import 'package:equatable/equatable.dart';
import '../../domain/entities/payment_record.dart';

abstract class PaymentsHistoryState extends Equatable {
  const PaymentsHistoryState();
  @override
  List<Object?> get props => [];
}

class PaymentsHistoryInitial extends PaymentsHistoryState {
  const PaymentsHistoryInitial();
}

class PaymentsHistoryLoading extends PaymentsHistoryState {
  const PaymentsHistoryLoading();
}

class PaymentsHistoryLoaded extends PaymentsHistoryState {
  const PaymentsHistoryLoaded({
    required this.records,
    this.hasMore = false,
    this.isLoadingMore = false,
  });
  final List<PaymentRecord> records;
  final bool hasMore;
  final bool isLoadingMore;

  PaymentsHistoryLoaded copyWith({
    List<PaymentRecord>? records,
    bool? hasMore,
    bool? isLoadingMore,
  }) =>
      PaymentsHistoryLoaded(
        records: records ?? this.records,
        hasMore: hasMore ?? this.hasMore,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      );

  @override
  List<Object?> get props => [records, hasMore, isLoadingMore];
}

class PaymentsHistoryFailure extends PaymentsHistoryState {
  const PaymentsHistoryFailure(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
