import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/video_consultation_repository.dart';

class JoinConsultationUsecase {
  JoinConsultationUsecase(this._repository);
  final VideoConsultationRepository _repository;

  Future<Either<Failure, String>> call(String consultationId) =>
      _repository.joinConsultation(consultationId);
}
