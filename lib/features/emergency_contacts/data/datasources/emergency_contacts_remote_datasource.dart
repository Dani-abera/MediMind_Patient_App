import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../models/emergency_contact_model.dart';

abstract class EmergencyContactsRemoteDataSource {
  Future<List<EmergencyContactModel>> getContacts();
  Future<EmergencyContactModel> addContact(Map<String, dynamic> data);
  Future<EmergencyContactModel> updateContact(String id, Map<String, dynamic> data);
  Future<void> deleteContact(String id);
  Future<void> setPrimary(String id);
}

class EmergencyContactsRemoteDataSourceImpl
    implements EmergencyContactsRemoteDataSource {
  EmergencyContactsRemoteDataSourceImpl(this._dio);
  final Dio _dio;

  @override
  Future<List<EmergencyContactModel>> getContacts() async {
    try {
      final res = await _dio.get('/patients/me/emergency-contacts');
      final list = res.data is List ? res.data as List : (res.data['contacts'] as List? ?? []);
      return list
          .map((e) => EmergencyContactModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ServerException(message: e.response?.data?['message'] ?? e.message ?? 'Error');
    }
  }

  @override
  Future<EmergencyContactModel> addContact(Map<String, dynamic> data) async {
    try {
      final res = await _dio.post('/patients/me/emergency-contacts', data: data);
      return EmergencyContactModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException(message: e.response?.data?['message'] ?? e.message ?? 'Error');
    }
  }

  @override
  Future<EmergencyContactModel> updateContact(String id, Map<String, dynamic> data) async {
    try {
      final res = await _dio.put('/patients/me/emergency-contacts/$id', data: data);
      return EmergencyContactModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException(message: e.response?.data?['message'] ?? e.message ?? 'Error');
    }
  }

  @override
  Future<void> deleteContact(String id) async {
    try {
      await _dio.delete('/patients/me/emergency-contacts/$id');
    } on DioException catch (e) {
      throw ServerException(message: e.response?.data?['message'] ?? e.message ?? 'Error');
    }
  }

  @override
  Future<void> setPrimary(String id) async {
    try {
      await _dio.post('/patients/me/emergency-contacts/$id/set-primary');
    } on DioException catch (e) {
      throw ServerException(message: e.response?.data?['message'] ?? e.message ?? 'Error');
    }
  }
}
