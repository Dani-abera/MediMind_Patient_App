import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../appointments/domain/entities/time_slot.dart';
import '../../domain/entities/doctor.dart';
import '../../domain/repositories/doctors_repository.dart';
import '../datasources/doctors_remote_datasource.dart';

class DoctorsRepositoryImpl implements DoctorsRepository {
  const DoctorsRepositoryImpl(this._remoteDataSource);
  final DoctorsRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, List<Doctor>>> getCenterDoctors(
    String centerId, {
    String? specialization,
  }) =>
      _wrap(() => _remoteDataSource.getCenterDoctors(
            centerId,
            specialization: specialization,
          ));

  @override
  Future<Either<Failure, List<Doctor>>> getDoctors({
    String? centerId,
    String? specialization,
    String? name,
  }) =>
      _wrap(() => _remoteDataSource.getDoctors(
            centerId: centerId,
            specialization: specialization,
            name: name,
          ));

  @override
  Future<Either<Failure, Doctor>> getDoctorDetail(String doctorId, {String? centerId}) =>
      _wrapSingle(() => _remoteDataSource.getDoctorDetail(doctorId, centerId: centerId));

  @override
  Future<Either<Failure, List<TimeSlot>>> getDoctorAvailability({
    required String doctorId,
    required String centerId,
    required DateTime date,
  }) =>
      _wrap(() => _remoteDataSource.getDoctorAvailability(
            doctorId: doctorId,
            centerId: centerId,
            date: date,
          ));

  @override
  Future<Either<Failure, List<DateTime>>> getDoctorAvailableDates({
    required String doctorId,
    required String centerId,
    int daysAhead = 30,
  }) =>
      _wrap(() => _remoteDataSource.getDoctorAvailableDates(
            doctorId: doctorId,
            centerId: centerId,
            daysAhead: daysAhead,
          ));

  Future<Either<Failure, List<T>>> _wrap<T>(
    Future<List<T>> Function() fn,
  ) async {
    try {
      return Right(await fn());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, T>> _wrapSingle<T>(
    Future<T> Function() fn,
  ) async {
    try {
      return Right(await fn());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }
}
