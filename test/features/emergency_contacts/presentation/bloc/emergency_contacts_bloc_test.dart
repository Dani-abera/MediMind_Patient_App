import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medimind/features/emergency_contacts/domain/entities/emergency_contact.dart';
import 'package:medimind/features/emergency_contacts/domain/usecases/add_contact_usecase.dart';
import 'package:medimind/features/emergency_contacts/domain/usecases/delete_contact_usecase.dart';
import 'package:medimind/features/emergency_contacts/domain/usecases/get_contacts_usecase.dart';
import 'package:medimind/features/emergency_contacts/domain/usecases/set_primary_contact_usecase.dart';
import 'package:medimind/features/emergency_contacts/domain/usecases/update_contact_usecase.dart';
import 'package:medimind/features/emergency_contacts/presentation/bloc/emergency_contacts_bloc.dart';
import 'package:medimind/features/emergency_contacts/presentation/bloc/emergency_contacts_event.dart';
import 'package:medimind/features/emergency_contacts/presentation/bloc/emergency_contacts_state.dart';
import 'package:mocktail/mocktail.dart';

class MockGetContactsUsecase extends Mock implements GetContactsUsecase {}
class MockAddContactUsecase extends Mock implements AddContactUsecase {}
class MockUpdateContactUsecase extends Mock implements UpdateContactUsecase {}
class MockDeleteContactUsecase extends Mock implements DeleteContactUsecase {}
class MockSetPrimaryContactUsecase extends Mock
    implements SetPrimaryContactUsecase {}

const _contact = EmergencyContact(
  id: 'c1',
  fullName: 'Jane Doe',
  relationship: 'Spouse',
  phoneNumber: '+1234567890',
);

void main() {
  setUpAll(() {
    registerFallbackValue(_contact);
    registerFallbackValue(const AddContactParams(
        fullName: '', relationship: '', phoneNumber: ''));
  });

  late MockGetContactsUsecase mockGet;
  late MockAddContactUsecase mockAdd;
  late MockUpdateContactUsecase mockUpdate;
  late MockDeleteContactUsecase mockDelete;
  late MockSetPrimaryContactUsecase mockSetPrimary;

  setUp(() {
    mockGet = MockGetContactsUsecase();
    mockAdd = MockAddContactUsecase();
    mockUpdate = MockUpdateContactUsecase();
    mockDelete = MockDeleteContactUsecase();
    mockSetPrimary = MockSetPrimaryContactUsecase();
  });

  EmergencyContactsBloc build() => EmergencyContactsBloc(
        getContacts: mockGet,
        addContact: mockAdd,
        updateContact: mockUpdate,
        deleteContact: mockDelete,
        setPrimary: mockSetPrimary,
      );

  group('EmergencyContactsRequested', () {
    blocTest<EmergencyContactsBloc, EmergencyContactsState>(
      'emits [Loading, Loaded] on success',
      setUp: () => when(() => mockGet())
          .thenAnswer((_) async => const Right([_contact])),
      build: build,
      act: (b) => b.add(const EmergencyContactsRequested()),
      expect: () => [
        const EmergencyContactsLoading(),
        const EmergencyContactsLoaded([_contact]),
      ],
    );
  });

  group('EmergencyContactAdded — max 3 constraint', () {
    final threeContacts = List.generate(
        3,
        (i) => EmergencyContact(
            id: 'c$i',
            fullName: 'Contact $i',
            relationship: 'Friend',
            phoneNumber: '+000$i'));

    blocTest<EmergencyContactsBloc, EmergencyContactsState>(
      'emits Failure when contacts list already has 3',
      build: build,
      seed: () => EmergencyContactsLoaded(threeContacts),
      act: (b) => b.add(const EmergencyContactAdded(
        fullName: 'Extra',
        relationship: 'Other',
        phoneNumber: '+99',
      )),
      expect: () => [
        const EmergencyContactsFailure(
            'Maximum 3 emergency contacts allowed'),
      ],
      verify: (_) => verifyNever(() => mockAdd(any())),
    );

    blocTest<EmergencyContactsBloc, EmergencyContactsState>(
      'adds contact when under limit',
      setUp: () => when(() => mockAdd(any()))
          .thenAnswer((_) async => const Right(_contact)),
      build: build,
      seed: () => const EmergencyContactsLoaded([]),
      act: (b) => b.add(const EmergencyContactAdded(
        fullName: 'Jane',
        relationship: 'Spouse',
        phoneNumber: '+1234',
      )),
      expect: () => [
        const EmergencyContactsLoading(),
        isA<EmergencyContactsActionSuccess>(),
        isA<EmergencyContactsLoaded>(),
      ],
    );
  });

  group('EmergencyContactDeleted', () {
    blocTest<EmergencyContactsBloc, EmergencyContactsState>(
      'removes contact from list on success',
      setUp: () =>
          when(() => mockDelete(any())).thenAnswer((_) async => const Right(null)),
      build: build,
      seed: () => const EmergencyContactsLoaded([_contact]),
      act: (b) => b.add(const EmergencyContactDeleted('c1')),
      expect: () => [
        const EmergencyContactsLoading(),
        isA<EmergencyContactsActionSuccess>(),
        const EmergencyContactsLoaded([]),
      ],
    );
  });
}
