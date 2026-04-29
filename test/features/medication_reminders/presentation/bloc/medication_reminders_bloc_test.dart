import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medimind/core/error/failures.dart';
import 'package:medimind/core/services/notification_service.dart';
import 'package:medimind/features/medication_reminders/domain/entities/medication_reminder.dart';
import 'package:medimind/features/medication_reminders/domain/usecases/add_reminder_usecase.dart';
import 'package:medimind/features/medication_reminders/domain/usecases/delete_reminder_usecase.dart';
import 'package:medimind/features/medication_reminders/domain/usecases/get_reminders_usecase.dart';
import 'package:medimind/features/medication_reminders/domain/usecases/toggle_reminder_usecase.dart';
import 'package:medimind/features/medication_reminders/presentation/bloc/medication_reminders_bloc.dart';
import 'package:medimind/features/medication_reminders/presentation/bloc/medication_reminders_event.dart';
import 'package:medimind/features/medication_reminders/presentation/bloc/medication_reminders_state.dart';
import 'package:mocktail/mocktail.dart';

class MockGetRemindersUsecase extends Mock implements GetRemindersUsecase {}
class MockAddReminderUsecase extends Mock implements AddReminderUsecase {}
class MockDeleteReminderUsecase extends Mock implements DeleteReminderUsecase {}
class MockToggleReminderUsecase extends Mock implements ToggleReminderUsecase {}
class MockNotificationService extends Mock implements NotificationService {}

final _activeReminder = MedicationReminder(
  id: 'r1',
  medicationName: 'Metformin',
  dosage: '500mg',
  frequency: ReminderFrequency.twice,
  times: const ['08:00', '20:00'],
  isActive: true,
  startDate: DateTime(2025, 1, 1),
  notificationIds: const [1001, 1002],
);

final _inactiveReminder = _activeReminder.copyWith(isActive: false);

