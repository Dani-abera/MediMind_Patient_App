import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/payment.dart';
import '../repositories/payments_repository.dart';

class SyncPaymentUsecase {
  const SyncPaymentUsecase(this._repository);
  final PaymentsRepository _repository;

  Future<Either<Failure, Payment>> call(String paymentId) =>
      _repository.syncPayment(paymentId);
}
