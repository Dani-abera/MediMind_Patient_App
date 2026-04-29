import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/prediction.dart';
import '../bloc/prediction/prediction_bloc.dart';
import '../bloc/prediction/prediction_event.dart';
import '../bloc/prediction/prediction_state.dart';

class PredictionDetailPage extends StatefulWidget {
  const PredictionDetailPage({super.key, required this.predictionId});
  final String predictionId;

  @override
  State<PredictionDetailPage> createState() =>
      _PredictionDetailPageState();
}

class _PredictionDetailPageState extends State<PredictionDetailPage> {
  @override
  void initState() {
    super.initState();
    context
        .read<PredictionBloc>()
        .add(PredictionDetailRequested(widget.predictionId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Prediction Results', style: AppTypography.title),
        backgroundColor: AppColors.white,
        elevation: 0,
      ),
      body: BlocBuilder<PredictionBloc, PredictionState>(
        builder: (context, state) {
          if (state is PredictionsLoading) {
            return const Center(
                child:
                    CircularProgressIndicator(color: AppColors.primary));
          }
          if (state is PredictionDetailLoaded) {
            return _DetailContent(prediction: state.prediction);
          }
          if (state is PredictionSuccess) {
            return _DetailContent(prediction: state.prediction);
          }
          if (state is PredictionFailure) {
            return Center(child: Text(state.message));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _DetailContent extends StatelessWidget {
  const _DetailContent({required this.prediction});
  final Prediction prediction;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ConfidenceBanner(prediction: prediction),
          SizedBox(height: 20.h),
          Text('Risk Assessment',
              style: AppTypography.subtitle
                  .copyWith(fontWeight: FontWeight.w700)),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                  child: _RiskGauge(
                label: 'Diabetes',
                risk: prediction.diabetes,
              )),
              SizedBox(width: 12.w),
              Expanded(
                  child: _RiskGauge(
                label: 'Hypertension',
                risk: prediction.hypertension,
              )),
              SizedBox(width: 12.w),
              Expanded(
                  child: _RiskGauge(
                label: 'CVD',
                risk: prediction.cardiovascular,
              )),
            ],
          ),
          SizedBox(height: 24.h),
          _ContributingFactorsSection(prediction: prediction),
          if (prediction.recommendations != null) ...[
            SizedBox(height: 24.h),
            _RecommendationsSection(
                markdown: prediction.recommendations!),
          ],
          SizedBox(height: 16.h),
          Text(
            'Model: ${prediction.modelVersion ?? 'v1.0'} · '
            '${prediction.dataPointsUsed} records analyzed',
            style: AppTypography.caption
                .copyWith(color: AppColors.neutral300),
          ),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }
}

class _ConfidenceBanner extends StatelessWidget {
  const _ConfidenceBanner({required this.prediction});
  final Prediction prediction;

  @override
  Widget build(BuildContext context) {
    final color = switch (prediction.confidenceLevel) {
      'high' => AppColors.success,
      'medium' => AppColors.warning,
      _ => AppColors.danger,
    };
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.insights, color: color, size: 24.r),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(prediction.formattedConfidence,
                  style: AppTypography.body.copyWith(
                      color: color, fontWeight: FontWeight.w600)),
              Text(
                '${prediction.dataPointsUsed} data points used',
                style: AppTypography.caption
                    .copyWith(color: AppColors.neutral500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RiskGauge extends StatelessWidget {
  const _RiskGauge({required this.label, required this.risk});
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
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(12.r),
        child: Column(
          children: [
            SizedBox(
              width: 72.w,
              height: 72.h,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: risk.riskScore / 100,
                    backgroundColor: AppColors.neutral100,
                    valueColor: AlwaysStoppedAnimation<Color>(_color),
                    strokeWidth: 7,
                    strokeCap: StrokeCap.round,
                  ),
                  Text(
                    '${risk.riskScore.toStringAsFixed(0)}%',
                    style: AppTypography.caption.copyWith(
                        fontWeight: FontWeight.w700, color: _color),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8.h),
            Text(label,
                style: AppTypography.caption.copyWith(
                    fontSize: 11.sp, color: AppColors.neutral700),
                textAlign: TextAlign.center),
            SizedBox(height: 2.h),
            Text(risk.riskLabel,
                style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.w600, color: _color),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _ContributingFactorsSection extends StatelessWidget {
  const _ContributingFactorsSection({required this.prediction});
  final Prediction prediction;

  @override
  Widget build(BuildContext context) {
    final allFactors = {
      'Diabetes': prediction.diabetes.contributingFactors,
      'Hypertension': prediction.hypertension.contributingFactors,
      'Cardiovascular': prediction.cardiovascular.contributingFactors,
    }.entries.where((e) => e.value.isNotEmpty).toList();

    if (allFactors.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Contributing Factors',
            style: AppTypography.subtitle
                .copyWith(fontWeight: FontWeight.w700)),
        SizedBox(height: 8.h),
        ...allFactors.map(
          (entry) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(entry.key,
                  style: AppTypography.caption.copyWith(
                      color: AppColors.neutral500,
                      fontWeight: FontWeight.w600)),
              SizedBox(height: 4.h),
              Wrap(
                spacing: 6.w,
                runSpacing: 4.h,
                children: entry.value
                    .map((f) => Chip(
                          label: Text(f,
                              style: AppTypography.caption
                                  .copyWith(fontSize: 11.sp)),
                          backgroundColor:
                              AppColors.neutral100,
                          padding: EdgeInsets.zero,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ))
                    .toList(),
              ),
              SizedBox(height: 8.h),
            ],
          ),
        ),
      ],
    );
  }
}

class _RecommendationsSection extends StatelessWidget {
  const _RecommendationsSection({required this.markdown});
  final String markdown;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recommendations',
            style: AppTypography.subtitle
                .copyWith(fontWeight: FontWeight.w700)),
        SizedBox(height: 8.h),
        Card(
          elevation: 0,
          color: AppColors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r)),
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: MarkdownBody(
              data: markdown,
              styleSheet: MarkdownStyleSheet(
                p: AppTypography.body,
                h3: AppTypography.subtitle
                    .copyWith(fontWeight: FontWeight.w600),
                listBullet: AppTypography.body,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
