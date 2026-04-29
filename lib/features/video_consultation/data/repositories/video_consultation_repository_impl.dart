import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/video_consultation.dart';
import '../../domain/repositories/video_consultation_repository.dart';
import '../datasources/video_consultation_remote_datasource.dart';

class VideoConsultationRepositoryImpl implements VideoConsultationRepository {
  VideoConsultationRepositoryImpl(this._dataSource);
  final VideoConsultationRemoteDataSource _dataSource;

  @override
  Future<Either<Failure, VideoConsultation>> getConsultation(
      String consultationId) async {
    try {
      return Right(await _dataSource.getConsultation(consultationId));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, String>> joinConsultation(
      String consultationId) async {
    try {
      return Right(await _dataSource.joinConsultation(consultationId));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }
}
