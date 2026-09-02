import 'package:lotus_connect/core/errors/exception.dart';
import 'package:lotus_connect/core/network/dio_client.dart';
import 'package:lotus_connect/features/calls/data/models/call_log_model.dart';

abstract class CallsRemoteDataSource {
  Future<List<CallLogModel>> getCallHistory();
}

class CallsRemoteDataSourceImpl implements CallsRemoteDataSource {
  CallsRemoteDataSourceImpl({required this.dioClient});

  final DioClient dioClient;

  @override
  Future<List<CallLogModel>> getCallHistory() async {
    try {
      final response = await dioClient.get<dynamic>('/calls/history');
      if (response.statusCode == 200) {
        final list = response.data as List<dynamic>;
        return list
            .map((item) => CallLogModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      throw const ServerException('Failed to load call history');
    } on Object catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to load call history: $e');
    }
  }
}
