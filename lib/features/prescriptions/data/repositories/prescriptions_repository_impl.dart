import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/prescription.dart';
import '../../domain/repositories/prescriptions_repository.dart';
import '../datasources/prescriptions_remote_datasource.dart';

class PrescriptionsRepositoryImpl implements PrescriptionsRepository {
  PrescriptionsRepositoryImpl(this._dataSource);
  final PrescriptionsRemoteDataSource _dataSource;

  @override
  Future<Either<Failure, List<Prescription>>> getPrescriptions({int page = 1, int pageSize = 20}) async {
    try { return Right(await _dataSource.getPrescriptions(page: page, pageSize: pageSize)); }
    on ServerException catch (e) { return Left(ServerFailure(message: e.message)); }
  }

  @override
  Future<Either<Failure, Prescription>> getPrescription(String id) async {
    try { return Right(await _dataSource.getPrescription(id)); }
    on ServerException catch (e) { return Left(ServerFailure(message: e.message)); }
  }

  @override
  Future<Either<Failure, String>> getPrescriptionPdfUrl(String id) async {
    try { return Right(await _dataSource.getPrescriptionPdfUrl(id)); }
    on ServerException catch (e) { return Left(ServerFailure(message: e.message)); }
  }

  @override
  Future<Either<Failure, List<Prescription>>> getPrescriptionsByAppointment(String appointmentId) async {
    try { return Right(await _dataSource.getPrescriptions()); }
    on ServerException catch (e) { return Left(ServerFailure(message: e.message)); }
  }
}
