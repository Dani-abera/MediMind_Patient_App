import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../models/center_model.dart';

abstract class CentersRemoteDataSource {
  Future<List<CenterModel>> getCenters({
    String? city,
    String? specialization,
    String? name,
    int page = 1,
    int pageSize = 20,
  });

  Future<List<CenterModel>> getNearbyCenters({
    required double latitude,
    required double longitude,
    double radiusKm = 10.0,
  });

  Future<CenterDetailModel> getCenterDetail(String centerId);
}

class CentersRemoteDataSourceImpl implements CentersRemoteDataSource {
  const CentersRemoteDataSourceImpl(this._dio);
  final Dio _dio;

  @override
  Future<List<CenterModel>> getCenters({
    String? city,
    String? specialization,
    String? name,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/healthcare-centers',
        queryParameters: {
          if (city != null) 'city': city,
          if (specialization != null) 'specialization': specialization,
          if (name != null) 'name': name,
          'page': page,
          'pageSize': pageSize,
        },
      );
      final items = (response.data['items'] ?? response.data) as List<dynamic>;
      return items
          .map((e) => CenterModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw e.error is Exception
          ? e.error as Exception
          : ServerException(message: e.message ?? 'Server error');
    }
  }

  @override
  Future<List<CenterModel>> getNearbyCenters({
    required double latitude,
    required double longitude,
    double radiusKm = 10.0,
  }) async {
    try {
      final response = await _dio.get(
        '/healthcare-centers/nearby',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'radiusKm': radiusKm,
        },
      );
      final items = response.data as List<dynamic>;
      return items
          .map((e) => CenterModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw e.error is Exception
          ? e.error as Exception
          : ServerException(message: e.message ?? 'Server error');
    }
  }

  @override
  Future<CenterDetailModel> getCenterDetail(String centerId) async {
    try {
      final response =
          await _dio.get('/healthcare-centers/$centerId');
      return CenterDetailModel.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.error is Exception
          ? e.error as Exception
          : ServerException(message: e.message ?? 'Server error');
    }
  }
}
