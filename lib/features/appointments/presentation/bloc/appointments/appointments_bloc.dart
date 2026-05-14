import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/cancel_appointment_usecase.dart';
import '../../../domain/usecases/get_appointment_detail_usecase.dart';
import '../../../domain/usecases/get_past_appointments_usecase.dart';
import '../../../domain/usecases/get_upcoming_appointments_usecase.dart';
import 'appointments_event.dart';
import 'appointments_state.dart';

class AppointmentsBloc extends Bloc<AppointmentsEvent, AppointmentsState> {
  AppointmentsBloc({
    required GetUpcomingAppointmentsUsecase getUpcoming,
    required GetAppointmentDetailUsecase getDetail,
    required GetPastAppointmentsUsecase getPast,
    required CancelAppointmentUsecase cancelAppointment,
  })  : _getUpcoming = getUpcoming,
        _getPast = getPast,
        _cancelAppointment = cancelAppointment,
        super(const AppointmentsInitial()) {
    on<AppointmentsRequested>(_onRequested, transformer: droppable());
    on<AppointmentsRefreshed>(_onRefreshed, transformer: droppable());
    on<PastAppointmentsLoadMore>(_onLoadMore, transformer: droppable());
    on<AppointmentCancelled>(_onCancelled);
  }

  final GetUpcomingAppointmentsUsecase _getUpcoming;
  final GetPastAppointmentsUsecase _getPast;
  final CancelAppointmentUsecase _cancelAppointment;

  Future<void> _onRequested(
    AppointmentsRequested event,
    Emitter<AppointmentsState> emit,
  ) async {
    emit(const AppointmentsLoading());
    final upcomingResult = await _getUpcoming();
    final pastResult = await _getPast(page: 1);
    upcomingResult.fold(
      (failure) => emit(AppointmentsError(failure.message)),
      (upcoming) => pastResult.fold(
        (_) => emit(AppointmentsLoaded(
          upcoming: upcoming,
          past: const [],
          hasMorePast: false,
        )),
        (past) => emit(AppointmentsLoaded(
          upcoming: upcoming,
          past: past,
          hasMorePast: past.length == 20,
        )),
      ),
    );
  }

  Future<void> _onRefreshed(
    AppointmentsRefreshed event,
    Emitter<AppointmentsState> emit,
  ) async {
    final result = await _getUpcoming();
    result.fold(
      (failure) => emit(AppointmentsError(failure.message)),
      (upcoming) => emit(AppointmentsLoaded(
        upcoming: upcoming,
        past: state is AppointmentsLoaded
            ? (state as AppointmentsLoaded).past
            : const [],
        hasMorePast: false,
      )),
    );
  }

  Future<void> _onLoadMore(
    PastAppointmentsLoadMore event,
    Emitter<AppointmentsState> emit,
  ) async {
    final current = state;
    if (current is! AppointmentsLoaded || !current.hasMorePast) return;
    final nextPage = (current.past.length ~/ 20) + 1;
    final result = await _getPast(page: nextPage);
    result.fold(
      (_) => null,
      (more) => emit(current.copyWith(
        past: [...current.past, ...more],
        hasMorePast: more.length == 20,
      )),
    );
  }

  Future<void> _onCancelled(
    AppointmentCancelled event,
    Emitter<AppointmentsState> emit,
  ) async {
    final current = state;
    if (current is! AppointmentsLoaded) return;

    emit(current.copyWith(cancellingId: event.appointmentId));
    final result = await _cancelAppointment(event.appointmentId);
    result.fold(
      (failure) => emit(current.copyWith(clearCancelling: true)),
      (_) => emit(current.copyWith(
        upcoming: current.upcoming
            .where((a) => a.id != event.appointmentId)
            .toList(),
        clearCancelling: true,
      )),
    );
  }
}
