import 'package:equatable/equatable.dart';
import '../../domain/entities/emergency_contact.dart';

abstract class EmergencyContactsState extends Equatable {
  const EmergencyContactsState();
  @override List<Object?> get props => [];
}

class EmergencyContactsInitial extends EmergencyContactsState {
  const EmergencyContactsInitial();
}

class EmergencyContactsLoading extends EmergencyContactsState {
  const EmergencyContactsLoading();
}

class EmergencyContactsLoaded extends EmergencyContactsState {
  const EmergencyContactsLoaded(this.contacts);
  final List<EmergencyContact> contacts;
  @override List<Object?> get props => [contacts];
}

class EmergencyContactsActionSuccess extends EmergencyContactsState {
  const EmergencyContactsActionSuccess({
    required this.contacts,
    required this.message,
  });
  final List<EmergencyContact> contacts;
  final String message;
  @override List<Object?> get props => [contacts, message];
}

class EmergencyContactsFailure extends EmergencyContactsState {
  const EmergencyContactsFailure(this.message);
  final String message;
  @override List<Object?> get props => [message];
}
