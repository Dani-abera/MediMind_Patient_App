import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../doctors/domain/usecases/get_availability_usecase.dart';
import '../../../../doctors/domain/usecases/get_available_dates_usecase.dart';
import 'slot_picker_event.dart';
import 'slot_picker_state.dart';

class SlotPickerBloc extends Bloc<SlotPickerEvent, SlotPickerState> {
  SlotPickerBloc({
    required GetAvailableDatesUsecase getAvailableDates,
    required GetAvailabilityUsecase getAvailability,
  })  : _getAvailableDates = getAvailableDates,
        _getAvailability = getAvailability,
        super(const SlotPickerInitial()) {
    on<SlotPickerInitialized>(_onInitialized, transformer: droppable());
    on<SlotDateSelected>(_onDateSelected, transformer: restartable());
    on<SlotChipSelected>(_onChipSelected);
  }

  final GetAvailableDatesUsecase _getAvailableDates;
  final GetAvailabilityUsecase _getAvailability;

  Future<void> _onInitialized(
    SlotPickerInitialized event,
    Emitter<SlotPickerState> emit,
  ) async {
    emit(const DatesLoading());
    final result = await _getAvailableDates(
      GetAvailableDatesParams(
        doctorId: event.doctorId,
        centerId: event.centerId,
      ),
    );
    result.fold(
      (failure) => emit(const DatesLoaded(
        availableDates: [],
        doctorId: '',
        centerId: '',
      )),
      (dates) {
        final state = DatesLoaded(
          availableDates: dates,
          doctorId: event.doctorId,
          centerId: event.centerId,
        );
        emit(state);
        // Auto-select the first available date
        if (dates.isNotEmpty) {
          add(SlotDateSelected(dates.first));
        }
      },
    );
  }

  Future<void> _onDateSelected(
    SlotDateSelected event,
    Emitter<SlotPickerState> emit,
  ) async {
    final current = state;
    List<DateTime> availableDates = [];
    String doctorId = '';
    String centerId = '';

    if (current is DatesLoaded) {
      availableDates = current.availableDates;
      doctorId = current.doctorId;
      centerId = current.centerId;
    } else if (current is SlotsLoaded) {
      availableDates = current.availableDates;
      doctorId = current.doctorId;
      centerId = current.centerId;
    } else if (current is SlotsError) {
      availableDates = current.availableDates;
      doctorId = current.doctorId;
      centerId = current.centerId;
    } else {
      return;
    }

    emit(SlotsLoading(
      availableDates: availableDates,
      selectedDate: event.date,
      doctorId: doctorId,
      centerId: centerId,
    ));

    final result = await _getAvailability(
      GetAvailabilityParams(
        doctorId: doctorId,
        centerId: centerId,
        date: event.date,
      ),
    );

    result.fold(
      (failure) => emit(SlotsError(
        message: failure.message,
        availableDates: availableDates,
        selectedDate: event.date,
        doctorId: doctorId,
        centerId: centerId,
      )),
      (slots) => emit(SlotsLoaded(
        availableDates: availableDates,
        selectedDate: event.date,
        slots: slots,
        doctorId: doctorId,
        centerId: centerId,
      )),
    );
  }

  void _onChipSelected(SlotChipSelected event, Emitter<SlotPickerState> emit) {
    final current = state;
    if (current is SlotsLoaded && event.slot.isAvailable) {
      emit(current.withSelectedSlot(event.slot));
    }
  }
}
