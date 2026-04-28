import 'package:equatable/equatable.dart';
import '../../../domain/entities/appointment_detail.dart';

abstract class AppointmentsState extends Equatable {
  const AppointmentsState();
  @override
  List<Object?> get props => [];
}

class AppointmentsInitial extends AppointmentsState {
  const AppointmentsInitial();
}

class AppointmentsLoading extends AppointmentsState {
  const AppointmentsLoading();
}

class AppointmentsLoaded extends AppointmentsState {
  const AppointmentsLoaded({
    required this.upcoming,
    required this.past,
    this.hasMorePast = false,
    this.cancellingId,
  });

  final List<AppointmentDetail> upcoming;
  final List<AppointmentDetail> past;
  final bool hasMorePast;
  final String? cancellingId;

  AppointmentsLoaded copyWith({
    List<AppointmentDetail>? upcoming,
    List<AppointmentDetail>? past,
    bool? hasMorePast,
    String? cancellingId,
    bool clearCancelling = false,
  }) =>
      AppointmentsLoaded(
        upcoming: upcoming ?? this.upcoming,
        past: past ?? this.past,
        hasMorePast: hasMorePast ?? this.hasMorePast,
        cancellingId: clearCancelling ? null : cancellingId ?? this.cancellingId,
      );

  @override
  List<Object?> get props => [upcoming, past, hasMorePast, cancellingId];
}

class AppointmentsError extends AppointmentsState {
  const AppointmentsError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
