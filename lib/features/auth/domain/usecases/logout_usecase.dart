import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

class LogoutUsecase {
  const LogoutUsecase(this._repository);
  final AuthRepository _repository;

  Future<Either<Failure, void>> call() => _repository.logout();
}
