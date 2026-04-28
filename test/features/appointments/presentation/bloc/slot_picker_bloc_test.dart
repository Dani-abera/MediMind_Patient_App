import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medimind/core/error/failures.dart';
import 'package:medimind/features/appointments/domain/entities/time_slot.dart';
import 'package:medimind/features/appointments/presentation/bloc/slot_picker/slot_picker_bloc.dart';
import 'package:medimind/features/appointments/presentation/bloc/slot_picker/slot_picker_event.dart';
import 'package:medimind/features/appointments/presentation/bloc/slot_picker/slot_picker_state.dart';
import 'package:medimind/features/doctors/domain/usecases/get_availability_usecase.dart';
import 'package:medimind/features/doctors/domain/usecases/get_available_dates_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockGetAvailableDatesUsecase extends Mock
    implements GetAvailableDatesUsecase {}

class MockGetAvailabilityUsecase extends Mock
    implements GetAvailabilityUsecase {}

class FakeGetAvailableDatesParams extends Fake
    implements GetAvailableDatesParams {}

class FakeGetAvailabilityParams extends Fake implements GetAvailabilityParams {}

void main() {
  late MockGetAvailableDatesUsecase mockGetDates;
  late MockGetAvailabilityUsecase mockGetSlots;

  final today = DateTime.now();
  final tomorrow = today.add(const Duration(days: 1));
  final dates = [today, tomorrow];
  final slots = [
    TimeSlot(
        id: 's1',
        dateTime: today.add(const Duration(hours: 3)),
        isBooked: false),
    TimeSlot(
        id: 's2',
        dateTime: today.add(const Duration(hours: 4)),
        isBooked: true),
  ];

  setUpAll(() {
    registerFallbackValue(FakeGetAvailableDatesParams());
    registerFallbackValue(FakeGetAvailabilityParams());
  });

  setUp(() {
    mockGetDates = MockGetAvailableDatesUsecase();
    mockGetSlots = MockGetAvailabilityUsecase();
  });

  SlotPickerBloc buildBloc() => SlotPickerBloc(
        getAvailableDates: mockGetDates,
        getAvailability: mockGetSlots,
      );

  group('SlotPickerInitialized', () {
    blocTest<SlotPickerBloc, SlotPickerState>(
      'emits DatesLoading then DatesLoaded then auto-selects first date',
      build: () {
        when(() => mockGetDates(any())).thenAnswer(
          (_) async => Right(dates),
        );
        when(() => mockGetSlots(any())).thenAnswer(
          (_) async => Right(slots),
        );
        return buildBloc();
      },
      act: (b) => b.add(const SlotPickerInitialized(
        doctorId: 'd1',
        centerId: 'c1',
      )),
      expect: () => [
        const DatesLoading(),
        isA<DatesLoaded>().having(
            (s) => s.availableDates.length, 'dates count', 2),
        isA<SlotsLoading>(),
        isA<SlotsLoaded>()
            .having((s) => s.slots.length, 'slots count', 2)
            .having((s) => s.slots.first.id, 'first slot id', 's1'),
      ],
    );

    blocTest<SlotPickerBloc, SlotPickerState>(
      'emits DatesLoaded with empty list when no dates available',
      build: () {
        when(() => mockGetDates(any())).thenAnswer(
          (_) async => const Right([]),
        );
        return buildBloc();
      },
      act: (b) => b.add(const SlotPickerInitialized(
        doctorId: 'd1',
        centerId: 'c1',
      )),
      expect: () => [
        const DatesLoading(),
        isA<DatesLoaded>().having(
            (s) => s.availableDates.isEmpty, 'empty', true),
      ],
    );

    blocTest<SlotPickerBloc, SlotPickerState>(
      'emits DatesLoaded with empty list on failure',
      build: () {
        when(() => mockGetDates(any())).thenAnswer(
          (_) async =>
              const Left(ServerFailure(message: 'Failed to load dates')),
        );
        return buildBloc();
      },
      act: (b) => b.add(const SlotPickerInitialized(
        doctorId: 'd1',
        centerId: 'c1',
      )),
      expect: () => [
        const DatesLoading(),
        isA<DatesLoaded>().having(
            (s) => s.availableDates.isEmpty, 'empty', true),
      ],
    );
  });

  group('SlotDateSelected', () {
    blocTest<SlotPickerBloc, SlotPickerState>(
      'emits SlotsLoading then SlotsLoaded',
      build: () {
        when(() => mockGetSlots(any()))
            .thenAnswer((_) async => Right(slots));
        return buildBloc();
      },
      seed: () => DatesLoaded(
        availableDates: dates,
        doctorId: 'd1',
        centerId: 'c1',
      ),
      act: (b) => b.add(SlotDateSelected(today)),
      expect: () => [
        isA<SlotsLoading>(),
        isA<SlotsLoaded>().having(
            (s) => s.slots.length, 'slots', 2),
      ],
    );

    blocTest<SlotPickerBloc, SlotPickerState>(
      'emits SlotsError when availability fails',
      build: () {
        when(() => mockGetSlots(any())).thenAnswer(
          (_) async =>
              const Left(ServerFailure(message: 'Failed to load slots')),
        );
        return buildBloc();
      },
      seed: () => DatesLoaded(
        availableDates: dates,
        doctorId: 'd1',
        centerId: 'c1',
      ),
      act: (b) => b.add(SlotDateSelected(today)),
      expect: () => [
        isA<SlotsLoading>(),
        isA<SlotsError>()
            .having((s) => s.message, 'message', 'Failed to load slots'),
      ],
    );
  });

  group('SlotChipSelected', () {
    blocTest<SlotPickerBloc, SlotPickerState>(
      'selects available slot',
      build: buildBloc,
      seed: () => SlotsLoaded(
        availableDates: dates,
        selectedDate: today,
        slots: slots,
        doctorId: 'd1',
        centerId: 'c1',
      ),
      act: (b) => b.add(SlotChipSelected(slots.first)),
      expect: () => [
        isA<SlotsLoaded>().having(
            (s) => s.selectedSlot?.id, 'selected slot', 's1'),
      ],
    );

    blocTest<SlotPickerBloc, SlotPickerState>(
      'ignores booked slot',
      build: buildBloc,
      seed: () => SlotsLoaded(
        availableDates: dates,
        selectedDate: today,
        slots: slots,
        doctorId: 'd1',
        centerId: 'c1',
      ),
      act: (b) => b.add(SlotChipSelected(slots[1])),
      expect: () => [],
    );
  });
}
