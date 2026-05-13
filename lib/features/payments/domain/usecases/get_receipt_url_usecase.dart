import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/payments_repository.dart';

class GetReceiptUrlUsecase {
  const GetReceiptUrlUsecase(this._repository);
  final PaymentsRepository _repository;

  Future<Either<Failure, String?>> call(String paymentId) =>
      _repository.getReceiptUrl(paymentId);
}
