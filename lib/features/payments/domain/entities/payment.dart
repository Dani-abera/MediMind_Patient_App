import 'package:equatable/equatable.dart';

enum PaymentStatus { pending, processing, completed, failed, refunded }

class Payment extends Equatable {
  const Payment({
    required this.id,
    required this.appointmentId,
    required this.amount,
    required this.status,
    this.checkoutUrl,
    this.txRef,
    this.currency = 'ETB',
    this.patientEmail,
    this.patientPhone,
    this.patientFirstName,
    this.patientLastName,
  });

  final String id;
  final String appointmentId;
  final double amount;
  final PaymentStatus status;
  final String? checkoutUrl;
  final String? txRef;
  final String currency;
  final String? patientEmail;
  final String? patientPhone;
  final String? patientFirstName;
  final String? patientLastName;

  bool get isCompleted => status == PaymentStatus.completed;

  @override
  List<Object?> get props => [id, appointmentId, amount, status];
}
