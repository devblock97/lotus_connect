import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:lotus_connect/core/errors/failure.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/features/settings/domain/entities/app_settings.dart';
import 'package:lotus_connect/features/settings/domain/repositories/settings_repository.dart';
import 'package:lotus_connect/features/settings/domain/usecases/get_app_settings_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  late MockSettingsRepository mockRepository;
  late GetAppSettingsUseCase useCase;

  setUp(() {
    mockRepository = MockSettingsRepository();
    useCase = GetAppSettingsUseCase(repository: mockRepository);
  });

  const testSettings = AppSettings(
    userId: 'user_123',
    username: 'testuser',
    email: 'user@example.com',
    fullName: 'Test User',
  );

  group('GetAppSettingsUseCase', () {
    test('should return Right(AppSettings) when getAppSettings succeeds',
        () async {
      when(() => mockRepository.getAppSettings())
          .thenAnswer((_) async => const Right(testSettings));

      final result = await useCase(const NoParams());

      expect(result, const Right<Failure, AppSettings>(testSettings));
      verify(() => mockRepository.getAppSettings()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return Left(DatabaseFailure) when getAppSettings fails',
        () async {
      const failure = DatabaseFailure('Failed to get app settings');
      when(() => mockRepository.getAppSettings())
          .thenAnswer((_) async => const Left(failure));

      final result = await useCase(const NoParams());

      expect(result, const Left<Failure, AppSettings>(failure));
      verify(() => mockRepository.getAppSettings()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
