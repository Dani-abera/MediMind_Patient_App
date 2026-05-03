import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../bloc/prediction/prediction_bloc.dart';
import '../bloc/prediction/prediction_event.dart';
import '../bloc/prediction/prediction_state.dart';

class RequestPredictionPage extends StatefulWidget {
  const RequestPredictionPage({super.key});

  @override
  State<RequestPredictionPage> createState() =>
      _RequestPredictionPageState();
}

class _RequestPredictionPageState extends State<RequestPredictionPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rotateController;
  Timer? _messageTimer;
  int _messageIndex = 0;
  bool _consentGiven = false;

  static const _processingMessages = [
    'Analyzing your vitals history...',
    'Running predictive models...',
    'Evaluating risk factors...',
    'Computing confidence scores...',
    'Generating recommendations...',
    'Almost done...',
  ];

  @override
  void initState() {
    super.initState();
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _rotateController.dispose();
    _messageTimer?.cancel();
    super.dispose();
  }

  void _startProcessing() {
    context.read<PredictionBloc>().add(const PredictionRequested());
    _messageTimer =
        Timer.periodic(const Duration(seconds: 2), (_) {
      if (mounted) {
        setState(() {
          _messageIndex =
              (_messageIndex + 1) % _processingMessages.length;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('AI Health Prediction', style: AppTypography.title),
        backgroundColor: AppColors.white,
        elevation: 0,
      ),
      body: BlocConsumer<PredictionBloc, PredictionState>(
        listener: (context, state) {
          if (state is PredictionSuccess) {
            _messageTimer?.cancel();
            context.pushReplacement(
                '${RouteNames.predictionDetail}/${state.prediction.id}');
          }
        },
        builder: (context, state) {
          if (state is PredictionProcessing) {
            return _ProcessingView(
              message: _processingMessages[_messageIndex],
              controller: _rotateController,
            );
          }
          if (state is PredictionInsufficientData) {
            return _InsufficientDataView(
              dataPoints: state.dataPointsUsed,
              canRequestPrediction: state.canRequestPrediction,
            );
          }
          if (state is PredictionFailure) {
            return _ErrorView(
              message: state.message,
              onRetry: _startProcessing,
            );
          }
          return _ConsentView(
            consentGiven: _consentGiven,
            onConsentChanged: (v) => setState(() => _consentGiven = v),
            onProceed: _consentGiven ? _startProcessing : null,
          );
        },
      ),
    );
  }
}

class _ConsentView extends StatelessWidget {
  const _ConsentView({
    required this.consentGiven,
    required this.onConsentChanged,
    required this.onProceed,
  });
  final bool consentGiven;
  final ValueChanged<bool> onConsentChanged;
  final VoidCallback? onProceed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(24.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.psychology, color: AppColors.info, size: 28.r),
                    SizedBox(width: 12.w),
                    Text('AI Analysis',
                        style: AppTypography.subtitle
                            .copyWith(fontWeight: FontWeight.w700)),
                  ],
                ),
                SizedBox(height: 12.h),
                Text(
                  'MediMind will analyze your health records to estimate your risk for:',
                  style: AppTypography.body,
                ),
                SizedBox(height: 12.h),
                _DiseaseRow(icon: Icons.bloodtype, label: 'Type 2 Diabetes'),
                _DiseaseRow(
                    icon: Icons.monitor_heart,
                    label: 'Hypertension'),
                _DiseaseRow(
                    icon: Icons.favorite,
                    label: 'Cardiovascular Disease'),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          _ConfidenceInfoCard(),
          SizedBox(height: 20.h),
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              'This prediction is for informational purposes only and does not '
              'constitute medical advice. Always consult a qualified healthcare '
              'professional for medical decisions.',
              style: AppTypography.caption
                  .copyWith(color: AppColors.neutral700),
            ),
          ),
          SizedBox(height: 20.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: consentGiven,
                onChanged: (v) => onConsentChanged(v ?? false),
                activeColor: AppColors.primary,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: GestureDetector(
                  onTap: () => onConsentChanged(!consentGiven),
                  child: Text(
                    'I understand this is AI-generated and not a medical diagnosis. '
                    'I consent to my health data being analyzed.',
                    style: AppTypography.caption,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          FilledButton(
            onPressed: onProceed,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: Size(double.infinity, 52.h),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r)),
              disabledBackgroundColor:
                  AppColors.neutral300,
            ),
            child: const Text('Run Prediction'),
          ),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }
}

