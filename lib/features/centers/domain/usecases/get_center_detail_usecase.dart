import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/center_detail.dart';
import '../repositories/centers_repository.dart';

class GetCenterDetailUsecase {
  const GetCenterDetailUsecase(this._repository);
  final CentersRepository _repository;

  Future<Either<Failure, CenterDetail>> call(String centerId) =>
      _repository.getCenterDetail(centerId);
}
