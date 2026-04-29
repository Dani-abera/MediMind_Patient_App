import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/prescription.dart';

abstract class PrescriptionsRepository {
  Future<Either<Failure, List<Prescription>>> getPrescriptions({int page = 1, int pageSize = 20});
  Future<Either<Failure, Prescription>> getPrescription(String id);
  Future<Either<Failure, String>> getPrescriptionPdfUrl(String id);
  Future<Either<Failure, List<Prescription>>> getPrescriptionsByAppointment(String appointmentId);
}
