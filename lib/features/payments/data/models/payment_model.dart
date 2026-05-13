import '../../domain/entities/payment.dart';

class PaymentModel extends Payment {
  const PaymentModel({
    required super.id,
    required super.appointmentId,
    required super.amount,
    required super.status,
    super.checkoutUrl,
    super.txRef,
    super.currency,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) => PaymentModel(
        id: json['paymentId'] as String? ?? json['id'] as String? ?? '',
        appointmentId: json['appointmentId'] as String? ??
            (json['appointmentDetails'] as Map<String, dynamic>?)?['appointmentId'] as String? ?? '',
        amount: (json['totalAmount'] as num? ?? json['amount'] as num? ?? 0).toDouble(),
        status: _parseStatus(json['status'] as String?),
        checkoutUrl: json['checkoutUrl'] as String?,
        txRef: json['txRef'] as String? ?? json['paymentRef'] as String?,
        currency: json['currency'] as String? ?? 'ETB',
      );

  static PaymentStatus _parseStatus(String? s) =>
      switch (s?.toLowerCase()) {
        'processing' => PaymentStatus.processing,
        'completed' => PaymentStatus.completed,
        'failed' => PaymentStatus.failed,
        'refunded' => PaymentStatus.refunded,
        _ => PaymentStatus.pending,
      };
}
