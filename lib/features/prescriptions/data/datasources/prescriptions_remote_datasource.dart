import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../models/prescription_model.dart';

abstract class PrescriptionsRemoteDataSource {
  Future<List<PrescriptionModel>> getPrescriptions({int page, int pageSize});
  Future<PrescriptionModel> getPrescription(String id);
  Future<String> getPrescriptionPdfUrl(String id);
}

class PrescriptionsRemoteDataSourceImpl
    implements PrescriptionsRemoteDataSource {
  PrescriptionsRemoteDataSourceImpl(this._dio);
  final Dio _dio;

  @override
  Future<List<PrescriptionModel>> getPrescriptions(
      {int page = 1, int pageSize = 20}) async {
    try {
      final res = await _dio.get('/prescriptions',
          queryParameters: {'page': page, 'pageSize': pageSize});
      final items = res.data is List
          ? res.data as List
          : (res.data['items'] as List? ?? []);
      return items
          .map((e) => PrescriptionModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ServerException(
          message: e.response?.data?['message'] ?? e.message ?? 'Error');
    }
  }

  @override
  Future<PrescriptionModel> getPrescription(String id) async {
    try {
      final res = await _dio.get('/prescriptions/$id');
      return PrescriptionModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException(
          message: e.response?.data?['message'] ?? e.message ?? 'Error');
    }
  }

  @override
  Future<String> getPrescriptionPdfUrl(String id) async {
    try {
      final res = await _dio.get('/prescriptions/$id/pdf');
      return res.data['url'] as String? ??
          res.data['pdfUrl'] as String? ?? '';
    } on DioException catch (e) {
      throw ServerException(
          message: e.response?.data?['message'] ?? e.message ?? 'Error');
    }
  }
}
