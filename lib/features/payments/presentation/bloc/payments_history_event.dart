import 'package:equatable/equatable.dart';

abstract class PaymentsHistoryEvent extends Equatable {
  const PaymentsHistoryEvent();
  @override
  List<Object?> get props => [];
}

class PaymentsHistoryRequested extends PaymentsHistoryEvent {
  const PaymentsHistoryRequested();
}

class PaymentsHistoryRefreshed extends PaymentsHistoryEvent {
  const PaymentsHistoryRefreshed();
}

class PaymentsHistoryNextPageRequested extends PaymentsHistoryEvent {
  const PaymentsHistoryNextPageRequested();
}
