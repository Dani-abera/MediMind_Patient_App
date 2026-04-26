import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';

abstract class NotificationRemoteDataSource {
  Future<int> getUnreadCount();
}

class NotificationRemoteDataSourceImpl
    implements NotificationRemoteDataSource {
  const NotificationRemoteDataSourceImpl(this._dio);
  final Dio _dio;

  @override
  Future<int> getUnreadCount() async {
    try {
      final res = await _dio.get('/notifications/unread-count');
      return (res.data['count'] as num?)?.toInt() ?? 0;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const UnauthorizedException();
      }
      throw NetworkException(message: e.message ?? 'Error');
    }
  }
}
