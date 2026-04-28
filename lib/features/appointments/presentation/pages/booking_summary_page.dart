import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../bloc/booking_flow/booking_flow_bloc.dart';
import '../bloc/booking_flow/booking_flow_event.dart';
import '../bloc/booking_flow/booking_flow_state.dart';

class BookingSummaryPage extends StatefulWidget {
  const BookingSummaryPage({super.key});

  @override
  State<BookingSummaryPage> createState() => _BookingSummaryPageState();
}

class _BookingSummaryPageState extends State<BookingSummaryPage> {
  final _reasonController = TextEditingController();
  final _symptomsController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    _symptomsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BookingFlowBloc, BookingFlowState>(
      listener: (context, state) {
        if (state.step == BookingStep.payment &&
            state.checkoutUrl != null) {
          context.push('/book/payment', extra: {
            'checkoutUrl': state.checkoutUrl,
            'paymentId': state.paymentId,
          });
        }
        if (state.error != null && !state.isProcessing) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              backgroundColor: AppColors.danger,
            ),
          );
        }
      },
      builder: (context, state) {
        final doctor = state.selectedDoctor;
        final center = state.selectedCenter;
        final slot = state.selectedSlot;
        final date = state.selectedDate;

        if (doctor == null || center == null || slot == null || date == null) {
          return const Scaffold(
            body: Center(child: Text('Missing booking details')),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            surfaceTintColor: Colors.transparent,
            title: const Text('Review Booking'),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SummaryCard(
                  title: 'Doctor',
                  child: _InfoRow(
                    leading: CircleAvatar(
                      radius: 20.r,
                      backgroundColor: AppColors.primaryLight,
                      backgroundImage: doctor.avatarUrl != null
                          ? NetworkImage(doctor.avatarUrl!)
                          : null,
                      child: doctor.avatarUrl == null
                          ? Text(doctor.fullName[0].toUpperCase(),
                              style: AppTypography.caption
                                  .copyWith(color: AppColors.white))
                          : null,
                    ),
                    title: 'Dr. ${doctor.fullName}',
                    subtitle: doctor.specialization,
                  ),
                ),
                SizedBox(height: 12.h),
                _SummaryCard(
                  title: 'Center',
                  child: _InfoRow(
                    leading: const Icon(Icons.local_hospital_outlined,
                        color: AppColors.primary),
                    title: center.name,
                    subtitle: center.address,
                  ),
                ),
                SizedBox(height: 12.h),
                _SummaryCard(
                  title: 'Date & Time',
                  child: _InfoRow(
                    leading: const Icon(Icons.access_time_rounded,
                        color: AppColors.primary),
                    title: DateFormat('EEEE, MMMM d, yyyy').format(date),
                    subtitle: slot.formattedTime,
                  ),
                ),
                SizedBox(height: 20.h),
                Text('Reason for Visit *', style: AppTypography.subtitle),
                SizedBox(height: 8.h),
                TextField(
                  controller: _reasonController,
                  maxLines: 3,
                  maxLength: 500,
                  onChanged: (_) => setState(() {}),
                  decoration: _inputDecoration(
                      'Describe the reason for your visit…'),
                ),
                SizedBox(height: 12.h),
                Text('Symptoms (optional)', style: AppTypography.subtitle),
                SizedBox(height: 8.h),
                TextField(
                  controller: _symptomsController,
                  maxLines: 4,
                  maxLength: 1000,
                  decoration:
                      _inputDecoration('Describe your symptoms…'),
                ),
                SizedBox(height: 20.h),
                _PriceBreakdown(
                  consultationFee: doctor.consultationFee,
                  serviceFee: state.serviceFee,
                  total: state.totalAmount,
                ),
                SizedBox(height: 16.h),
                _TermsCheckbox(
                  agreed: state.agreedToTerms,
                  onChanged: () => context
                      .read<BookingFlowBloc>()
                      .add(const TermsToggled()),
                ),
                SizedBox(height: 80.h),
              ],
            ),
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(16.r),
              child: ElevatedButton(
                onPressed: _canConfirm(state)
                    ? () {
                        context.read<BookingFlowBloc>().add(ReasonEntered(
                              reason: _reasonController.text,
                              symptoms: _symptomsController.text.isEmpty
                                  ? null
                                  : _symptomsController.text,
                            ));
                        context
                            .read<BookingFlowBloc>()
                            .add(const BookingConfirmed());
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.neutral300,
                  minimumSize: Size(double.infinity, 52.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                ),
                child: state.isProcessing
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        'Confirm & Pay',
                        style: AppTypography.subtitle
                            .copyWith(color: AppColors.white),
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  bool _canConfirm(BookingFlowState state) =>
      _reasonController.text.trim().isNotEmpty &&
      state.agreedToTerms &&
      !state.isProcessing;

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.neutral300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.neutral300),
        ),
        contentPadding: EdgeInsets.all(12.r),
      );
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.neutral300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: AppTypography.overline
                .copyWith(color: AppColors.neutral500, letterSpacing: 1),
          ),
          SizedBox(height: 10.h),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.leading,
    required this.title,
    required this.subtitle,
  });
  final Widget leading;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        leading,
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: AppTypography.body
                      .copyWith(fontWeight: FontWeight.w600)),
              Text(subtitle, style: AppTypography.caption),
            ],
          ),
        ),
      ],
    );
  }
}

class _PriceBreakdown extends StatelessWidget {
  const _PriceBreakdown({
    required this.consultationFee,
    required this.serviceFee,
    required this.total,
  });
  final double consultationFee;
  final double serviceFee;
  final double total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.neutral300),
      ),
      child: Column(
        children: [
          _PriceRow(
              label: 'Consultation fee',
              amount: 'ETB ${consultationFee.toStringAsFixed(0)}'),
          SizedBox(height: 8.h),
          _PriceRow(
              label: 'Service fee (2%)',
              amount: 'ETB ${serviceFee.toStringAsFixed(2)}'),
          Divider(height: 16.h),
          _PriceRow(
            label: 'Total',
            amount: 'ETB ${total.toStringAsFixed(2)}',
            isBold: true,
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow(
      {required this.label, required this.amount, this.isBold = false});
  final String label;
  final String amount;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    final style = isBold
        ? AppTypography.subtitle
        : AppTypography.body.copyWith(color: AppColors.neutral700);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(amount, style: style),
      ],
    );
  }
}

class _TermsCheckbox extends StatelessWidget {
  const _TermsCheckbox({required this.agreed, required this.onChanged});
  final bool agreed;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onChanged,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24.w,
            height: 24.h,
            child: Checkbox(
              value: agreed,
              onChanged: (_) => onChanged(),
              activeColor: AppColors.primary,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              'I agree to the booking terms and cancellation policy.',
              style: AppTypography.caption,
            ),
          ),
        ],
      ),
    );
  }
}
