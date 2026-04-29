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
      final res = await _dio.get('/payments/history',
          queryParameters: {'page': page, 'pageSize': pageSize});
      final list = res.data is List
          ? res.data as List
          : (res.data['items'] as List? ?? []);
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
