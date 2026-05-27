import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/datasources/video_consultation_remote_datasource.dart';
import '../repositories/video_consultation_repository.dart';

class JoinConsultationUsecase {
  JoinConsultationUsecase(this._repository);
  final VideoConsultationRepository _repository;

  Future<Either<Failure, JoinResult>> call(String consultationId) =>
      _repository.joinConsultation(consultationId);
}
