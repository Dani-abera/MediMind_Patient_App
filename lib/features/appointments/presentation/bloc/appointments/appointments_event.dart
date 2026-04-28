import 'package:equatable/equatable.dart';

abstract class AppointmentsEvent extends Equatable {
  const AppointmentsEvent();
  @override
  List<Object?> get props => [];
}

class AppointmentsRequested extends AppointmentsEvent {
  const AppointmentsRequested();
}

class AppointmentsRefreshed extends AppointmentsEvent {
  const AppointmentsRefreshed();
}

class PastAppointmentsLoadMore extends AppointmentsEvent {
  const PastAppointmentsLoadMore();
}

class AppointmentCancelled extends AppointmentsEvent {
  const AppointmentCancelled(this.appointmentId);
  final String appointmentId;
  @override
  List<Object?> get props => [appointmentId];
}
