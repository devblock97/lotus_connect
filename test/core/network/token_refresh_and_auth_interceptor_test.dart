import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lotus_connect/core/errors/exception.dart';
import 'package:lotus_connect/core/network/dio_client.dart';
import 'package:lotus_connect/core/network/interceptors/auth_interceptor.dart';
import 'package:lotus_connect/core/network/interceptors/token_refresh_interceptor.dart';
import 'package:lotus_connect/core/network/network_security_utils.dart';

typedef AdapterHandler = Future<ResponseBody> Function(
  RequestOptions options,
  Stream<Uint8List>? requestStream,
  Future<void>? cancelFuture,
);

class FakeHttpClientAdapter implements HttpClientAdapter {
  FakeHttpClientAdapter(this._handler);

  final AdapterHandler _handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    return _handler(options, requestStream, cancelFuture);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody jsonResponse(Map<String, dynamic> body, int statusCode) {
  return ResponseBody.fromString(
    jsonEncode(body),
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

void main() {
  group('NetworkSecurityUtils', () {
    test('isTrustedOrigin matches identical scheme, host, and port', () {
      expect(
        NetworkSecurityUtils.isTrustedOrigin(
          Uri.parse('https://10.0.2.2:8443/api/v1/users/me'),
          serverHost: 'https://10.0.2.2:8443/api/v1',
        ),
        isTrue,
      );
      expect(
        NetworkSecurityUtils.isTrustedOrigin(
          Uri.parse('https://api.lotus.app:443/uploads/avatar.jpg'),
          serverHost: 'https://api.lotus.app/api/v1',
        ),
        isTrue,
      );
    });

    test('isTrustedOrigin rejects external hosts, port changes, and downgrades',
        () {
      const serverHost = 'https://api.lotus.app/api/v1';

      expect(
        NetworkSecurityUtils.isTrustedOrigin(
          Uri.parse('https://evil.com/api/v1/users/me'),
          serverHost: serverHost,
        ),
        isFalse,
      );
      expect(
        NetworkSecurityUtils.isTrustedOrigin(
          Uri.parse('http://api.lotus.app/api/v1/users/me'),
          serverHost: serverHost,
        ),
        isFalse,
      );
      expect(
        NetworkSecurityUtils.isTrustedOrigin(
          Uri.parse('https://api.lotus.app:8443/api/v1/users/me'),
          serverHost: serverHost,
        ),
        isFalse,
      );
      expect(
        NetworkSecurityUtils.isTrustedOrigin(
          Uri.parse('https://api.lotus.app@evil.com/api/v1/users/me'),
          serverHost: serverHost,
        ),
        isFalse,
      );
      expect(
        NetworkSecurityUtils.isTrustedOrigin(
          Uri.parse('/users/me'),
          serverHost: serverHost,
        ),
        isFalse,
      );
    });

    test('buildTrustedEndpointUrl anchors endpoint strictly to serverHost', () {
      expect(
        NetworkSecurityUtils.buildTrustedEndpointUrl(
          endpointPath: '/auth/refresh',
          serverHost: 'https://api.lotus.app/api/v1/',
        ),
        'https://api.lotus.app/api/v1/auth/refresh',
      );
      expect(
        NetworkSecurityUtils.buildTrustedEndpointUrl(
          endpointPath: '/auth/refresh',
          serverHost: '',
          fallbackBaseUrl: 'https://fallback.lotus.app/api/v1',
        ),
        'https://fallback.lotus.app/api/v1/auth/refresh',
      );
      expect(
        NetworkSecurityUtils.buildTrustedEndpointUrl(
          endpointPath: '/auth/refresh',
          serverHost: '',
          fallbackBaseUrl: '',
        ),
        isNull,
      );
    });
  });

  group('AuthInterceptor', () {
    test('attaches Bearer token for trusted origin requests', () async {
      RequestOptions? capturedOptions;
      final dio = Dio(BaseOptions(baseUrl: 'https://api.lotus.app/api/v1'))
        ..httpClientAdapter = FakeHttpClientAdapter((options, _, __) async {
          capturedOptions = options;
          return jsonResponse({'ok': true}, 200);
        })
        ..interceptors.add(
          AuthInterceptor(
            getToken: () => 'secret_jwt_token',
            getTrustedServerHost: () => 'https://api.lotus.app/api/v1',
          ),
        );

      await dio.get<dynamic>('/users/me');

      expect(
        capturedOptions?.headers['Authorization'],
        'Bearer secret_jwt_token',
      );
    });

    test('does not leak Bearer token to external URLs or HTTP downgrades',
        () async {
      final capturedHeaders = <Map<String, dynamic>>[];
      final dio = Dio(BaseOptions(baseUrl: 'https://api.lotus.app/api/v1'))
        ..httpClientAdapter = FakeHttpClientAdapter((options, _, __) async {
          capturedHeaders.add(Map<String, dynamic>.from(options.headers));
          return jsonResponse({'ok': true}, 200);
        })
        ..interceptors.add(
          AuthInterceptor(
            getToken: () => 'secret_jwt_token',
            getTrustedServerHost: () => 'https://api.lotus.app/api/v1',
          ),
        );

      await dio.get<dynamic>('https://cdn.thirdparty.com/video.mp4');
      await dio.get<dynamic>('http://api.lotus.app/users/me');
      await dio.get<dynamic>('https://api.lotus.app:8443/users/me');
      await dio.get<dynamic>('https://api.lotus.app@evil.com/steal');

      expect(capturedHeaders, hasLength(4));
      for (final headers in capturedHeaders) {
        expect(headers.containsKey('Authorization'), isFalse);
      }

      // Also verify protocol-relative path without baseUrl never attaches token
      final bareDio = Dio()
        ..httpClientAdapter = FakeHttpClientAdapter((options, _, __) async {
          capturedHeaders.add(Map<String, dynamic>.from(options.headers));
          return jsonResponse({'ok': true}, 200);
        })
        ..interceptors.add(
          AuthInterceptor(
            getToken: () => 'secret_jwt_token',
            getTrustedServerHost: () => 'https://api.lotus.app/api/v1',
          ),
        );
      await bareDio.get<dynamic>('//evil.com/steal');
      expect(capturedHeaders.last.containsKey('Authorization'), isFalse);
    });
  });

  group('TokenRefreshInterceptor & DioClient RTR', () {
    test('refreshes token once on 401 and retries original request', () async {
      var accessToken = 'expired_access_token';
      var refreshToken = 'initial_refresh_token';
      var refreshCalls = 0;
      var refreshFailedCalls = 0;
      final requestAuthHeaders = <String?>[];
      final calledUrls = <String>[];

      final adapter = FakeHttpClientAdapter((options, _, __) async {
        calledUrls.add(options.uri.toString());
        if (options.uri.path.endsWith('/auth/refresh')) {
          refreshCalls++;
          return jsonResponse(
            {
              'accessToken': 'rotated_access_token',
              'refreshToken': 'rotated_refresh_token',
            },
            200,
          );
        }

        final auth = options.headers['Authorization'] as String?;
        requestAuthHeaders.add(auth);
        if (auth == 'Bearer rotated_access_token') {
          return jsonResponse({'id': 'user_1'}, 200);
        }
        return jsonResponse({'error': 'token expired'}, 401);
      });

      final client = DioClient(
        tokenGetter: () => accessToken,
        serverHostGetter: () => 'https://10.0.2.2:8443/api/v1',
        refreshTokenGetter: () => refreshToken,
        onTokensRefreshed: (newAccess, newRefresh) async {
          accessToken = newAccess;
          refreshToken = newRefresh;
        },
        onRefreshFailed: () => refreshFailedCalls++,
        dioFactory: (options) => Dio(options)..httpClientAdapter = adapter,
      );
      client.dio.httpClientAdapter = adapter;

      final response = await client.get<dynamic>('/users/me');

      expect(response.statusCode, 200);
      expect(response.data, {'id': 'user_1'});
      expect(refreshCalls, 1);
      expect(refreshFailedCalls, 0);
      expect(accessToken, 'rotated_access_token');
      expect(refreshToken, 'rotated_refresh_token');
      expect(
        requestAuthHeaders,
        ['Bearer expired_access_token', 'Bearer rotated_access_token'],
      );
      expect(
        calledUrls,
        contains('https://10.0.2.2:8443/api/v1/auth/refresh'),
      );
    });

    test('coalesces concurrent 401 responses into a single refresh request',
        () async {
      var accessToken = 'expired_token';
      var refreshToken = 'refresh_1';
      var refreshCalls = 0;
      var refreshFailedCalls = 0;
      final refreshStarted = Completer<void>();

      final adapter = FakeHttpClientAdapter((options, _, __) async {
        if (options.uri.path.endsWith('/auth/refresh')) {
          refreshCalls++;
          if (!refreshStarted.isCompleted) {
            refreshStarted.complete();
          }
          await Future<void>.delayed(const Duration(milliseconds: 25));
          return jsonResponse(
            {
              'accessToken': 'fresh_token',
              'refreshToken': 'refresh_2',
            },
            200,
          );
        }

        if (options.headers['Authorization'] == 'Bearer fresh_token') {
          return jsonResponse({'path': options.uri.path}, 200);
        }
        return jsonResponse({'error': 'expired'}, 401);
      });

      final client = DioClient(
        tokenGetter: () => accessToken,
        serverHostGetter: () => 'https://api.lotus.app/api/v1',
        refreshTokenGetter: () => refreshToken,
        onTokensRefreshed: (newAccess, newRefresh) async {
          accessToken = newAccess;
          refreshToken = newRefresh;
        },
        onRefreshFailed: () => refreshFailedCalls++,
        dioFactory: (options) => Dio(options)..httpClientAdapter = adapter,
      );
      client.dio.httpClientAdapter = adapter;

      final results = await Future.wait([
        client.get<dynamic>('/users/me'),
        client.get<dynamic>('/feed'),
      ]);

      expect(refreshCalls, 1);
      expect(refreshFailedCalls, 0);
      expect(accessToken, 'fresh_token');
      expect(refreshToken, 'refresh_2');
      expect(results[0].data, {'path': '/api/v1/users/me'});
      expect(results[1].data, {'path': '/api/v1/feed'});
    });

    test(
      'does not call onRefreshFailed when refresh succeeds but retry returns '
      '500',
      () async {
        var accessToken = 'old_token';
        var refreshToken = 'refresh_1';
        var refreshCalls = 0;
        var refreshFailedCalls = 0;

        final adapter = FakeHttpClientAdapter((options, _, __) async {
          if (options.uri.path.endsWith('/auth/refresh')) {
            refreshCalls++;
            return jsonResponse(
              {
                'accessToken': 'new_token',
                'refreshToken': 'refresh_2',
              },
              200,
            );
          }
          if (options.headers['Authorization'] == 'Bearer new_token') {
            return jsonResponse({'error': 'server error'}, 500);
          }
          return jsonResponse({'error': 'expired'}, 401);
        });

        final client = DioClient(
          tokenGetter: () => accessToken,
          serverHostGetter: () => 'https://api.lotus.app/api/v1',
          refreshTokenGetter: () => refreshToken,
          onTokensRefreshed: (newAccess, newRefresh) async {
            accessToken = newAccess;
            refreshToken = newRefresh;
          },
          onRefreshFailed: () => refreshFailedCalls++,
          dioFactory: (options) => Dio(options)..httpClientAdapter = adapter,
        );
        client.dio.httpClientAdapter = adapter;

        await expectLater(
          () => client.get<dynamic>('/users/me'),
          throwsA(isA<ServerException>()),
        );

        expect(refreshCalls, 1);
        expect(refreshFailedCalls, 0);
        expect(accessToken, 'new_token');
        expect(refreshToken, 'refresh_2');
      },
    );

    test('calls onRefreshFailed when refresh endpoint rejects with 401',
        () async {
      var accessToken = 'old_token';
      var refreshToken = 'revoked_refresh';
      var refreshFailedCalls = 0;

      final adapter = FakeHttpClientAdapter((options, _, __) async {
        return jsonResponse({'error': 'invalid refresh token'}, 401);
      });

      final client = DioClient(
        tokenGetter: () => accessToken,
        serverHostGetter: () => 'https://api.lotus.app/api/v1',
        refreshTokenGetter: () => refreshToken,
        onTokensRefreshed: (newAccess, newRefresh) async {
          accessToken = newAccess;
          refreshToken = newRefresh;
        },
        onRefreshFailed: () {
          refreshFailedCalls++;
          accessToken = '';
          refreshToken = '';
        },
        dioFactory: (options) => Dio(options)..httpClientAdapter = adapter,
      );
      client.dio.httpClientAdapter = adapter;

      await expectLater(
        () => client.get<dynamic>('/users/me'),
        throwsA(isA<AuthException>()),
      );

      expect(refreshFailedCalls, 1);
      expect(accessToken, '');
      expect(refreshToken, '');
    });

    test(
      'never refreshes or leaks tokens when external URL returns 401',
      () async {
        var refreshCalls = 0;
        var refreshFailedCalls = 0;
        RequestOptions? externalRequest;

        final adapter = FakeHttpClientAdapter((options, _, __) async {
          if (options.uri.path.endsWith('/auth/refresh')) {
            refreshCalls++;
            return jsonResponse({}, 200);
          }
          externalRequest = options;
          return jsonResponse({'error': 'unauthorized external resource'}, 401);
        });

        final client = DioClient(
          tokenGetter: () => 'top_secret_access_token',
          serverHostGetter: () => 'https://api.lotus.app/api/v1',
          refreshTokenGetter: () => 'top_secret_refresh_token',
          onTokensRefreshed: (_, __) async {},
          onRefreshFailed: () => refreshFailedCalls++,
          dioFactory: (options) => Dio(options)..httpClientAdapter = adapter,
        );
        client.dio.httpClientAdapter = adapter;

        await expectLater(
          () => client.get<dynamic>('https://evil.example.com/steal'),
          throwsA(isA<AuthException>()),
        );

        expect(externalRequest?.headers.containsKey('Authorization'), isFalse);
        expect(refreshCalls, 0);
        expect(refreshFailedCalls, 0);
      },
    );

    test('never refreshes when /auth/login or /auth/refresh returns 401',
        () async {
      var refreshCalls = 0;
      var refreshFailedCalls = 0;

      final adapter = FakeHttpClientAdapter((options, _, __) async {
        if (options.uri.path.endsWith('/auth/refresh')) {
          refreshCalls++;
        }
        return jsonResponse({'error': 'invalid credentials'}, 401);
      });

      final client = DioClient(
        tokenGetter: () => '',
        serverHostGetter: () => 'https://api.lotus.app/api/v1',
        refreshTokenGetter: () => 'some_refresh_token',
        onTokensRefreshed: (_, __) async {},
        onRefreshFailed: () => refreshFailedCalls++,
        dioFactory: (options) => Dio(options)..httpClientAdapter = adapter,
      );
      client.dio.httpClientAdapter = adapter;

      await expectLater(
        () => client.post<dynamic>('/auth/login', data: {'email': 'a@b.c'}),
        throwsA(isA<AuthException>()),
      );

      expect(refreshCalls, 0);
      expect(refreshFailedCalls, 0);
    });

    test('refreshes cleanly when trusted /uploads/ resource returns 401',
        () async {
      var accessToken = 'expired';
      var refreshToken = 'r1';
      final requestedUrls = <String>[];

      final adapter = FakeHttpClientAdapter((options, _, __) async {
        requestedUrls.add(options.uri.toString());
        if (options.uri.toString() ==
            'https://10.0.2.2:8443/api/v1/auth/refresh') {
          return jsonResponse(
            {
              'accessToken': 'fresh',
              'refreshToken': 'r2',
            },
            200,
          );
        }
        if (options.headers['Authorization'] == 'Bearer fresh') {
          return jsonResponse({'uploaded': true}, 200);
        }
        return jsonResponse({'error': 'expired'}, 401);
      });

      final client = DioClient(
        tokenGetter: () => accessToken,
        serverHostGetter: () => 'https://10.0.2.2:8443/api/v1',
        refreshTokenGetter: () => refreshToken,
        onTokensRefreshed: (a, r) async {
          accessToken = a;
          refreshToken = r;
        },
        onRefreshFailed: () {},
        dioFactory: (options) => Dio(options)..httpClientAdapter = adapter,
      );
      client.dio.httpClientAdapter = adapter;

      final res = await client.get<dynamic>(
        'https://old-tunnel.ngrok.app/uploads/a.png',
      );

      expect(res.statusCode, 200);
      expect(
        requestedUrls,
        [
          'https://10.0.2.2:8443/uploads/a.png',
          'https://10.0.2.2:8443/api/v1/auth/refresh',
          'https://10.0.2.2:8443/uploads/a.png',
        ],
      );
    });

    test(
      'retries directly with latest token if already rotated before 401 '
      'arrives',
      () async {
        var refreshCalls = 0;
        final retryHeaders = <String?>[];
        final adapter = FakeHttpClientAdapter((options, _, __) async {
          if (options.uri.path.endsWith('/auth/refresh')) {
            refreshCalls++;
            return jsonResponse({}, 500);
          }
          retryHeaders.add(options.headers['Authorization'] as String?);
          return jsonResponse({'ok': true}, 200);
        });

        final interceptor = TokenRefreshInterceptor(
          getRefreshToken: () => 'refresh_token',
          getAccessToken: () => 'already_rotated_token',
          getServerHost: () => 'https://api.lotus.app/api/v1',
          onTokensRefreshed: (_, __) async {},
          onRefreshFailed: () {},
          dioFactory: (options) => Dio(options)..httpClientAdapter = adapter,
        );

        final dio = Dio(BaseOptions(baseUrl: 'https://api.lotus.app/api/v1'))
          ..httpClientAdapter = FakeHttpClientAdapter((options, _, __) async {
            return jsonResponse({'error': 'expired'}, 401);
          })
          ..interceptors.add(interceptor);

        final res = await dio.get<dynamic>(
          '/users/me',
          options: Options(
            headers: {'Authorization': 'Bearer stale_token'},
          ),
        );

        expect(res.statusCode, 200);
        expect(refreshCalls, 0);
        expect(retryHeaders, ['Bearer already_rotated_token']);
      },
    );
  });
}
