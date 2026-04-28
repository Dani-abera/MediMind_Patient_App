import '../../domain/entities/appointment_detail.dart';

class AppointmentDetailModel extends AppointmentDetail {
  const AppointmentDetailModel({
    required super.id,
    required super.doctorId,
    required super.doctorName,
    required super.doctorSpecialization,
    required super.centerId,
    required super.centerName,
    required super.centerAddress,
    required super.centerPhone,
    required super.appointmentTime,
    required super.status,
    required super.type,
    required super.consultationFee,
    required super.serviceFee,
    required super.totalAmount,
    required super.canCancel,
    required super.canReschedule,
    super.doctorAvatarUrl,
    super.reasonForVisit,
    super.symptoms,
    super.queueNumber,
    super.estimatedWaitMinutes,
    super.paymentId,
    super.paymentStatus,
    super.prescriptionId,
    super.reviewId,
    super.centerLatitude,
    super.centerLongitude,
  });

  factory AppointmentDetailModel.fromJson(Map<String, dynamic> json) {
    return AppointmentDetailModel(
      id: json['id'] as String,
      doctorId: json['doctorId'] as String,
      doctorName: json['doctorName'] as String,
      doctorSpecialization: json['doctorSpecialization'] as String? ?? '',
      centerId: json['centerId'] as String,
      centerName: json['centerName'] as String,
      centerAddress: json['centerAddress'] as String? ?? '',
      centerPhone: json['centerPhone'] as String? ?? '',
      appointmentTime:
          DateTime.parse(json['appointmentTime'] as String),
      status: _parseStatus(json['status'] as String?),
      type: _parseType(json['type'] as String?),
      consultationFee:
          (json['consultationFee'] as num?)?.toDouble() ?? 0.0,
      serviceFee: (json['serviceFee'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      canCancel: json['canCancel'] as bool? ?? false,
      canReschedule: json['canReschedule'] as bool? ?? false,
      doctorAvatarUrl: json['doctorAvatarUrl'] as String?,
      reasonForVisit: json['reasonForVisit'] as String?,
      symptoms: json['symptoms'] as String?,
      queueNumber: (json['queueNumber'] as num?)?.toInt(),
      estimatedWaitMinutes:
          (json['estimatedWaitMinutes'] as num?)?.toInt(),
      paymentId: json['paymentId'] as String?,
      paymentStatus: _parsePaymentStatus(json['paymentStatus'] as String?),
      prescriptionId: json['prescriptionId'] as String?,
      reviewId: json['reviewId'] as String?,
      centerLatitude: (json['centerLatitude'] as num?)?.toDouble(),
      centerLongitude: (json['centerLongitude'] as num?)?.toDouble(),
    );
  }

  static AppointmentStatus _parseStatus(String? s) =>
      switch (s?.toLowerCase()) {
        'confirmed' => AppointmentStatus.confirmed,
        'completed' => AppointmentStatus.completed,
        'cancelled' => AppointmentStatus.cancelled,
        'noshow' => AppointmentStatus.noShow,
        _ => AppointmentStatus.pending,
      };

  static AppointmentType _parseType(String? s) =>
      switch (s?.toLowerCase()) {
        'video' => AppointmentType.video,
        'homevisit' => AppointmentType.homeVisit,
        _ => AppointmentType.inPerson,
      };

  static PaymentStatus? _parsePaymentStatus(String? s) =>
      switch (s?.toLowerCase()) {
        'processing' => PaymentStatus.processing,
        'completed' => PaymentStatus.completed,
        'failed' => PaymentStatus.failed,
        'refunded' => PaymentStatus.refunded,
        'pending' => PaymentStatus.pending,
        _ => null,
      };
}
