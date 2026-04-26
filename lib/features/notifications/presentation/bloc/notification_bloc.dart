import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/notification_remote_datasource.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc
    extends Bloc<NotificationEvent, NotificationState> {
  NotificationBloc({required NotificationRemoteDataSource dataSource})
      : _dataSource = dataSource,
        super(const NotificationState()) {
    on<NotificationPollingStarted>(_onPollingStarted);
    on<NotificationPollingTicked>(_onTicked);
    on<NotificationFcmReceived>(_onFcmReceived);
    on<NotificationPollingPaused>(_onPaused);
  }

  final NotificationRemoteDataSource _dataSource;
  Timer? _timer;

  Future<void> _onPollingStarted(
    NotificationPollingStarted event,
    Emitter<NotificationState> emit,
  ) async {
    await _fetch(emit);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 60), (_) {
      add(const NotificationPollingTicked());
    });
  }

  Future<void> _onTicked(
    NotificationPollingTicked event,
    Emitter<NotificationState> emit,
  ) async {
    await _fetch(emit);
  }

  void _onFcmReceived(
    NotificationFcmReceived event,
    Emitter<NotificationState> emit,
  ) {
    emit(state.copyWith(unreadCount: state.unreadCount + 1));
  }

  void _onPaused(
    NotificationPollingPaused event,
    Emitter<NotificationState> emit,
  ) {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _fetch(Emitter<NotificationState> emit) async {
    try {
      final count = await _dataSource.getUnreadCount();
      emit(state.copyWith(unreadCount: count));
    } catch (_) {
      // Silently ignore polling errors
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
