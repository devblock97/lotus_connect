import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:lotus_connect/core/errors/failure.dart';
import 'package:lotus_connect/features/settings/data/datasources/settings_local_data_source.dart';
import 'package:lotus_connect/features/settings/data/repositories/settings_repository.dart';
import 'package:lotus_connect/features/settings/domain/entities/app_settings.dart';
import 'package:mocktail/mocktail.dart';

class MockSettingLocalDataSource extends Mock
    implements SettingLocalDataSource {}

void main() {
  late MockSettingLocalDataSource mockLocalDataSource;
  late SettingsRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(const AppSettings());
  });

  setUp(() {
    mockLocalDataSource = MockSettingLocalDataSource();
    repository = SettingsRepositoryImpl(localDataSource: mockLocalDataSource);
  });

  const testSettings = AppSettings(
    userId: 'user_123',
    username: 'testuser',
    email: 'test@example.com',
  );

  group('SettingsRepositoryImpl', () {
    group('getAppSettings', () {
      test('should return Right(AppSettings) on success', () async {
        when(() => mockLocalDataSource.getAppSettings())
            .thenAnswer((_) async => testSettings);

        final result = await repository.getAppSettings();

        expect(result, const Right<Failure, AppSettings>(testSettings));
        verify(() => mockLocalDataSource.getAppSettings()).called(1);
        verifyNoMoreInteractions(mockLocalDataSource);
      });

      test('should return Left(DatabaseFailure) when exception is thrown',
          () async {
        when(() => mockLocalDataSource.getAppSettings())
            .thenThrow(Exception('Database error'));

        final result = await repository.getAppSettings();

        expect(
          result,
          const Left<Failure, AppSettings>(
            DatabaseFailure('Failed to get app settings. Please try again'),
          ),
        );
        verify(() => mockLocalDataSource.getAppSettings()).called(1);
        verifyNoMoreInteractions(mockLocalDataSource);
      });
    });

    group('updateAppSettings', () {
      test('should return Right(null) when update succeeds', () async {
        when(() => mockLocalDataSource.updateAppSettings(any()))
            .thenAnswer((_) async {});

        final result = await repository.updateAppSettings(testSettings);

        expect(result, const Right<Failure, void>(null));
        verify(() => mockLocalDataSource.updateAppSettings(testSettings))
            .called(1);
        verifyNoMoreInteractions(mockLocalDataSource);
      });

      test('should return Left(DatabaseFailure) when update throws exception',
          () async {
        when(() => mockLocalDataSource.updateAppSettings(any()))
            .thenThrow(Exception('Database update error'));

        final result = await repository.updateAppSettings(testSettings);

        expect(
          result,
          const Left<Failure, void>(
            DatabaseFailure('Failed to update app setting. Please try again'),
          ),
        );
        verify(() => mockLocalDataSource.updateAppSettings(testSettings))
            .called(1);
        verifyNoMoreInteractions(mockLocalDataSource);
      });
    });
  });
}
