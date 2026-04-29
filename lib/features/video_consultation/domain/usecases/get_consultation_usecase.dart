import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/video_consultation.dart';
import '../repositories/video_consultation_repository.dart';

class GetConsultationUsecase {
  GetConsultationUsecase(this._repository);
  final VideoConsultationRepository _repository;

  Future<Either<Failure, VideoConsultation>> call(String consultationId) =>
      _repository.getConsultation(consultationId);
}
