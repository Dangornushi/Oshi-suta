import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../core/error/error_handler.dart';

/// リポジトリ基底クラス
abstract class BaseRepository {
  /// 共通API呼び出しラッパー
  Future<T> executeApiCall<T>({
    required Future<HttpResponse<T>> Function() apiCall,
    required String operationName,
  }) async {
    try {
      final response = await apiCall();

      if (response.data == null) {
        throw ServerException('${operationName}に失敗しました');
      }

      return response.data!;
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }
}
