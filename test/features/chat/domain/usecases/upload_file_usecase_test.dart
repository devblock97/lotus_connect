import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:lotus_connect/core/errors/failure.dart';
import 'package:lotus_connect/features/chat/data/models/file_upload_response_model.dart';
import 'package:lotus_connect/features/chat/domain/repositories/private_chat_repository.dart';
import 'package:lotus_connect/features/chat/domain/usecases/upload_file_usecase.dart';
import 'package:lotus_connect/features/chat_core/domain/entities/message.dart';
import 'package:mocktail/mocktail.dart';

class MockChatRepository extends Mock implements PrivateChatRepository {}

void main() {
  late MockChatRepository mockChatRepo;
  late UploadFileUseCase useCase;

  setUp(() {
    mockChatRepo = MockChatRepository();
    useCase = UploadFileUseCase(repository: mockChatRepo);
  });

  const testFileUpload = FileUploadResponseModel(
    files: [
      MediaModel(
        url: 'https://lotusconnect.com/uploads/file1.png',
        thumbnailUrl: 'https://lotusconnect.com/uploads/thumbnail.png',
        fileName: 'file1.png',
        mimeType: 'image/png',
      ),
    ],
    fileUrls: [
      'https://lotusconnect.com/uploads/thumbnail.png',
    ],
  );

  group('uploadFileUseCase', () {
    test('should return FileUploadResponseModel when uploadFile succeeds',
        () async {
      when(
        () => mockChatRepo.uploadFiles(['/path/to/file1.png']),
      ).thenAnswer((_) async => const Right(testFileUpload));

      final result = await useCase(
        const UploadFileParam(
          paths: ['/path/to/file1.png'],
        ),
      );

      expect(
        result,
        const Right<Failure, FileUploadResponseModel>(testFileUpload),
      );
      verify(() => mockChatRepo.uploadFiles(['/path/to/file1.png'])).called(1);
      verifyNoMoreInteractions(mockChatRepo);
    });

    test('should return ServerFailure when uploadFile fails', () async {
      const serverFailure = ServerFailure('Failed to upload media from server');
      when(
        () => mockChatRepo.uploadFiles(['/path/to/file1.png']),
      ).thenAnswer(
        (_) async => const Left(serverFailure),
      );

      final result = await useCase(
        const UploadFileParam(
          paths: ['/path/to/file1.png'],
        ),
      );

      expect(
        result,
        const Left<Failure, FileUploadResponseModel>(serverFailure),
      );
      verify(() => mockChatRepo.uploadFiles(['/path/to/file1.png'])).called(1);
      verifyNoMoreInteractions(mockChatRepo);
    });

    test('should return NetworkFailure when device has no internet connection',
        () async {
      const networkFailure = NetworkFailure('No internet connection');
      when(() => mockChatRepo.uploadFiles(['/path/to/file1.png']))
          .thenAnswer((_) async => const Left(networkFailure));

      final result = await useCase(
        const UploadFileParam(
          paths: ['/path/to/file1.png'],
        ),
      );

      expect(
        result,
        const Left<Failure, FileUploadResponseModel>(networkFailure),
      );
      verify(() => mockChatRepo.uploadFiles(['/path/to/file1.png']));
      verifyNoMoreInteractions(mockChatRepo);
    });
  });
}
