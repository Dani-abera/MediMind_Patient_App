import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../models/medical_history_model.dart';

abstract class MedicalHistoryRemoteDataSource {
  Future<MedicalHistoryModel> getMedicalHistory();
  Future<MedicalHistoryModel> updateMedicalHistory(MedicalHistoryModel model);
}

class MedicalHistoryRemoteDataSourceImpl
    implements MedicalHistoryRemoteDataSource {
  MedicalHistoryRemoteDataSourceImpl(this._dio);
  final Dio _dio;

  @override
  Future<MedicalHistoryModel> getMedicalHistory() async {
    try {
      final res = await _dio.get('/patients/me/medical-history');
      return MedicalHistoryModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException(
          message: e.response?.data?['message'] ?? e.message ?? 'Error');
    }
  }

  @override
  Future<MedicalHistoryModel> updateMedicalHistory(
      MedicalHistoryModel model) async {
    try {
      final res = await _dio.put(
        '/patients/me/medical-history',
        data: model.toJson(),
      );
      return MedicalHistoryModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException(
          message: e.response?.data?['message'] ?? e.message ?? 'Error');
    }
  }
}
