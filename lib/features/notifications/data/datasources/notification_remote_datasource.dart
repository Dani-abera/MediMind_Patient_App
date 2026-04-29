import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../models/notification_item_model.dart';

abstract class NotificationRemoteDataSource {
  Future<int> getUnreadCount();
  Future<List<NotificationItemModel>> getNotifications({int page, int pageSize});
  Future<NotificationPreferencesModel> getPreferences();
  Future<void> updatePreferences(Map<String, dynamic> data);
  Future<void> markRead(String id);
  Future<void> markAllRead();
  Future<void> registerDeviceToken(String token, String platform);
  Future<void> unregisterDeviceToken(String token);
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
      if (e.response?.statusCode == 401) throw const UnauthorizedException();
      throw NetworkException(message: e.message ?? 'Error');
    }
  }

  @override
  Future<List<NotificationItemModel>> getNotifications(
      {int page = 1, int pageSize = 20}) async {
    try {
      final res = await _dio.get('/notifications/history',
          queryParameters: {'page': page, 'pageSize': pageSize});
      final list = res.data is List
          ? res.data as List
          : (res.data['items'] as List? ?? []);
      return list
          .map((e) =>
              NotificationItemModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ServerException(
          message: e.response?.data?['message'] ?? e.message ?? 'Error');
    }
  }

  @override
  Future<NotificationPreferencesModel> getPreferences() async {
    try {
      final res = await _dio.get('/notifications/preferences');
      return NotificationPreferencesModel.fromJson(
          res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException(
          message: e.response?.data?['message'] ?? e.message ?? 'Error');
    }
  }

  @override
  Future<void> updatePreferences(Map<String, dynamic> data) async {
    try {
      await _dio.put('/notifications/preferences', data: data);
    } on DioException catch (e) {
      throw ServerException(
          message: e.response?.data?['message'] ?? e.message ?? 'Error');
    }
  }

  @override
  Future<void> markRead(String id) async {
    try {
      await _dio.post('/notifications/$id/mark-read');
    } on DioException catch (e) {
      throw ServerException(
          message: e.response?.data?['message'] ?? e.message ?? 'Error');
    }
  }

  @override
  Future<void> markAllRead() async {
    try {
      await _dio.post('/notifications/mark-all-read');
    } on DioException catch (e) {
      throw ServerException(
          message: e.response?.data?['message'] ?? e.message ?? 'Error');
    }
  }

  @override
  Future<void> registerDeviceToken(String token, String platform) async {
    try {
      await _dio.post('/notifications/device-token',
          data: {'token': token, 'platform': platform});
    } on DioException catch (e) {
      throw ServerException(
          message: e.response?.data?['message'] ?? e.message ?? 'Error');
    }
  }

  @override
  Future<void> unregisterDeviceToken(String token) async {
    try {
      await _dio.delete('/notifications/device-token',
          data: {'token': token});
    } on DioException catch (e) {
      throw ServerException(
          message: e.response?.data?['message'] ?? e.message ?? 'Error');
    }
  }
}
