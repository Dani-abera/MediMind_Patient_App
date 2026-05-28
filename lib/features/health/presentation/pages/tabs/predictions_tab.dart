import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../../../core/routing/route_names.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../../../../predictions/domain/entities/prediction.dart';
import '../../../../predictions/domain/entities/prediction_status.dart';
import '../../../../predictions/presentation/bloc/prediction/prediction_bloc.dart';
import '../../../../predictions/presentation/bloc/prediction/prediction_event.dart';
import '../../../../predictions/presentation/bloc/prediction/prediction_state.dart';

class PredictionsTab extends StatefulWidget {
  const PredictionsTab({super.key});

  @override
  State<PredictionsTab> createState() => _PredictionsTabState();
}

class _PredictionsTabState extends State<PredictionsTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<PredictionBloc>().add(const PredictionsRequested());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PredictionBloc, PredictionState>(
      listenWhen: (_, curr) => curr is PredictionSuccess,
      listener: (context, _) =>
          context.read<PredictionBloc>().add(const PredictionsRequested()),
      builder: (context, state) {
        return switch (state) {
          PredictionInitial() ||
          PredictionsLoading() ||
          PredictionProcessing() ||
          PredictionSuccess() =>
            const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          PredictionsLoaded() => _PredictionsContent(state: state),
          PredictionFailure(:final message) => _ErrorView(
              message: message,
              onRetry: () =>
                  context.read<PredictionBloc>().add(const PredictionsRequested()),
            ),
          _ => const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
        };
      },
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Main Content
// ──────────────────────────────────────────────────────────────────────────────

class _PredictionsContent extends StatelessWidget {
  const _PredictionsContent({required this.state});
  final PredictionsLoaded state;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async =>
          context.read<PredictionBloc>().add(const PredictionsRequested()),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (state.latestPrediction != null)
                    _LatestPredictionCard(prediction: state.latestPrediction!),
                  if (state.status != null) ...[
                    SizedBox(height: 12.h),
                    _StatusCard(status: state.status!),
                  ],
                  SizedBox(height: 14.h),
                  FilledButton.icon(
                    onPressed: () => context.push(RouteNames.requestPrediction),
                    icon: const Icon(Icons.psychology),
                    label: const Text('Run AI Prediction'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      minimumSize: Size(double.infinity, 48.h),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r)),
                    ),
                  ),
                  if (state.predictions.isNotEmpty) ...[
                    SizedBox(height: 22.h),
                    Text('History',
                        style: AppTypography.subtitle
                            .copyWith(fontWeight: FontWeight.w700)),
                    SizedBox(height: 8.h),
                  ],
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _PredictionHistoryTile(
                prediction: state.predictions[index],
                isLast: index == state.predictions.length - 1,
              ),
              childCount: state.predictions.length,
            ),
          ),
          if (state.predictions.isEmpty && state.latestPrediction == null)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _EmptyState(),
            ),
          SliverToBoxAdapter(child: SizedBox(height: 24.h)),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Status Card (GET /health-predictions/status)
