import 'package:equatable/equatable.dart';
import '../../domain/entities/emergency_contact.dart';

abstract class EmergencyContactsEvent extends Equatable {
  const EmergencyContactsEvent();
  @override List<Object?> get props => [];
}

class EmergencyContactsRequested extends EmergencyContactsEvent {
  const EmergencyContactsRequested();
}

class EmergencyContactAdded extends EmergencyContactsEvent {
  const EmergencyContactAdded({
    required this.fullName,
    required this.relationship,
    required this.phoneNumber,
    this.isPrimary = false,
  });
  final String fullName;
  final String relationship;
  final String phoneNumber;
  final bool isPrimary;
  @override List<Object?> get props => [fullName, relationship, phoneNumber, isPrimary];
}

class EmergencyContactUpdated extends EmergencyContactsEvent {
  const EmergencyContactUpdated(this.contact);
  final EmergencyContact contact;
  @override List<Object?> get props => [contact];
}

class EmergencyContactDeleted extends EmergencyContactsEvent {
  const EmergencyContactDeleted(this.id);
  final String id;
  @override List<Object?> get props => [id];
}

class EmergencyContactSetPrimary extends EmergencyContactsEvent {
  const EmergencyContactSetPrimary(this.id);
  final String id;
  @override List<Object?> get props => [id];
}
