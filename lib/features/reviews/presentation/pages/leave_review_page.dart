import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../bloc/review_bloc.dart';
import '../bloc/review_event.dart';
import '../bloc/review_state.dart';

class LeaveReviewPage extends StatelessWidget {
  const LeaveReviewPage({
    super.key,
    required this.appointmentId,
    required this.doctorName,
    required this.centerName,
  });

  final String appointmentId;
  final String doctorName;
  final String centerName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Leave a Review', style: AppTypography.title),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.neutral900,
        elevation: 0,
      ),
      body: BlocConsumer<ReviewBloc, ReviewState>(
        listener: (context, state) {
          if (state.isSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Review submitted. Thank you!')),
            );
            Navigator.pop(context);
          }
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _RatingSection(
                  title: 'Rate Dr. $doctorName',
                  rating: state.doctorRating,
                  onChanged: (r) => context
                      .read<ReviewBloc>()
                      .add(ReviewDoctorRatingChanged(r)),
                ),
                SizedBox(height: 8.h),
                _CommentField(
                  hint: 'Write about your experience with the doctor...',
                  onChanged: (t) => context
                      .read<ReviewBloc>()
                      .add(ReviewDoctorCommentChanged(t)),
                ),
                SizedBox(height: 24.h),
                _RatingSection(
                  title: 'Rate $centerName',
                  rating: state.centerRating,
                  onChanged: (r) => context
                      .read<ReviewBloc>()
                      .add(ReviewCenterRatingChanged(r)),
                ),
                SizedBox(height: 8.h),
                _CommentField(
                  hint: 'Write about your experience at the center...',
                  onChanged: (t) => context
                      .read<ReviewBloc>()
                      .add(ReviewCenterCommentChanged(t)),
                ),
                SizedBox(height: 32.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: state.isSubmitting
                        ? null
                        : () => context
                            .read<ReviewBloc>()
                            .add(ReviewSubmitted(appointmentId)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor:
                          AppColors.primary.withValues(alpha: 0.5),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r)),
                    ),
                    child: state.isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.white))
                        : Text('Submit Review',
                            style: AppTypography.subtitle
                                .copyWith(color: AppColors.white)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _RatingSection extends StatelessWidget {
  const _RatingSection({
    required this.title,
    required this.rating,
    required this.onChanged,
  });
  final String title;
  final int rating;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.subtitle),
        SizedBox(height: 8.h),
        Row(
          children: List.generate(5, (i) {
            final filled = i < rating;
            return GestureDetector(
              onTap: () => onChanged(i + 1),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Icon(
                  filled ? Icons.star_rounded : Icons.star_border_rounded,
                  size: 36.sp,
                  color:
                      filled ? AppColors.warning : AppColors.neutral300,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _CommentField extends StatelessWidget {
  const _CommentField({required this.hint, required this.onChanged});
  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      maxLines: 4,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTypography.caption,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
        filled: true,
        fillColor: AppColors.white,
      ),
    );
  }
}
