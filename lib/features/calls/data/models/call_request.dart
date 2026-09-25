import 'package:flutter_riverpod/flutter_riverpod.dart';

class CallRequest {
  const CallRequest({required this.recipientId, required this.isVideo});
  final String recipientId;
  final bool isVideo;
}

final callRequestProvider = StateProvider<CallRequest?>((ref) => null);
