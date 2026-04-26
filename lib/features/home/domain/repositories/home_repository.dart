import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/appointment.dart';
import '../entities/health_prediction.dart';
import '../entities/health_record.dart';
import '../entities/healthcare_center.dart';

abstract class HomeRepository {
  Future<Either<Failure, Appointment?>> getUpcomingAppointment();
  Future<Either<Failure, HealthRecord?>> getLatestHealthRecord();
  Future<Either<Failure, HealthPrediction?>> getLatestPrediction();
  Future<Either<Failure, List<HealthcareCenter>>> getNearbyCenters({
    required double latitude,
    required double longitude,
    double radiusKm = 10,
  });
  Future<Either<Failure, int>> getUnreadNotificationCount();
}
