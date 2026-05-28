import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/prediction.dart';
import '../bloc/prediction/prediction_bloc.dart';
import '../bloc/prediction/prediction_event.dart';
import '../bloc/prediction/prediction_state.dart';

class PredictionDetailPage extends StatefulWidget {
  const PredictionDetailPage({
    super.key,
    required this.predictionId,
    this.prediction,
  });
  final String predictionId;
  // Provided when navigating directly from a fresh prediction result,
  // avoiding a BLoC round-trip that races with the tab's list refresh.
  final Prediction? prediction;

  @override
  State<PredictionDetailPage> createState() => _PredictionDetailPageState();
}

class _PredictionDetailPageState extends State<PredictionDetailPage> {
  @override
  void initState() {
    super.initState();
    // Only fetch from the API when we don't already have the prediction object.
    if (widget.prediction == null) {
      context
          .read<PredictionBloc>()
          .add(PredictionDetailRequested(widget.predictionId));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Fast path: prediction was passed directly (e.g. from RequestPredictionPage).
    // Render immediately without waiting for BLoC state so the tab's concurrent
    // list-refresh cannot overwrite the state and lock the page on a spinner.
    if (widget.prediction != null) {
      return _DetailScaffold(prediction: widget.prediction!);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<PredictionBloc, PredictionState>(
        builder: (context, state) {
          if (state is PredictionsLoading) {
            return const _LoadingView();
          }
          if (state is PredictionDetailLoaded) {
            return _DetailScaffold(prediction: state.prediction);
          }
          if (state is PredictionFailure) {
            return _FullErrorView(message: state.message);
          }
          return const _LoadingView();
        },
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Loading & Error Scaffolds
// ──────────────────────────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(backgroundColor: AppColors.background, elevation: 0),
      body: const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }
}

class _FullErrorView extends StatelessWidget {
  const _FullErrorView({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(backgroundColor: AppColors.background, elevation: 0),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64.r, color: AppColors.danger),
              SizedBox(height: 16.h),
              Text('Unable to Load Prediction',
                  style: AppTypography.subtitle
                      .copyWith(fontWeight: FontWeight.w600)),
              SizedBox(height: 8.h),
              Text(message,
                  style:
                      AppTypography.body.copyWith(color: AppColors.neutral500),
                  textAlign: TextAlign.center),
              SizedBox(height: 24.h),
              OutlinedButton(
                onPressed: () => context.pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Main Detail Scaffold
// ──────────────────────────────────────────────────────────────────────────────

class _DetailScaffold extends StatelessWidget {
  const _DetailScaffold({required this.prediction});
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
        RiskLevel.medium => 'Moderate Overall Risk',
        RiskLevel.high => 'High Overall Risk — See a Doctor',
      };

  @override
  Widget build(BuildContext context) {
    final hasHighRisk = _overallRisk == RiskLevel.high;
    final date = DateFormat('MMMM d, yyyy').format(prediction.createdAt);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Health Risk Report', style: AppTypography.title),
        backgroundColor: AppColors.white,
        elevation: 0,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: Center(
              child: Text(date,
                  style: AppTypography.caption
                      .copyWith(color: AppColors.neutral500)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeroCard(
              color: _overallColor,
              label: _overallLabel,
              prediction: prediction,
            ),
            SizedBox(height: 24.h),
            _SectionHeader('Risk Assessment'),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                    child: _AnimatedRiskGauge(
                  label: 'Diabetes',
                  risk: prediction.diabetes,
                )),
                SizedBox(width: 10.w),
                Expanded(
                    child: _AnimatedRiskGauge(
                  label: 'Hypertension',
                  risk: prediction.hypertension,
                )),
                SizedBox(width: 10.w),
                Expanded(
                    child: _AnimatedRiskGauge(
                  label: 'CVD',
                  risk: prediction.cardiovascular,
                )),
              ],
            ),
            SizedBox(height: 24.h),
            _ContributingFactorsSection(prediction: prediction),
            if (prediction.recommendations != null) ...[
              SizedBox(height: 24.h),
              _SectionHeader('Recommendations'),
              SizedBox(height: 10.h),
              _RecommendationsCard(markdown: prediction.recommendations!),
            ],
            if (hasHighRisk) ...[
              SizedBox(height: 24.h),
              _BookAppointmentButton(),
            ],
            SizedBox(height: 16.h),
            _Footer(prediction: prediction),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Hero Card
// ──────────────────────────────────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.color,
    required this.label,
    required this.prediction,
  });
  final Color color;
  final String label;
  final Prediction prediction;

  @override
  Widget build(BuildContext context) {
    final confidenceColor = switch (prediction.confidenceLevel) {
      'high' => AppColors.success,
      'medium' => AppColors.warning,
      _ => AppColors.danger,
    };

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.12),
            color.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.monitor_heart, color: color, size: 22.r),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(label,
                    style: AppTypography.subtitle.copyWith(
                        color: color, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              _ConfidencePill(
                label: prediction.formattedConfidence,
                color: confidenceColor,
              ),
              SizedBox(width: 8.w),
              _ConfidencePill(
                label: '${prediction.dataPointsUsed} records',
                color: AppColors.info,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ConfidencePill extends StatelessWidget {
  const _ConfidencePill({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: AppTypography.caption
            .copyWith(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Animated Risk Gauge
// ──────────────────────────────────────────────────────────────────────────────

class _AnimatedRiskGauge extends StatelessWidget {
  const _AnimatedRiskGauge({required this.label, required this.risk});
  final String label;
  final DiseaseRisk risk;

  Color get _color => switch (risk.riskLevel) {
        RiskLevel.low => AppColors.success,
        RiskLevel.medium => AppColors.warning,
        RiskLevel.high => AppColors.danger,
      };

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.white,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 8.w),
        child: Column(
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: risk.riskScore / 100),
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return SizedBox(
                  width: 70.w,
                  height: 70.w,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: value,
                        backgroundColor: AppColors.neutral100,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(_color),
                        strokeWidth: 7,
                        strokeCap: StrokeCap.round,
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${(value * 100).toStringAsFixed(0)}%',
                            style: AppTypography.caption.copyWith(
                                fontWeight: FontWeight.w800,
                                color: _color,
                                fontSize: 13.sp),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            SizedBox(height: 10.h),
            Text(label,
                style: AppTypography.caption.copyWith(
                    fontSize: 11.sp,
                    color: AppColors.neutral700,
                    fontWeight: FontWeight.w500),
                textAlign: TextAlign.center),
            SizedBox(height: 3.h),
            Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: _color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(risk.riskLabel,
                  style: AppTypography.caption.copyWith(
                      fontWeight: FontWeight.w700,
                      color: _color,
                      fontSize: 10.sp),
                  textAlign: TextAlign.center),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Contributing Factors
// ──────────────────────────────────────────────────────────────────────────────

class _ContributingFactorsSection extends StatelessWidget {
  const _ContributingFactorsSection({required this.prediction});
  final Prediction prediction;

  @override
  Widget build(BuildContext context) {
    final entries = [
      ('Diabetes', prediction.diabetes),
      ('Hypertension', prediction.hypertension),
      ('Cardiovascular', prediction.cardiovascular),
    ].where((e) => e.$2.contributingFactors.isNotEmpty).toList();

    if (entries.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader('Contributing Factors'),
        SizedBox(height: 10.h),
        ...entries.map((entry) => _FactorTile(
              label: entry.$1,
              risk: entry.$2,
            )),
      ],
    );
  }
}

class _FactorTile extends StatelessWidget {
  const _FactorTile({required this.label, required this.risk});
  final String label;
  final DiseaseRisk risk;

  Color get _color => switch (risk.riskLevel) {
        RiskLevel.low => AppColors.success,
        RiskLevel.medium => AppColors.warning,
        RiskLevel.high => AppColors.danger,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.neutral100),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 2.h),
          childrenPadding:
              EdgeInsets.only(left: 14.w, right: 14.w, bottom: 12.h),
          leading: Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              color: _color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(_iconFor(label), color: _color, size: 16.r),
          ),
          title: Text(label,
              style: AppTypography.body.copyWith(fontWeight: FontWeight.w600)),
          subtitle: Text('${risk.riskLabel} risk · ${risk.contributingFactors.length} factor${risk.contributingFactors.length == 1 ? '' : 's'}',
              style: AppTypography.caption
                  .copyWith(color: AppColors.neutral500)),
          children: [
            Wrap(
              spacing: 6.w,
              runSpacing: 6.h,
              children: risk.contributingFactors
                  .map(
                    (f) => Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: _color.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20.r),
                        border:
                            Border.all(color: _color.withValues(alpha: 0.25)),
                      ),
                      child: Text(f,
                          style: AppTypography.caption
                              .copyWith(color: _color, fontSize: 11.sp)),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(String disease) {
    return switch (disease) {
      'Diabetes' => Icons.bloodtype_outlined,
      'Hypertension' => Icons.speed_outlined,
      _ => Icons.favorite_outline,
    };
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Recommendations
// ──────────────────────────────────────────────────────────────────────────────

class _RecommendationsCard extends StatelessWidget {
  const _RecommendationsCard({required this.markdown});
  final String markdown;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.neutral100),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: MarkdownBody(
          data: markdown,
          styleSheet: MarkdownStyleSheet(
            p: AppTypography.body.copyWith(height: 1.6),
            h3: AppTypography.subtitle.copyWith(fontWeight: FontWeight.w600),
            listBullet: AppTypography.body,
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Book Appointment Button
// ──────────────────────────────────────────────────────────────────────────────

class _BookAppointmentButton extends StatelessWidget {
  const _BookAppointmentButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded,
                  color: AppColors.danger, size: 20.r),
              SizedBox(width: 8.w),
              Text('Action Recommended',
                  style: AppTypography.body.copyWith(
                      color: AppColors.danger, fontWeight: FontWeight.w700)),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            'Your results indicate elevated risk. Consider booking an appointment with a doctor.',
            style:
                AppTypography.caption.copyWith(color: AppColors.neutral700),
          ),
          SizedBox(height: 12.h),
          FilledButton.icon(
            onPressed: () => context.go('/book'),
            icon: Icon(Icons.calendar_month_outlined, size: 18.r),
            label: const Text('Book an Appointment'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.danger,
              minimumSize: Size(double.infinity, 44.h),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r)),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Footer & Section Header
// ──────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title,
        style:
            AppTypography.subtitle.copyWith(fontWeight: FontWeight.w700));
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.prediction});
  final Prediction prediction;

  @override
  Widget build(BuildContext context) {
    return Text(
      'Model: ${prediction.modelVersion ?? 'v1.0'} · ${prediction.dataPointsUsed} records analyzed',
      style: AppTypography.caption.copyWith(color: AppColors.neutral500),
    );
  }
}
