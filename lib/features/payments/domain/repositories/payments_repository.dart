import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/payment.dart';

abstract class PaymentsRepository {
  Future<Either<Failure, Payment>> initiatePayment(String appointmentId);
  Future<Either<Failure, Payment>> getPaymentStatus(String paymentId);
  Future<Either<Failure, Payment>> syncPayment(String paymentId);
  Future<Either<Failure, String?>> getReceiptUrl(String paymentId);
}
