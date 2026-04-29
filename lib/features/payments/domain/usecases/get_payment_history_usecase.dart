import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/payment_record.dart';
import '../repositories/payments_history_repository.dart';

class GetPaymentHistoryUsecase {
  const GetPaymentHistoryUsecase(this._repo);
  final PaymentsHistoryRepository _repo;

  Future<Either<Failure, List<PaymentRecord>>> call(
          {int page = 1, int pageSize = 20}) =>
      _repo.getPaymentHistory(page: page, pageSize: pageSize);
}
