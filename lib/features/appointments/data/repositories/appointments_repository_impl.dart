import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/appointment_detail.dart';
import '../../domain/repositories/appointments_repository.dart';
import '../datasources/appointments_remote_datasource.dart';

class AppointmentsRepositoryImpl implements AppointmentsRepository {
  const AppointmentsRepositoryImpl(this._remoteDataSource);
  final AppointmentsRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, AppointmentDetail>> createAppointment({
    required String doctorId,
    required String centerId,
    required DateTime appointmentTime,
    required String slotId,
    String? reasonForVisit,
    String? symptoms,
  }) =>
      _wrap(() => _remoteDataSource.createAppointment(
            doctorId: doctorId,
            centerId: centerId,
            appointmentTime: appointmentTime,
            slotId: slotId,
            reasonForVisit: reasonForVisit,
            symptoms: symptoms,
          ));

  @override
  Future<Either<Failure, List<AppointmentDetail>>>
      getUpcomingAppointments() =>
          _wrapList(() => _remoteDataSource.getUpcomingAppointments());

  @override
  Future<Either<Failure, List<AppointmentDetail>>> getPastAppointments({
    int page = 1,
    int pageSize = 20,
  }) =>
      _wrapList(() => _remoteDataSource.getPastAppointments(
            page: page,
            pageSize: pageSize,
          ));

  @override
  Future<Either<Failure, AppointmentDetail>> getAppointmentDetail(
          String appointmentId) =>
      _wrap(() => _remoteDataSource.getAppointmentDetail(appointmentId));

  @override
  Future<Either<Failure, void>> cancelAppointment(
      String appointmentId) async {
    try {
      await _remoteDataSource.cancelAppointment(appointmentId);
      return const Right(null);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, T>> _wrap<T>(Future<T> Function() fn) async {
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

  Future<Either<Failure, List<T>>> _wrapList<T>(
      Future<List<T>> Function() fn) async {
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
