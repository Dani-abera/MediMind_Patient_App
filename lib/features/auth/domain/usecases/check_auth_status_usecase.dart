import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

class CheckAuthStatusUsecase {
  const CheckAuthStatusUsecase(this._repository);
  final AuthRepository _repository;

  Future<Either<Failure, bool>> call() => _repository.checkAuthStatus();
}
