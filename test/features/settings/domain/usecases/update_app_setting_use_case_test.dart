import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:lotus_connect/core/errors/failure.dart';
import 'package:lotus_connect/features/settings/domain/entities/app_settings.dart';
import 'package:lotus_connect/features/settings/domain/repositories/settings_repository.dart';
import 'package:lotus_connect/features/settings/domain/usecases/update_app_setting_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  late MockSettingsRepository mockRepository;
  late UpdateAppSettingUseCase useCase;

  setUpAll(() {
    registerFallbackValue(const AppSettings());
  });

  setUp(() {
    mockRepository = MockSettingsRepository();
    useCase = UpdateAppSettingUseCase(repository: mockRepository);
  });

  const testSettings = AppSettings(
    userId: 'user_123',
    username: 'testuser',
    email: 'user@example.com',
    fullName: 'Test User',
  );

  group('UpdateAppSettingUseCase', () {
    test('should return Right(null) when repository update succeeds', () async {
      when(() => mockRepository.updateAppSettings(any()))
          .thenAnswer((_) async => const Right(null));

      final result =
          await useCase(const UpdateAppSettingParam(settings: testSettings));

      expect(result, const Right<Failure, void>(null));
      verify(() => mockRepository.updateAppSettings(testSettings)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return Left(DatabaseFailure) when repository update fails',
        () async {
      const failure = DatabaseFailure('Failed to update app setting');
      when(() => mockRepository.updateAppSettings(any()))
          .thenAnswer((_) async => const Left(failure));

      final result =
          await useCase(const UpdateAppSettingParam(settings: testSettings));

      expect(result, const Left<Failure, void>(failure));
      verify(() => mockRepository.updateAppSettings(testSettings)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
