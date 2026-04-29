import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/video_consultation.dart';

abstract class VideoConsultationRepository {
  Future<Either<Failure, VideoConsultation>> getConsultation(String consultationId);
  Future<Either<Failure, String>> joinConsultation(String consultationId);
}
