import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../../../core/routing/route_names.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../../../../predictions/domain/entities/prediction.dart';
import '../../../../predictions/presentation/bloc/prediction/prediction_bloc.dart';
import '../../../../predictions/presentation/bloc/prediction/prediction_event.dart';
import '../../../../predictions/presentation/bloc/prediction/prediction_state.dart';

class PredictionsTab extends StatelessWidget {
  const PredictionsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PredictionBloc, PredictionState>(
      builder: (context, state) {
        return switch (state) {
          PredictionInitial() ||
          PredictionsLoading() =>
            const Center(
              child:
                  CircularProgressIndicator(color: AppColors.primary),
            ),
          PredictionsLoaded() => _PredictionsContent(state: state),
          PredictionFailure(:final message) => _ErrorView(
              message: message,
              onRetry: () => context
                  .read<PredictionBloc>()
                  .add(const PredictionsRequested()),
            ),
          _ => const SizedBox.shrink(),
        };
      },
    );
  }
}

class _PredictionsContent extends StatelessWidget {
  const _PredictionsContent({required this.state});
  final PredictionsLoaded state;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (state.latestPrediction != null)
                  _LatestPredictionCard(
                      prediction: state.latestPrediction!),
                SizedBox(height: 16.h),
                FilledButton.icon(
                  onPressed: () =>
                      context.push(RouteNames.requestPrediction),
                  icon: const Icon(Icons.psychology),
                  label: const Text('Run AI Prediction'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: Size(double.infinity, 48.h),
                  ),
                ),
                if (state.predictions.isNotEmpty) ...[
                  SizedBox(height: 20.h),
                  Text('History',
                      style: AppTypography.subtitle.copyWith(
                          fontWeight: FontWeight.w600)),
                ],
              ],
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => _PredictionHistoryTile(
              prediction: state.predictions[index],
            ),
            childCount: state.predictions.length,
          ),
        ),
        if (state.predictions.isEmpty && state.latestPrediction == null)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.psychology_outlined,
                      size: 64.r, color: AppColors.neutral300),
                  SizedBox(height: 16.h),
                  Text('No predictions yet',
                      style: AppTypography.subtitle),
                  SizedBox(height: 8.h),
                  Text(
                    'Log at least one vital record\nthen run an AI prediction',
                    style: AppTypography.caption
                        .copyWith(color: AppColors.neutral500),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _LatestPredictionCard extends StatelessWidget {
  const _LatestPredictionCard({required this.prediction});
  final Prediction prediction;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(
          '${RouteNames.predictionDetail}/${prediction.id}'),
      child: Card(
        elevation: 0,
        color: AppColors.info.withValues(alpha: 0.06),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r)),
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Latest Prediction',
                      style: AppTypography.caption.copyWith(
                          color: AppColors.info,
                          fontWeight: FontWeight.w600)),
                  Text(prediction.formattedConfidence,
                      style: AppTypography.caption
                          .copyWith(color: AppColors.neutral500)),
                ],
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  _RiskBadge(
                      label: 'Diabetes',
                      risk: prediction.diabetes),
                  SizedBox(width: 8.w),
                  _RiskBadge(
                      label: 'Hypertension',
                      risk: prediction.hypertension),
                  SizedBox(width: 8.w),
                  _RiskBadge(
                      label: 'CVD',
                      risk: prediction.cardiovascular),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RiskBadge extends StatelessWidget {
  const _RiskBadge({required this.label, required this.risk});
  final String label;
  final DiseaseRisk risk;

  Color get _color => switch (risk.riskLevel) {
        RiskLevel.low => AppColors.success,
        RiskLevel.medium => AppColors.warning,
        RiskLevel.high => AppColors.danger,
      };

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        decoration: BoxDecoration(
          color: _color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Column(
          children: [
            Text(label,
                style: AppTypography.caption
                    .copyWith(fontSize: 10.sp, color: AppColors.neutral500),
                textAlign: TextAlign.center),
            SizedBox(height: 4.h),
            Text(risk.riskLabel,
                style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.w700, color: _color),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _PredictionHistoryTile extends StatelessWidget {
  const _PredictionHistoryTile({required this.prediction});
  final Prediction prediction;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding:
          EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      leading: CircleAvatar(
        backgroundColor: AppColors.info.withValues(alpha: 0.1),
        child: Icon(Icons.psychology, color: AppColors.info, size: 20.r),
      ),
      title: Text(
        prediction.formattedConfidence,
        style: AppTypography.body.copyWith(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        '${prediction.dataPointsUsed} data points used',
        style:
            AppTypography.caption.copyWith(color: AppColors.neutral500),
      ),
      trailing: Icon(Icons.chevron_right, color: AppColors.neutral500),
      onTap: () => context.push(
          '${RouteNames.predictionDetail}/${prediction.id}'),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48.r, color: AppColors.danger),
          SizedBox(height: 12.h),
          Text(message, style: AppTypography.body, textAlign: TextAlign.center),
          SizedBox(height: 16.h),
          OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
