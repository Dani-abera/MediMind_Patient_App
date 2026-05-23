import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/location_service.dart';
import '../entities/appointment.dart';
import '../entities/health_prediction.dart';
import '../entities/health_record.dart';
import '../entities/healthcare_center.dart';
import '../repositories/home_repository.dart';

class HomeData {
  const HomeData({
    this.upcomingAppointment,
    this.latestHealthRecord,
    this.latestPrediction,
    this.nearbyCenters = const [],
    this.unreadCount = 0,
    this.failedSections = const [],
  });

  final Appointment? upcomingAppointment;
  final HealthRecord? latestHealthRecord;
  final HealthPrediction? latestPrediction;
  final List<HealthcareCenter> nearbyCenters;
  final int unreadCount;
  final List<String> failedSections;

  HomeData copyWith({
    Appointment? upcomingAppointment,
    HealthRecord? latestHealthRecord,
    HealthPrediction? latestPrediction,
    List<HealthcareCenter>? nearbyCenters,
    int? unreadCount,
    List<String>? failedSections,
  }) {
    return HomeData(
      upcomingAppointment:
          upcomingAppointment ?? this.upcomingAppointment,
      latestHealthRecord: latestHealthRecord ?? this.latestHealthRecord,
      latestPrediction: latestPrediction ?? this.latestPrediction,
      nearbyCenters: nearbyCenters ?? this.nearbyCenters,
      unreadCount: unreadCount ?? this.unreadCount,
      failedSections: failedSections ?? this.failedSections,
    );
  }
}

class GetHomeDataUsecase {
  const GetHomeDataUsecase({
    required this.repository,
    required this.locationService,
  });

  final HomeRepository repository;
  final LocationService locationService;

  Future<Either<Failure, HomeData>> call() async {
    try {
      final position = await locationService.getCurrentLocation();

      final results = await Future.wait([
        repository.getUpcomingAppointment(),
        repository.getLatestHealthRecord(),
        repository.getLatestPrediction(),
        repository.getNearbyCenters(
          latitude: position.latitude,
          longitude: position.longitude,
        ),
        repository.getUnreadNotificationCount(),
      ]);

      final failures = <String>[];

      Appointment? appointment;
      HealthRecord? record;
      HealthPrediction? prediction;
      List<HealthcareCenter> centers = [];
      int unreadCount = 0;

      results[0].fold((_) => failures.add('appointments'),
          (v) => appointment = v as Appointment?);
      results[1].fold((_) => failures.add('health_record'),
          (v) => record = v as HealthRecord?);
      results[2].fold((_) => failures.add('prediction'),
          (v) => prediction = v as HealthPrediction?);
      results[3].fold(
        (_) => failures.add('centers'),
        (v) => centers = (v as List).cast<HealthcareCenter>(),
      );
      results[4].fold(
          (_) => failures.add('notifications'), (v) => unreadCount = v as int);

      if (failures.length == 5) {
        return const Left(
          ServerFailure(message: 'Failed to load dashboard data'),
        );
      }

      return Right(HomeData(
        upcomingAppointment: appointment,
        latestHealthRecord: record,
        latestPrediction: prediction,
        nearbyCenters: centers,
        unreadCount: unreadCount,
        failedSections: failures,
      ));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }
}
