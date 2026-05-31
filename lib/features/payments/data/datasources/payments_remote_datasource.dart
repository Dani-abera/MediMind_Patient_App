import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../models/payment_model.dart';

abstract class PaymentsRemoteDataSource {
  Future<PaymentModel> initiatePayment(String appointmentId);
  Future<PaymentModel> getPaymentStatus(String paymentId);
  Future<PaymentModel> syncPayment(String paymentId);
  Future<PaymentModel> verifyPayment(String txRef);
  Future<String?> getReceiptUrl(String paymentId);
}

class PaymentsRemoteDataSourceImpl implements PaymentsRemoteDataSource {
  const PaymentsRemoteDataSourceImpl(this._dio);
  final Dio _dio;

  @override
  Future<PaymentModel> initiatePayment(String appointmentId) async {
    try {
      final response = await _dio.post(
        '/payments/initiate',
        data: {'appointmentId': appointmentId},
      );
      return PaymentModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.error is Exception
          ? e.error as Exception
          : ServerException(message: e.message ?? 'Server error');
    }
  }

  @override
  Future<PaymentModel> getPaymentStatus(String paymentId) async {
    try {
      final response = await _dio.get('/payments/$paymentId/status');
      return PaymentModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.error is Exception
          ? e.error as Exception
          : ServerException(message: e.message ?? 'Server error');
    }
  }

  @override
  Future<PaymentModel> syncPayment(String paymentId) async {
    try {
      final response = await _dio.post('/payments/$paymentId/sync');
      return PaymentModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.error is Exception
          ? e.error as Exception
          : ServerException(message: e.message ?? 'Server error');
    }
  }

  @override
  Future<PaymentModel> verifyPayment(String txRef) async {
    try {
      final response = await _dio.post('/payments/$txRef/verify');
      return PaymentModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.error is Exception
          ? e.error as Exception
          : ServerException(message: e.message ?? 'Server error');
    }
  }

  @override
  Future<String?> getReceiptUrl(String paymentId) async {
    try {
      final response = await _dio.get('/payments/$paymentId/receipt');
      final data = response.data;
      return data is Map ? data['url'] as String? : null;
    } on DioException catch (e) {
      throw e.error is Exception
          ? e.error as Exception
          : ServerException(message: e.message ?? 'Server error');
    }
  }
}
