import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/datasources/video_consultation_remote_datasource.dart';
import '../entities/video_consultation.dart';

abstract class VideoConsultationRepository {
  Future<Either<Failure, VideoConsultation>> getConsultation(String consultationId);
  Future<Either<Failure, JoinResult>> joinConsultation(String consultationId);
  Future<Either<Failure, VideoConsultation>> getConsultationByAppointmentId(String appointmentId);
  Future<Either<Failure, void>> sendMessage(String consultationId, String content);
}
