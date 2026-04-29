import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/payment_record.dart';

abstract class PaymentsHistoryRepository {
  Future<Either<Failure, List<PaymentRecord>>> getPaymentHistory(
      {int page, int pageSize});
}
