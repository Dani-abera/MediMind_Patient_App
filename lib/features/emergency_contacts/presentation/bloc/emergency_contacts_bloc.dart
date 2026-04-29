import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/emergency_contact.dart';
import '../../domain/usecases/add_contact_usecase.dart';
import '../../domain/usecases/delete_contact_usecase.dart';
import '../../domain/usecases/get_contacts_usecase.dart';
import '../../domain/usecases/set_primary_contact_usecase.dart';
import '../../domain/usecases/update_contact_usecase.dart';
import 'emergency_contacts_event.dart';
import 'emergency_contacts_state.dart';

class EmergencyContactsBloc
    extends Bloc<EmergencyContactsEvent, EmergencyContactsState> {
  EmergencyContactsBloc({
    required this.getContacts,
    required this.addContact,
    required this.updateContact,
    required this.deleteContact,
    required this.setPrimary,
  }) : super(const EmergencyContactsInitial()) {
    on<EmergencyContactsRequested>(_onRequested);
    on<EmergencyContactAdded>(_onAdded);
    on<EmergencyContactUpdated>(_onUpdated);
    on<EmergencyContactDeleted>(_onDeleted);
    on<EmergencyContactSetPrimary>(_onSetPrimary);
  }

  final GetContactsUsecase getContacts;
  final AddContactUsecase addContact;
  final UpdateContactUsecase updateContact;
  final DeleteContactUsecase deleteContact;
  final SetPrimaryContactUsecase setPrimary;

  Future<void> _onRequested(
      EmergencyContactsRequested event, Emitter<EmergencyContactsState> emit) async {
    emit(const EmergencyContactsLoading());
    final result = await getContacts();
    result.fold(
      (f) => emit(EmergencyContactsFailure(f.message)),
      (list) => emit(EmergencyContactsLoaded(list)),
    );
  }

  Future<void> _onAdded(
      EmergencyContactAdded event, Emitter<EmergencyContactsState> emit) async {
    final current = state;
    final currentList =
        current is EmergencyContactsLoaded ? current.contacts : <EmergencyContact>[];
    if (currentList.length >= 3) {
      emit(const EmergencyContactsFailure('Maximum 3 emergency contacts allowed'));
      return;
    }
    emit(const EmergencyContactsLoading());
    final result = await addContact(AddContactParams(
      fullName: event.fullName,
      relationship: event.relationship,
      phoneNumber: event.phoneNumber,
      isPrimary: event.isPrimary,
    ));
    result.fold(
      (f) => emit(EmergencyContactsFailure(f.message)),
      (contact) {
        final updated = [...currentList, contact];
        emit(EmergencyContactsActionSuccess(
            contacts: updated, message: 'Contact added'));
        emit(EmergencyContactsLoaded(updated));
      },
    );
  }

  Future<void> _onUpdated(
      EmergencyContactUpdated event, Emitter<EmergencyContactsState> emit) async {
    emit(const EmergencyContactsLoading());
    final result = await updateContact(event.contact);
    result.fold(
      (f) => emit(EmergencyContactsFailure(f.message)),
      (_) => add(const EmergencyContactsRequested()),
    );
  }

  Future<void> _onDeleted(
      EmergencyContactDeleted event, Emitter<EmergencyContactsState> emit) async {
    final current = state;
    final currentList =
        current is EmergencyContactsLoaded ? current.contacts : <EmergencyContact>[];
    emit(const EmergencyContactsLoading());
    final result = await deleteContact(event.id);
    result.fold(
      (f) => emit(EmergencyContactsFailure(f.message)),
      (_) {
        final updated =
            currentList.where((c) => c.id != event.id).toList();
        emit(EmergencyContactsActionSuccess(
            contacts: updated, message: 'Contact deleted'));
        emit(EmergencyContactsLoaded(updated));
      },
    );
  }

  Future<void> _onSetPrimary(
      EmergencyContactSetPrimary event, Emitter<EmergencyContactsState> emit) async {
    final result = await setPrimary(event.id);
    result.fold(
      (f) => emit(EmergencyContactsFailure(f.message)),
      (_) => add(const EmergencyContactsRequested()),
    );
  }
}
