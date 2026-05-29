import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

class DeleteAccountUsecase {
  const DeleteAccountUsecase(this._repository);
  final AuthRepository _repository;

  Future<Either<Failure, void>> call() => _repository.deleteAccount();
}
