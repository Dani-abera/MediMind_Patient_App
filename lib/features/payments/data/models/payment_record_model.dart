import '../../domain/entities/payment_record.dart';

class PaymentRecordModel extends PaymentRecord {
  const PaymentRecordModel({
    required super.id,
    required super.amount,
    required super.currency,
    required super.status,
    required super.createdAt,
    super.appointmentSummary,
    super.doctorName,
    super.receiptUrl,
  });

  factory PaymentRecordModel.fromJson(Map<String, dynamic> json) =>
      PaymentRecordModel(
        id: json['id'] as String? ?? json['_id'] as String? ?? '',
        amount: (json['amount'] as num?)?.toDouble() ?? 0,
        currency: json['currency'] as String? ?? 'ETB',
        status: _parseStatus(json['status'] as String? ?? ''),
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : DateTime.now(),
        appointmentSummary: json['appointmentSummary'] as String?,
        doctorName: json['doctorName'] as String?,
        receiptUrl: json['receiptUrl'] as String?,
      );

  static PaymentStatus _parseStatus(String s) => switch (s.toLowerCase()) {
        'completed' => PaymentStatus.completed,
        'failed' => PaymentStatus.failed,
        'refunded' => PaymentStatus.refunded,
        _ => PaymentStatus.pending,
      };
}
