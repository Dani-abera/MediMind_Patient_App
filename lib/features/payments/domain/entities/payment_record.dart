import 'package:equatable/equatable.dart';

enum PaymentStatus { pending, completed, failed, refunded }

class PaymentRecord extends Equatable {
  const PaymentRecord({
    required this.id,
    required this.amount,
    required this.currency,
    required this.status,
    required this.createdAt,
    this.appointmentSummary,
    this.doctorName,
    this.receiptUrl,
  });

  final String id;
  final double amount;
  final String currency;
  final PaymentStatus status;
  final DateTime createdAt;
  final String? appointmentSummary;
  final String? doctorName;
  final String? receiptUrl;

  @override
  List<Object?> get props => [
        id, amount, currency, status, createdAt,
        appointmentSummary, doctorName, receiptUrl,
      ];
}