void main() {
  late MockGetRemindersUsecase mockGet;
  late MockAddReminderUsecase mockAdd;
  late MockDeleteReminderUsecase mockDelete;
  late MockToggleReminderUsecase mockToggle;
  late MockNotificationService mockNotifications;

  setUp(() {
    mockGet = MockGetRemindersUsecase();
    mockAdd = MockAddReminderUsecase();
    mockDelete = MockDeleteReminderUsecase();
    mockToggle = MockToggleReminderUsecase();
    mockNotifications = MockNotificationService();

    registerFallbackValue(
        AddReminderParams(
          medicationName: '',
          dosage: '',
          frequency: ReminderFrequency.once,
          times: const [],
          startDate: DateTime(2025),
        ));
  });

  MedicationRemindersBloc build() => MedicationRemindersBloc(
        getReminders: mockGet,
        addReminder: mockAdd,
        deleteReminder: mockDelete,
        toggleReminder: mockToggle,
        notificationService: mockNotifications,
      );

  group('MedicationRemindersRequested', () {
    blocTest<MedicationRemindersBloc, MedicationRemindersState>(
      'emits Loaded with reminders on success',
      build: build,
      setUp: () {
        when(() => mockGet()).thenAnswer(
            (_) async => Right([_activeReminder]));
      },
      act: (bloc) => bloc.add(const MedicationRemindersRequested()),
      expect: () => [
        const MedicationRemindersLoading(),
        isA<MedicationRemindersLoaded>()
            .having((s) => s.reminders.length, 'count', 1),
      ],
    );

    blocTest<MedicationRemindersBloc, MedicationRemindersState>(
      'emits Failure on error',
      build: build,
      setUp: () {
        when(() => mockGet()).thenAnswer((_) async =>
            const Left(ServerFailure(message: 'Network error')));
      },
      act: (bloc) => bloc.add(const MedicationRemindersRequested()),
      expect: () => [
        const MedicationRemindersLoading(),
        const MedicationRemindersFailure('Network error'),
      ],
    );
  });

  group('MedicationReminderToggled', () {
    blocTest<MedicationRemindersBloc, MedicationRemindersState>(
      'cancels notifications when toggling off',
      build: build,
      setUp: () {
        // Set up initial state with active reminder
        when(() => mockGet()).thenAnswer(
            (_) async => Right([_activeReminder]));
        when(() => mockToggle('r1')).thenAnswer(
            (_) async => Right(_inactiveReminder));
        when(() => mockNotifications.cancelReminder(any()))
            .thenAnswer((_) async {});
      },
      seed: () => MedicationRemindersLoaded([_activeReminder]),
      act: (bloc) => bloc.add(const MedicationReminderToggled('r1')),
      verify: (_) {
        // 2 notification IDs for a twice-daily reminder
        verify(() => mockNotifications.cancelReminder(any())).called(2);
        verifyNever(() => mockNotifications.scheduleAllTimes(
              baseId: any(named: 'baseId'),
              medicationName: any(named: 'medicationName'),
              dosage: any(named: 'dosage'),
              times: any(named: 'times'),
            ));
      },
    );

    blocTest<MedicationRemindersBloc, MedicationRemindersState>(
      'reschedules notifications when toggling on',
      build: build,
      setUp: () {
        when(() => mockGet()).thenAnswer(
            (_) async => Right([_activeReminder]));
        when(() => mockToggle('r1')).thenAnswer(
            (_) async => Right(_activeReminder));
        when(() => mockNotifications.cancelReminder(any()))
            .thenAnswer((_) async {});
        when(() => mockNotifications.scheduleAllTimes(
              baseId: any(named: 'baseId'),
              medicationName: any(named: 'medicationName'),
              dosage: any(named: 'dosage'),
              times: any(named: 'times'),
            )).thenAnswer((_) async => [1001, 1002]);
      },
      seed: () => MedicationRemindersLoaded([_inactiveReminder]),
      act: (bloc) => bloc.add(const MedicationReminderToggled('r1')),
      verify: (_) {
        verify(() => mockNotifications.scheduleAllTimes(
              baseId: any(named: 'baseId'),
              medicationName: 'Metformin',
              dosage: '500mg',
              times: any(named: 'times'),
            )).called(1);
      },
    );
  });

  group('MedicationReminderDeleted', () {
    blocTest<MedicationRemindersBloc, MedicationRemindersState>(
      'emits ActionSuccess with reminder removed',
      build: build,
      setUp: () {
        when(() => mockDelete('r1'))
            .thenAnswer((_) async => const Right(null));
        when(() => mockGet()).thenAnswer(
            (_) async => const Right([]));
        when(() => mockNotifications.cancelReminder(any()))
            .thenAnswer((_) async {});
      },
      seed: () => MedicationRemindersLoaded([_activeReminder]),
      act: (bloc) => bloc.add(const MedicationReminderDeleted('r1')),
      expect: () => [
        isA<MedicationReminderActionSuccess>()
            .having((s) => s.reminders, 'reminders', isEmpty)
            .having((s) => s.message, 'message', 'Reminder deleted'),
        // After the add(Requested) fires, we get Loading then Loaded
        const MedicationRemindersLoading(),
        isA<MedicationRemindersLoaded>(),
      ],
    );

    blocTest<MedicationRemindersBloc, MedicationRemindersState>(
      'cancels notifications for deleted reminder',
      build: build,
      setUp: () {
        when(() => mockDelete('r1'))
            .thenAnswer((_) async => const Right(null));
        when(() => mockGet()).thenAnswer(
            (_) async => const Right([]));
        when(() => mockNotifications.cancelReminder(any()))
            .thenAnswer((_) async {});
      },
      seed: () => MedicationRemindersLoaded([_activeReminder]),
      act: (bloc) => bloc.add(const MedicationReminderDeleted('r1')),
      verify: (_) {
        verify(() => mockNotifications.cancelReminder(any())).called(2);
      },
    );

    blocTest<MedicationRemindersBloc, MedicationRemindersState>(
      'emits Failure when delete fails',
      build: build,
      setUp: () {
        when(() => mockDelete('r1')).thenAnswer((_) async =>
            const Left(ServerFailure(message: 'Delete failed')));
      },
      seed: () => MedicationRemindersLoaded([_activeReminder]),
      act: (bloc) => bloc.add(const MedicationReminderDeleted('r1')),
      expect: () => [
        const MedicationRemindersFailure('Delete failed'),
      ],
    );
  });
}
