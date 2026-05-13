import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../models/payment_record_model.dart';

abstract class PaymentsHistoryDataSource {
  Future<List<PaymentRecordModel>> getPaymentHistory(
      {int page, int pageSize});
}

class PaymentsHistoryDataSourceImpl implements PaymentsHistoryDataSource {
  const PaymentsHistoryDataSourceImpl(this._dio);
  final Dio _dio;

  @override
  Future<List<PaymentRecordModel>> getPaymentHistory(
      {int page = 1, int pageSize = 20}) async {
    try {
      final res = await _dio.get('/payments',
          queryParameters: {'page': page, 'pageSize': pageSize});
      final data = res.data;
      final list = data is List
          ? data
          : (data['data'] as List? ?? data['items'] as List? ?? []);
      return list
          .map((e) =>
              PaymentRecordModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ServerException(
          message: e.response?.data?['message'] ?? e.message ?? 'Error');
    }
  }
}
