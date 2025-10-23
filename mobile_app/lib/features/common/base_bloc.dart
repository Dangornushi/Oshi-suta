import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/error/error_handler.dart';

/// BLoC基底クラス
abstract class BaseBloc<Event, State> extends Bloc<Event, State> {
  BaseBloc(super.initialState);

  /// 共通のエラーハンドリング付き非同期処理
  Future<void> executeWithErrorHandling({
    required Emitter<State> emit,
    required Future<void> Function() operation,
    required State Function() loadingState,
    required State Function(String errorMessage) errorState,
  }) async {
    emit(loadingState());

    try {
      await operation();
    } catch (e) {
      final appException = ErrorHandler.handleError(e);
      emit(errorState(appException.message));
    }
  }
}
