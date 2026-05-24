import 'package:equatable/equatable.dart';

enum AppointmentStatus { pending, confirmed, completed, cancelled, noShow }

enum AppointmentType { inPerson, video, homeVisit }

enum PaymentStatus { pending, processing, completed, failed, refunded }

class AppointmentDetail extends Equatable {
  const AppointmentDetail({
    required this.id,
    required this.doctorId,
    required this.doctorName,
    required this.doctorSpecialization,
    required this.centerId,
    required this.centerName,
    required this.centerAddress,
    required this.centerPhone,
    required this.appointmentTime,
    required this.status,
    required this.type,
    required this.consultationFee,
    required this.serviceFee,
    required this.totalAmount,
    required this.canCancel,
    required this.canReschedule,
    this.cancellationPolicyHours = 2,
    this.doctorAvatarUrl,
    this.reasonForVisit,
    this.symptoms,
    this.queueNumber,
    this.estimatedWaitMinutes,
    this.paymentId,
    this.paymentStatus,
    this.prescriptionId,
    this.reviewId,
    this.centerLatitude,
    this.centerLongitude,
    this.videoConsultationId,
    this.canInitiateVideoConsultation = false,
    this.videoConsultationStatus,
  });

  final String id;
  final String doctorId;
  final String doctorName;
  final String doctorSpecialization;
  final String centerId;
  final String centerName;
  final String centerAddress;
  final String centerPhone;
  final DateTime appointmentTime;
  final AppointmentStatus status;
  final AppointmentType type;
  final double consultationFee;
  final double serviceFee;
  final double totalAmount;
  final bool canCancel;
  final bool canReschedule;
  final int cancellationPolicyHours;
  final String? doctorAvatarUrl;
  final String? reasonForVisit;
  final String? symptoms;
  final int? queueNumber;
  final int? estimatedWaitMinutes;
  final String? paymentId;
  final PaymentStatus? paymentStatus;
  final String? prescriptionId;
  final String? reviewId;
  final double? centerLatitude;
  final double? centerLongitude;
  final String? videoConsultationId;
  final bool canInitiateVideoConsultation;
  final String? videoConsultationStatus;

  bool get isUpcoming =>
      status == AppointmentStatus.pending ||
      status == AppointmentStatus.confirmed;

  bool get isToday {
    final now = DateTime.now();
    return appointmentTime.year == now.year &&
        appointmentTime.month == now.month &&
        appointmentTime.day == now.day;
  }

  String get statusLabel => switch (status) {
        AppointmentStatus.pending => 'Pending',
        AppointmentStatus.confirmed => 'Confirmed',
        AppointmentStatus.completed => 'Completed',
        AppointmentStatus.cancelled => 'Cancelled',
        AppointmentStatus.noShow => 'No Show',
      };

  @override
  List<Object?> get props => [
        id, doctorId, centerId, appointmentTime, status, paymentStatus,
        videoConsultationId, canInitiateVideoConsultation, videoConsultationStatus,
      ];
}
