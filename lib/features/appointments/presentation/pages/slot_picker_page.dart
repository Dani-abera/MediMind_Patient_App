import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/feedback/app_shimmer.dart';
import '../../../doctors/domain/entities/doctor.dart';
import '../../domain/entities/time_slot.dart';
import '../bloc/booking_flow/booking_flow_bloc.dart';
import '../bloc/booking_flow/booking_flow_event.dart';
import '../bloc/booking_flow/booking_flow_state.dart';
import '../bloc/slot_picker/slot_picker_bloc.dart';
import '../bloc/slot_picker/slot_picker_event.dart';
import '../bloc/slot_picker/slot_picker_state.dart';

class SlotPickerPage extends StatefulWidget {
  const SlotPickerPage({super.key});

  @override
  State<SlotPickerPage> createState() => _SlotPickerPageState();
}

class _SlotPickerPageState extends State<SlotPickerPage> {
  DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    final flowState = context.read<BookingFlowBloc>().state;
    final doctorId = flowState.selectedDoctor?.id ?? '';
    final centerId = flowState.selectedCenter?.id ?? '';
    if (doctorId.isNotEmpty && centerId.isNotEmpty) {
      context.read<SlotPickerBloc>().add(
            SlotPickerInitialized(doctorId: doctorId, centerId: centerId),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        title: const Text('Choose a Slot'),
      ),
      body: BlocBuilder<SlotPickerBloc, SlotPickerState>(
        builder: (context, state) {
          if (state is DatesLoading) {
            return const _SlotPickerShimmer();
          }

          final availableDates = switch (state) {
            DatesLoaded(availableDates: final d) => d,
            SlotsLoading(availableDates: final d) => d,
            SlotsLoaded(availableDates: final d) => d,
            SlotsError(availableDates: final d) => d,
            _ => <DateTime>[],
          };

          final selectedDate = switch (state) {
            SlotsLoaded(selectedDate: final d) => d,
            SlotsLoading(selectedDate: final d) => d,
            SlotsError(selectedDate: final d) => d,
            _ => null,
          };

          final selectedSlot = state is SlotsLoaded ? state.selectedSlot : null;

          return BlocBuilder<BookingFlowBloc, BookingFlowState>(
            buildWhen: (p, n) => p.selectedDoctor != n.selectedDoctor,
            builder: (context, flowState) {
              final doctor = flowState.selectedDoctor;
              return Column(
                children: [
                  if (doctor != null)
                    _DoctorMiniCard(doctor: doctor),
                  Expanded(
                    child: CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: _Calendar(
                            focusedDay: _focusedDay,
                            selectedDay: selectedDate,
                            availableDates: availableDates,
                            onDaySelected: (day, focused) {
                              setState(() => _focusedDay = focused);
                              context
                                  .read<SlotPickerBloc>()
                                  .add(SlotDateSelected(day));
                            },
                          ),
                        ),
                        if (state is SlotsLoading)
                          const SliverToBoxAdapter(
                            child: _SlotsLoadingIndicator(),
                          )
                        else if (state is SlotsLoaded)
                          SliverToBoxAdapter(
                            child: _SlotsGrid(
                              slots: state.slots,
                              selectedSlot: selectedSlot,
                              onTap: (slot) => context
                                  .read<SlotPickerBloc>()
                                  .add(SlotChipSelected(slot)),
                            ),
                          )
                        else if (state is SlotsError)
                          SliverToBoxAdapter(
                            child: Center(
                              child: Text(state.message,
                                  style: AppTypography.body),
                            ),
                          ),
                        SliverToBoxAdapter(child: SizedBox(height: 100.h)),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
      bottomNavigationBar: BlocBuilder<SlotPickerBloc, SlotPickerState>(
        builder: (context, state) {
          final slot =
              state is SlotsLoaded ? state.selectedSlot : null;
          return SafeArea(
            child: Padding(
              padding: EdgeInsets.all(16.r),
              child: ElevatedButton(
                onPressed: slot == null
                    ? null
                    : () {
                        final date = (state as SlotsLoaded).selectedDate;
                        context.read<BookingFlowBloc>().add(
                              SlotSelected(date: date, slot: slot),
                            );
                        context.pushNamed(RouteNames.appointmentConfirm);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.neutral300,
                  minimumSize: Size(double.infinity, 52.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                ),
                child: Text(
                  'Continue',
                  style: AppTypography.subtitle
                      .copyWith(color: AppColors.white),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DoctorMiniCard extends StatelessWidget {
  const _DoctorMiniCard({required this.doctor});
  final Doctor doctor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16.r),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.neutral300),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20.r,
            backgroundColor: AppColors.primaryLight,
            backgroundImage: doctor.avatarUrl != null
                ? NetworkImage(doctor.avatarUrl!)
                : null,
            child: doctor.avatarUrl == null
                ? Text(
                    doctor.fullName[0].toUpperCase(),
                    style: AppTypography.body
                        .copyWith(color: AppColors.white),
                  )
                : null,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Dr. ${doctor.fullName}',
                    style: AppTypography.body
                        .copyWith(fontWeight: FontWeight.w600)),
                Text(doctor.specialization, style: AppTypography.caption),
              ],
            ),
          ),
          Text(doctor.formattedFee,
              style: AppTypography.body
                  .copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _Calendar extends StatelessWidget {
  const _Calendar({
    required this.focusedDay,
    required this.selectedDay,
    required this.availableDates,
    required this.onDaySelected,
  });

  final DateTime focusedDay;
  final DateTime? selectedDay;
  final List<DateTime> availableDates;
  final void Function(DateTime, DateTime) onDaySelected;

  bool _isAvailable(DateTime day) => availableDates.any(
        (d) => d.year == day.year && d.month == day.month && d.day == day.day,
      );

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return TableCalendar(
      firstDay: now,
      lastDay: now.add(const Duration(days: 60)),
      focusedDay: focusedDay,
      calendarFormat: CalendarFormat.twoWeeks,
      availableCalendarFormats: const {
        CalendarFormat.twoWeeks: '2 Weeks',
        CalendarFormat.week: 'Week',
      },
      enabledDayPredicate: _isAvailable,
      selectedDayPredicate: (day) =>
          selectedDay != null && isSameDay(selectedDay, day),
      onDaySelected: onDaySelected,
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        selectedDecoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        disabledTextStyle:
            AppTypography.caption.copyWith(color: AppColors.neutral300),
        outsideDaysVisible: false,
      ),
      headerStyle: HeaderStyle(
        formatButtonDecoration: BoxDecoration(
          border: Border.all(color: AppColors.neutral300),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        formatButtonTextStyle: AppTypography.caption,
      ),
    );
  }
}

class _SlotsGrid extends StatelessWidget {
  const _SlotsGrid({
    required this.slots,
    required this.selectedSlot,
    required this.onTap,
  });

  final List<TimeSlot> slots;
  final TimeSlot? selectedSlot;
  final ValueChanged<TimeSlot> onTap;

  @override
  Widget build(BuildContext context) {
    if (slots.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(24.r),
        child: Center(
          child: Text(
            'No available slots for this date.',
            style: AppTypography.body,
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Available Times', style: AppTypography.subtitle),
          SizedBox(height: 12.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8.w,
              mainAxisSpacing: 8.h,
              childAspectRatio: 2.4,
            ),
            itemCount: slots.length,
            itemBuilder: (context, i) {
              final slot = slots[i];
              if (slot.isPast) return const SizedBox.shrink();
              final isSelected = selectedSlot?.id == slot.id;
              return _SlotChip(
                slot: slot,
                isSelected: isSelected,
                onTap: slot.isAvailable ? () => onTap(slot) : null,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SlotChip extends StatelessWidget {
  const _SlotChip({
    required this.slot,
    required this.isSelected,
    this.onTap,
  });

  final TimeSlot slot;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isBooked = slot.isBooked;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : isBooked
                  ? AppColors.neutral100
                  : AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : isBooked
                    ? AppColors.neutral300
                    : AppColors.success.withValues(alpha: 0.6),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          slot.formattedTime,
          style: AppTypography.caption.copyWith(
            color: isSelected
                ? AppColors.white
                : isBooked
                    ? AppColors.neutral300
                    : AppColors.neutral900,
            fontWeight:
                isSelected ? FontWeight.w600 : FontWeight.normal,
            decoration:
                isBooked ? TextDecoration.lineThrough : null,
          ),
        ),
      ),
    );
  }
}

class _SlotsLoadingIndicator extends StatelessWidget {
  const _SlotsLoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.r),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8.w,
          mainAxisSpacing: 8.h,
          childAspectRatio: 2.4,
        ),
        itemCount: 9,
        itemBuilder: (_, __) =>
            AppShimmer.box(width: double.infinity, height: 36.h, radius: 8),
      ),
    );
  }
}

class _SlotPickerShimmer extends StatelessWidget {
  const _SlotPickerShimmer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppShimmer.box(width: double.infinity, height: 80.h, radius: 12),
          SizedBox(height: 16.h),
          AppShimmer.box(width: double.infinity, height: 300.h, radius: 12),
        ],
      ),
    );
  }
}
