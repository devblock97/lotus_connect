import 'package:lotus_connect/core/utils/typedefs.dart';

abstract class ChatCommand<T> {
  /// Unique identifier of this command / action (useful for tracking retries)
  String get id;

  /// Executes the command (including remote dispatch and database writes)
  FutureResult<T> execute();

  /// Rolls back the optimistic changes if the remote operation fails
  Future<void> undo();
}
