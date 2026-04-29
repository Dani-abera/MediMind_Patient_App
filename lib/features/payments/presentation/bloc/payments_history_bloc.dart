import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_payment_history_usecase.dart';
import 'payments_history_event.dart';
import 'payments_history_state.dart';

class PaymentsHistoryBloc
    extends Bloc<PaymentsHistoryEvent, PaymentsHistoryState> {
  PaymentsHistoryBloc({required GetPaymentHistoryUsecase getHistory})
      : _getHistory = getHistory,
        super(const PaymentsHistoryInitial()) {
    on<PaymentsHistoryRequested>(_onRequested, transformer: droppable());
    on<PaymentsHistoryRefreshed>(_onRefreshed, transformer: droppable());
    on<PaymentsHistoryNextPageRequested>(_onNextPage,
        transformer: droppable());
  }

  final GetPaymentHistoryUsecase _getHistory;
  int _page = 1;
  static const _pageSize = 20;

  Future<void> _onRequested(
    PaymentsHistoryRequested event,
    Emitter<PaymentsHistoryState> emit,
  ) async {
    emit(const PaymentsHistoryLoading());
    _page = 1;
    final result = await _getHistory(page: _page, pageSize: _pageSize);
    result.fold(
      (f) => emit(PaymentsHistoryFailure(f.message)),
      (records) => emit(PaymentsHistoryLoaded(
        records: records,
        hasMore: records.length >= _pageSize,
      )),
    );
  }

  Future<void> _onRefreshed(
    PaymentsHistoryRefreshed event,
    Emitter<PaymentsHistoryState> emit,
  ) async {
    emit(const PaymentsHistoryLoading());
    _page = 1;
    final result = await _getHistory(page: _page, pageSize: _pageSize);
    result.fold(
      (f) => emit(PaymentsHistoryFailure(f.message)),
      (records) => emit(PaymentsHistoryLoaded(
        records: records,
        hasMore: records.length >= _pageSize,
      )),
    );
  }

  Future<void> _onNextPage(
    PaymentsHistoryNextPageRequested event,
    Emitter<PaymentsHistoryState> emit,
  ) async {
    final current = state;
    if (current is! PaymentsHistoryLoaded || !current.hasMore) return;
    emit(current.copyWith(isLoadingMore: true));
    _page++;
    final result = await _getHistory(page: _page, pageSize: _pageSize);
    result.fold(
      (f) {
        _page--;
        emit(current.copyWith(isLoadingMore: false));
      },
      (newRecords) => emit(PaymentsHistoryLoaded(
        records: [...current.records, ...newRecords],
        hasMore: newRecords.length >= _pageSize,
      )),
    );
  }
}
