import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../models/prediction_model.dart';
import '../models/prediction_status_model.dart';

abstract class PredictionsRemoteDataSource {
  Future<PredictionModel> requestPrediction();
  Future<List<PredictionModel>> getPredictions();
  Future<PredictionModel?> getLatestPrediction();
  Future<PredictionModel> getPredictionById(String id);
  Future<PredictionStatusModel> getPredictionStatus();
}

class PredictionsRemoteDataSourceImpl implements PredictionsRemoteDataSource {
  const PredictionsRemoteDataSourceImpl(this._dio);
  final Dio _dio;

  @override
  Future<PredictionModel> requestPrediction() async {
    try {
      final response = await _dio.post('/health-predictions/request');
      return PredictionModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  @override
  Future<List<PredictionModel>> getPredictions() async {
    try {
      final response = await _dio.get('/health-predictions');
      final data = response.data;
      final items = data is List
          ? data
          : (data as Map<String, dynamic>)['items'] as List<dynamic>? ?? [];
      return items
          .map((e) => PredictionModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  @override
  Future<PredictionModel?> getLatestPrediction() async {
    try {
      final response = await _dio.get('/health-predictions/latest');
      if (response.data == null) return null;
      return PredictionModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw _mapDio(e);
    }
  }

  @override
  Future<PredictionModel> getPredictionById(String id) async {
    try {
      final response = await _dio.get('/health-predictions/$id');
      return PredictionModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  @override
  Future<PredictionStatusModel> getPredictionStatus() async {
    try {
      final response = await _dio.get('/health-predictions/status');
      return PredictionStatusModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  Exception _mapDio(DioException e) => e.error is Exception
      ? e.error as Exception
      : ServerException(message: e.message ?? 'Server error');
}