class _DiseaseRow extends StatelessWidget {
  const _DiseaseRow({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        children: [
          Icon(icon, color: AppColors.info, size: 16.r),
          SizedBox(width: 8.w),
          Text(label, style: AppTypography.body),
        ],
      ),
    );
  }
}

class _ConfidenceInfoCard extends StatelessWidget {
  const _ConfidenceInfoCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.white,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Prediction Confidence',
                style: AppTypography.caption
                    .copyWith(fontWeight: FontWeight.w600)),
            SizedBox(height: 8.h),
            _ConfidenceRow('Low', '1–6 vital records', AppColors.danger),
            _ConfidenceRow('Medium', '7–29 records', AppColors.warning),
            _ConfidenceRow(
                'High', '30+ records', AppColors.success),
          ],
        ),
      ),
    );
  }
}

class _ConfidenceRow extends StatelessWidget {
  const _ConfidenceRow(this.level, this.desc, this.color);
  final String level;
  final String desc;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        children: [
          Container(
            width: 8.w,
            height: 8.h,
            decoration:
                BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 8.w),
          Text('$level – $desc',
              style: AppTypography.caption
                  .copyWith(color: AppColors.neutral700)),
        ],
      ),
    );
  }
}

class _ProcessingView extends StatelessWidget {
  const _ProcessingView({
    required this.message,
    required this.controller,
  });
  final String message;
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RotationTransition(
            turns: controller,
            child: Container(
              width: 80.w,
              height: 80.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0),
                    AppColors.primary,
                  ],
                ),
              ),
              child: Container(
                margin: EdgeInsets.all(6.r),
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.psychology,
                    color: AppColors.primary, size: 36.r),
              ),
            ),
          ),
          SizedBox(height: 32.h),
          Text('Analyzing your data',
              style: AppTypography.subtitle
                  .copyWith(fontWeight: FontWeight.w600)),
          SizedBox(height: 12.h),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: Text(
              message,
              key: ValueKey(message),
              style: AppTypography.body
                  .copyWith(color: AppColors.neutral500),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _InsufficientDataView extends StatelessWidget {
  const _InsufficientDataView({
    required this.dataPoints,
    required this.canRequestPrediction,
  });
  final int dataPoints;
  final bool canRequestPrediction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline,
                size: 72.r, color: AppColors.warning),
            SizedBox(height: 20.h),
            Text('Insufficient Data',
                style: AppTypography.headline
                    .copyWith(fontWeight: FontWeight.w700)),
            SizedBox(height: 12.h),
            Text(
              !canRequestPrediction
                  ? 'You currently do not have enough data to request a prediction. Please log more vitals.'
                  : (dataPoints == 0
                      ? 'Please log at least one vital record before requesting a prediction.'
                      : 'You have $dataPoints record${dataPoints == 1 ? '' : 's'}. '
                          'Log more vitals to improve prediction confidence.'),
              style: AppTypography.body
                  .copyWith(color: AppColors.neutral700),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32.h),
            OutlinedButton(
              onPressed: () => context.pop(),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(color: AppColors.primary),
                minimumSize: Size(200.w, 48.h),
              ),
              child: const Text('Log Vitals First'),
            ),
          ],
        ),
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64.r, color: AppColors.danger),
          SizedBox(height: 16.h),
          Text('Prediction Failed', style: AppTypography.subtitle),
          SizedBox(height: 8.h),
          Text(message,
              style:
                  AppTypography.body.copyWith(color: AppColors.neutral500),
              textAlign: TextAlign.center),
          SizedBox(height: 24.h),
          FilledButton(
            onPressed: onRetry,
            style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}
