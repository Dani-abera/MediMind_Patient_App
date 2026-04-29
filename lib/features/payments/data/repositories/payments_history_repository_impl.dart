import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/payment_record.dart';
import '../../domain/repositories/payments_history_repository.dart';
import '../datasources/payments_history_datasource.dart';

class PaymentsHistoryRepositoryImpl implements PaymentsHistoryRepository {
  const PaymentsHistoryRepositoryImpl(this._ds);
  final PaymentsHistoryDataSource _ds;

  @override
  Future<Either<Failure, List<PaymentRecord>>> getPaymentHistory(
      {int page = 1, int pageSize = 20}) async {
    try {
      final records = await _ds.getPaymentHistory(page: page, pageSize: pageSize);
      return Right(records);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