// ──────────────────────────────────────────────────────────────────────────────

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.status});
  final PredictionStatus status;

  Color get _color => switch (status.confidenceLevel.toLowerCase()) {
        'high' => AppColors.success,
        'medium' => AppColors.warning,
        _ => AppColors.danger,
      };

  IconData get _icon => switch (status.confidenceLevel.toLowerCase()) {
        'high' => Icons.verified_outlined,
        'medium' => Icons.info_outline,
        _ => Icons.warning_amber_outlined,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: _color.withValues(alpha: 0.22)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_icon, color: _color, size: 18.r),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${status.healthRecordCount} vital record${status.healthRecordCount == 1 ? '' : 's'}',
                      style: AppTypography.caption
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 7.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: _color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        '${status.confidenceLevel} Confidence',
                        style: AppTypography.caption.copyWith(
                          color: _color,
                          fontWeight: FontWeight.w600,
                          fontSize: 10.sp,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 3.h),
                Text(
                  status.message,
                  style: AppTypography.caption
                      .copyWith(color: AppColors.neutral700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Latest Prediction Card
// ──────────────────────────────────────────────────────────────────────────────

class _LatestPredictionCard extends StatelessWidget {
  const _LatestPredictionCard({required this.prediction});
  final Prediction prediction;

  RiskLevel get _overallRisk {
    final levels = [
      prediction.diabetes.riskLevel,
      prediction.hypertension.riskLevel,
      prediction.cardiovascular.riskLevel,
    ];
    if (levels.contains(RiskLevel.high)) return RiskLevel.high;
    if (levels.contains(RiskLevel.medium)) return RiskLevel.medium;
    return RiskLevel.low;
  }

  Color get _overallColor => switch (_overallRisk) {
        RiskLevel.low => AppColors.success,
        RiskLevel.medium => AppColors.warning,
        RiskLevel.high => AppColors.danger,
      };

  String get _overallLabel => switch (_overallRisk) {
        RiskLevel.low => 'Low Overall Risk',
        RiskLevel.medium => 'Moderate Risk',
        RiskLevel.high => 'High Risk',
      };

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('MMM d, y').format(prediction.createdAt);

    return GestureDetector(
      onTap: () => context
          .push('${RouteNames.predictionDetail}/${prediction.id}'),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _overallColor.withValues(alpha: 0.12),
              _overallColor.withValues(alpha: 0.04),
            ],
          ),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
              color: _overallColor.withValues(alpha: 0.2), width: 1.5),
        ),
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.psychology, color: _overallColor, size: 18.r),
                    SizedBox(width: 6.w),
                    Text('Latest Prediction',
                        style: AppTypography.caption.copyWith(
                            color: _overallColor,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
                Text(date,
                    style: AppTypography.caption
                        .copyWith(color: AppColors.neutral500)),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: _overallColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(_overallLabel,
                      style: AppTypography.caption.copyWith(
                          color: _overallColor,
                          fontWeight: FontWeight.w700)),
                ),
                const Spacer(),
                _MiniRiskBadge(label: 'DM', risk: prediction.diabetes),
                SizedBox(width: 6.w),
                _MiniRiskBadge(label: 'HTN', risk: prediction.hypertension),
                SizedBox(width: 6.w),
                _MiniRiskBadge(label: 'CVD', risk: prediction.cardiovascular),
              ],
            ),
            SizedBox(height: 10.h),
            Text(
              prediction.formattedConfidence,
              style: AppTypography.caption
                  .copyWith(color: AppColors.neutral500),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// History Tile
// ──────────────────────────────────────────────────────────────────────────────

class _PredictionHistoryTile extends StatelessWidget {
  const _PredictionHistoryTile({
    required this.prediction,
    required this.isLast,
  });
  final Prediction prediction;
  final bool isLast;

  RiskLevel get _overall {
    final levels = [
      prediction.diabetes.riskLevel,
      prediction.hypertension.riskLevel,
      prediction.cardiovascular.riskLevel,
    ];
    if (levels.contains(RiskLevel.high)) return RiskLevel.high;
    if (levels.contains(RiskLevel.medium)) return RiskLevel.medium;
    return RiskLevel.low;
  }

  Color get _overallColor => switch (_overall) {
        RiskLevel.low => AppColors.success,
        RiskLevel.medium => AppColors.warning,
        RiskLevel.high => AppColors.danger,
      };

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('MMM d, y').format(prediction.createdAt);

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, isLast ? 0 : 8.h),
      child: GestureDetector(
        onTap: () => context
            .push('${RouteNames.predictionDetail}/${prediction.id}'),
        child: Container(
          padding: EdgeInsets.all(14.r),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.neutral100),
          ),
          child: Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: _overallColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.psychology,
                    color: _overallColor, size: 20.r),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(date,
                        style: AppTypography.body
                            .copyWith(fontWeight: FontWeight.w600)),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        _RiskDot(risk: prediction.diabetes),
                        SizedBox(width: 4.w),
                        Text('DM',
                            style: AppTypography.caption.copyWith(
                                color: AppColors.neutral500,
                                fontSize: 10.sp)),
                        SizedBox(width: 10.w),
                        _RiskDot(risk: prediction.hypertension),
                        SizedBox(width: 4.w),
                        Text('HTN',
                            style: AppTypography.caption.copyWith(
                                color: AppColors.neutral500,
                                fontSize: 10.sp)),
                        SizedBox(width: 10.w),
                        _RiskDot(risk: prediction.cardiovascular),
                        SizedBox(width: 4.w),
                        Text('CVD',
                            style: AppTypography.caption.copyWith(
                                color: AppColors.neutral500,
                                fontSize: 10.sp)),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: _overallColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      _overall == RiskLevel.low
                          ? 'Low'
                          : _overall == RiskLevel.medium
                              ? 'Medium'
                              : 'High',
                      style: AppTypography.caption.copyWith(
                          color: _overallColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 10.sp),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Icon(Icons.chevron_right,
                      color: AppColors.neutral500, size: 18.r),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Small Helpers
// ──────────────────────────────────────────────────────────────────────────────

class _MiniRiskBadge extends StatelessWidget {
  const _MiniRiskBadge({required this.label, required this.risk});
  final String label;
  final DiseaseRisk risk;

  Color get _color => switch (risk.riskLevel) {
        RiskLevel.low => AppColors.success,
        RiskLevel.medium => AppColors.warning,
        RiskLevel.high => AppColors.danger,
      };

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 28.w,
          height: 28.w,
          decoration: BoxDecoration(
            color: _color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              risk.riskScore.toStringAsFixed(0),
              style: AppTypography.caption.copyWith(
                  fontSize: 9.sp,
                  color: _color,
                  fontWeight: FontWeight.w800),
            ),
          ),
        ),
        SizedBox(height: 2.h),
        Text(label,
            style: AppTypography.caption
                .copyWith(fontSize: 9.sp, color: AppColors.neutral500)),
      ],
    );
  }
}

class _RiskDot extends StatelessWidget {
  const _RiskDot({required this.risk});
  final DiseaseRisk risk;

  Color get _color => switch (risk.riskLevel) {
        RiskLevel.low => AppColors.success,
        RiskLevel.medium => AppColors.warning,
        RiskLevel.high => AppColors.danger,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8.w,
      height: 8.w,
      decoration: BoxDecoration(color: _color, shape: BoxShape.circle),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24.r),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.psychology_outlined,
                size: 52.r, color: AppColors.primary),
          ),
          SizedBox(height: 20.h),
          Text('No Predictions Yet',
              style: AppTypography.subtitle
                  .copyWith(fontWeight: FontWeight.w700)),
          SizedBox(height: 8.h),
          Text(
            'Log at least one vital record,\nthen run your first AI health prediction.',
            style: AppTypography.caption
                .copyWith(color: AppColors.neutral500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
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
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48.r, color: AppColors.danger),
            SizedBox(height: 12.h),
            Text(message,
                style: AppTypography.body, textAlign: TextAlign.center),
            SizedBox(height: 16.h),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
