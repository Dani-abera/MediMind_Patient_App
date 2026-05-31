import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../bloc/appointments/appointments_bloc.dart';
import '../bloc/appointments/appointments_event.dart';
import '../bloc/booking_flow/booking_flow_bloc.dart';
import '../bloc/booking_flow/booking_flow_event.dart';
import '../bloc/booking_flow/booking_flow_state.dart';

class BookingConfirmationPage extends StatefulWidget {
  const BookingConfirmationPage({super.key});

  @override
  State<BookingConfirmationPage> createState() =>
      _BookingConfirmationPageState();
}

class _BookingConfirmationPageState extends State<BookingConfirmationPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.elasticOut,
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookingFlowBloc, BookingFlowState>(
      builder: (context, state) {
        final doctor = state.selectedDoctor;
        final center = state.selectedCenter;
        final slot = state.selectedSlot;
        final date = state.selectedDate;
        final appointmentId = state.createdAppointmentId;

        return PopScope(
          canPop: false,
          child: Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(24.r),
                      child: Column(
                        children: [
                          SizedBox(height: 32.h),
                          ScaleTransition(
                            scale: _scaleAnim,
                            child: Container(
                              width: 96.w,
                              height: 96.w,
                              decoration: BoxDecoration(
                                color: AppColors.success
                                    .withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.success,
                                size: 64.r,
                              ),
                            ),
                          ),
                          SizedBox(height: 20.h),
                          FadeTransition(
                            opacity: _fadeAnim,
                            child: Column(
                              children: [
                                Text(
                                  'Appointment Confirmed!',
                                  style: AppTypography.title,
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 8.h),
                                if (appointmentId != null)
                                  Text(
                                    'Booking ID: ${appointmentId.substring(0, 8).toUpperCase()}',
                                    style: AppTypography.caption.copyWith(
                                        color: AppColors.neutral500),
                                  ),
                              ],
                            ),
                          ),
                          SizedBox(height: 32.h),
                          if (doctor != null &&
                              center != null &&
                              slot != null &&
                              date != null)
                            _ConfirmationCard(
                              doctor: doctor.fullName,
                              specialization: doctor.specialization,
                              center: center.name,
                              address: center.address,
                              date: DateFormat('EEE, MMM d, yyyy').format(date),
                              time: slot.formattedTime,
                              total: state.totalAmount,
                            ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16.r),
                    child: Column(
                      children: [
                        if (appointmentId != null)
                          OutlinedButton(
                            onPressed: () {
                              context.goNamed(
                                RouteNames.appointmentDetail,
                                pathParameters: {'id': appointmentId},
                              );
                              context
                                  .read<BookingFlowBloc>()
                                  .add(const BookingReset());
                            },
                            style: OutlinedButton.styleFrom(
                              minimumSize: Size(double.infinity, 52.h),
                              side: const BorderSide(color: AppColors.primary),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(AppRadius.lg),
                              ),
                            ),
                            child: Text(
                              'View Appointment',
                              style: AppTypography.subtitle
                                  .copyWith(color: AppColors.primary),
                            ),
                          ),
                        SizedBox(height: 12.h),
                        ElevatedButton(
                          onPressed: () {
                            final router = GoRouter.of(context);
                            context
                                .read<BookingFlowBloc>()
                                .add(const BookingReset());
                            context
                                .read<AppointmentsBloc>()
                                .add(const AppointmentsRefreshed());
                            router.go('/book');
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              router.go('/home');
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            minimumSize: Size(double.infinity, 52.h),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppRadius.lg),
                            ),
                          ),
                          child: Text(
                            'Back to Home',
                            style: AppTypography.subtitle
                                .copyWith(color: AppColors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ConfirmationCard extends StatelessWidget {
  const _ConfirmationCard({
    required this.doctor,
    required this.specialization,
    required this.center,
    required this.address,
    required this.date,
    required this.time,
    required this.total,
  });

  final String doctor;
  final String specialization;
  final String center;
  final String address;
  final String date;
  final String time;
  final double total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.neutral300),
      ),
      child: Column(
        children: [
          _Row(icon: Icons.person_outline_rounded,
              label: 'Dr. $doctor', sub: specialization),
          _Divider(),
          _Row(icon: Icons.local_hospital_outlined,
              label: center, sub: address),
          _Divider(),
          _Row(icon: Icons.calendar_today_outlined,
              label: date, sub: time),
          _Divider(),
          _Row(icon: Icons.payment_rounded,
              label: 'ETB ${total.toStringAsFixed(2)}', sub: 'Total paid'),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.icon, required this.label, required this.sub});
  final IconData icon;
  final String label;
  final String sub;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20.r, color: AppColors.primary),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: AppTypography.body
                      .copyWith(fontWeight: FontWeight.w600)),
              Text(sub, style: AppTypography.caption),
            ],
          ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Divider(height: 20.h, color: AppColors.neutral300);
}
