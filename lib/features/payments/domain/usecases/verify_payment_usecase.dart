import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/payment.dart';
import '../repositories/payments_repository.dart';

class VerifyPaymentUsecase {
  const VerifyPaymentUsecase(this._repository);
  final PaymentsRepository _repository;

  Future<Either<Failure, Payment>> call(String txRef) =>
      _repository.verifyPayment(txRef);
}
