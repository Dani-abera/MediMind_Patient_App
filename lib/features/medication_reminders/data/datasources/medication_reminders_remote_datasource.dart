import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../models/medication_reminder_model.dart';

abstract class MedicationRemindersRemoteDataSource {
  Future<List<MedicationReminderModel>> getReminders();
  Future<MedicationReminderModel> addReminder(Map<String, dynamic> body);
  Future<MedicationReminderModel> updateReminder(
      String id, Map<String, dynamic> body);
  Future<void> deleteReminder(String id);
  Future<MedicationReminderModel> toggleReminder(String id);
}

class MedicationRemindersRemoteDataSourceImpl
    implements MedicationRemindersRemoteDataSource {
  const MedicationRemindersRemoteDataSourceImpl(this._dio);
  final Dio _dio;

  @override
  Future<List<MedicationReminderModel>> getReminders() async {
    try {
      final response = await _dio.get('/medication-reminders');
      final items =
          (response.data['items'] ?? response.data) as List<dynamic>;
      return items
          .map((e) =>
              MedicationReminderModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  @override
  Future<MedicationReminderModel> addReminder(
      Map<String, dynamic> body) async {
    try {
      final response =
          await _dio.post('/medication-reminders', data: body);
      return MedicationReminderModel.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  @override
  Future<MedicationReminderModel> updateReminder(
      String id, Map<String, dynamic> body) async {
    try {
      final response =
          await _dio.put('/medication-reminders/$id', data: body);
      return MedicationReminderModel.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  @override
  Future<void> deleteReminder(String id) async {
    try {
      await _dio.delete('/medication-reminders/$id');
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  @override
  Future<MedicationReminderModel> toggleReminder(String id) async {
    try {
      final response =
          await _dio.patch('/medication-reminders/$id/toggle');
      return MedicationReminderModel.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  Exception _mapDio(DioException e) => e.error is Exception
      ? e.error as Exception
      : ServerException(message: e.message ?? 'Server error');
}
