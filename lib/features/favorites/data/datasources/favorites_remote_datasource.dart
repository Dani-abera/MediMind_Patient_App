import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../models/favorite_model.dart';

abstract class FavoritesRemoteDataSource {
  Future<List<FavoriteDoctorModel>> getFavoriteDoctors();
  Future<void> addFavoriteDoctor(String doctorId);
  Future<void> removeFavoriteDoctor(String doctorId);
  Future<List<FavoriteCenterModel>> getFavoriteCenters();
  Future<void> addFavoriteCenter(String centerId);
  Future<void> removeFavoriteCenter(String centerId);
}

class FavoritesRemoteDataSourceImpl implements FavoritesRemoteDataSource {
  FavoritesRemoteDataSourceImpl(this._dio);
  final Dio _dio;

  @override
  Future<List<FavoriteDoctorModel>> getFavoriteDoctors() async {
    try {
      final res = await _dio.get('/favorites/doctors');
      final list = res.data is List ? res.data as List : (res.data['items'] as List? ?? []);
      return list.map((e) => FavoriteDoctorModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ServerException(message: e.response?.data?['message'] ?? e.message ?? 'Error');
    }
  }

  @override
  Future<void> addFavoriteDoctor(String doctorId) async {
    try { await _dio.post('/favorites/doctors/$doctorId'); }
    on DioException catch (e) { throw ServerException(message: e.response?.data?['message'] ?? e.message ?? 'Error'); }
  }

  @override
  Future<void> removeFavoriteDoctor(String doctorId) async {
    try { await _dio.delete('/favorites/doctors/$doctorId'); }
    on DioException catch (e) { throw ServerException(message: e.response?.data?['message'] ?? e.message ?? 'Error'); }
  }

  @override
  Future<List<FavoriteCenterModel>> getFavoriteCenters() async {
    try {
      final res = await _dio.get('/favorites/centers');
      final list = res.data is List ? res.data as List : (res.data['items'] as List? ?? []);
      return list.map((e) => FavoriteCenterModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ServerException(message: e.response?.data?['message'] ?? e.message ?? 'Error');
    }
  }

  @override
  Future<void> addFavoriteCenter(String centerId) async {
    try { await _dio.post('/favorites/centers/$centerId'); }
    on DioException catch (e) { throw ServerException(message: e.response?.data?['message'] ?? e.message ?? 'Error'); }
  }

  @override
  Future<void> removeFavoriteCenter(String centerId) async {
    try { await _dio.delete('/favorites/centers/$centerId'); }
    on DioException catch (e) { throw ServerException(message: e.response?.data?['message'] ?? e.message ?? 'Error'); }
  }
}
