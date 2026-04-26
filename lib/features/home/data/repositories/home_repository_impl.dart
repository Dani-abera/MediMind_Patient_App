import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/entities/health_prediction.dart';
import '../../domain/entities/health_record.dart';
import '../../domain/entities/healthcare_center.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_datasource.dart';

class HomeRepositoryImpl implements HomeRepository {
  const HomeRepositoryImpl(this._remote);
  final HomeRemoteDataSource _remote;

  @override
  Future<Either<Failure, Appointment?>> getUpcomingAppointment() =>
      _wrap(() => _remote.getUpcomingAppointment());

  @override
  Future<Either<Failure, HealthRecord?>> getLatestHealthRecord() =>
      _wrap(() => _remote.getLatestHealthRecord());

  @override
  Future<Either<Failure, HealthPrediction?>> getLatestPrediction() =>
      _wrap(() => _remote.getLatestPrediction());

  @override
  Future<Either<Failure, List<HealthcareCenter>>> getNearbyCenters({
    required double latitude,
    required double longitude,
    double radiusKm = 10,
  }) =>
      _wrap(() => _remote.getNearbyCenters(
            latitude: latitude,
            longitude: longitude,
            radiusKm: radiusKm,
          ));

  @override
  Future<Either<Failure, int>> getUnreadNotificationCount() =>
      _wrap(() => _remote.getUnreadNotificationCount());

  Future<Either<Failure, T>> _wrap<T>(Future<T> Function() call) async {
    try {
      return Right(await call());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on UnauthorizedException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }
}
