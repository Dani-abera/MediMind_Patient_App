import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../../../core/routing/route_names.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../../../../health_records/domain/entities/health_record.dart';
import '../../../../health_records/presentation/bloc/vitals/vitals_bloc.dart';
import '../../../../health_records/presentation/bloc/vitals/vitals_event.dart';
import '../../../../health_records/presentation/bloc/vitals/vitals_state.dart';

class VitalsTab extends StatelessWidget {
  const VitalsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VitalsBloc, VitalsState>(
      builder: (context, state) {
        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async =>
              context.read<VitalsBloc>().add(const VitalsRefreshed()),
          child: switch (state) {
            VitalsInitial() || VitalsLoading() => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            VitalsFailure(:final message) => _ErrorView(
                message: message,
                onRetry: () => context
                    .read<VitalsBloc>()
                    .add(const VitalsRequested()),
              ),
            VitalsLoaded() => _VitalsContent(state: state),
            _ => const SizedBox.shrink(),
          },
        );
      },
    );
  }
}

class _VitalsContent extends StatelessWidget {
  const _VitalsContent({required this.state});
  final VitalsLoaded state;

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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${state.totalCount} Records',
                      style: AppTypography.caption.copyWith(
                          color: AppColors.neutral500),
                    ),
                    Row(
                      children: [
                        TextButton.icon(
                          onPressed: () =>
                              context.push(RouteNames.trendsDetail),
                          icon: Icon(Icons.show_chart, size: 16.r),
                          label: const Text('Trends'),
                          style: TextButton.styleFrom(
                              foregroundColor: AppColors.primary),
                        ),
                        SizedBox(width: 8.w),
                        FilledButton.icon(
                          onPressed: () =>
                              context.push(RouteNames.logVitals),
                          icon: Icon(Icons.add, size: 16.r),
                          label: const Text('Log'),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.w, vertical: 8.h),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (state.latestRecord != null) ...[
                  SizedBox(height: 16.h),
                  _LatestVitalsSummary(record: state.latestRecord!),
                ],
              ],
            ),
          ),
        ),
        if (state.records.isEmpty)
          SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.monitor_heart_outlined,
                      size: 64.r, color: AppColors.neutral300),
                  SizedBox(height: 16.h),
                  Text('No vitals logged yet',
                      style: AppTypography.subtitle),
                  SizedBox(height: 8.h),
                  Text('Tap "Log" to record your first vitals',
                      style: AppTypography.caption
                          .copyWith(color: AppColors.neutral500)),
                ],
              ),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _VitalRecordTile(
                  record: state.records[index]),
              childCount: state.records.length,
            ),
          ),
      ],
    );
  }
}

class _LatestVitalsSummary extends StatelessWidget {
  const _LatestVitalsSummary({required this.record});
  final HealthRecord record;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.primary.withValues(alpha: 0.06),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Latest Reading',
                style: AppTypography.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600)),
            SizedBox(height: 12.h),
            Wrap(
              spacing: 12.w,
              runSpacing: 8.h,
              children: [
                if (record.bloodPressureSystolic != null)
                  _VitalChip(
                    label: 'BP',
                    value:
                        '${record.bloodPressureSystolic!.toInt()}/${record.bloodPressureDiastolic?.toInt() ?? '–'}',
                    unit: 'mmHg',
                    status: record.bpStatus,
                  ),
                if (record.glucoseLevel != null)
                  _VitalChip(
                    label: 'Glucose',
                    value: record.glucoseLevel!.toStringAsFixed(0),
                    unit: 'mg/dL',
                    status: record.glucoseStatus,
                  ),
                if (record.heartRate != null)
                  _VitalChip(
                    label: 'Heart Rate',
                    value: record.heartRate!.toStringAsFixed(0),
                    unit: 'bpm',
                    status: record.heartRateStatus,
                  ),
                if (record.oxygenSaturation != null)
                  _VitalChip(
                    label: 'SpO₂',
                    value: record.oxygenSaturation!.toStringAsFixed(0),
                    unit: '%',
                    status: record.oxygenStatus,
                  ),
                if (record.temperature != null)
                  _VitalChip(
                    label: 'Temp',
                    value: record.temperature!.toStringAsFixed(1),
                    unit: '°C',
                    status: record.tempStatus,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _VitalChip extends StatelessWidget {
  const _VitalChip({
    required this.label,
    required this.value,
    required this.unit,
    required this.status,
  });
  final String label;
  final String value;
  final String unit;
  final VitalStatus status;

  Color get _statusColor => switch (status) {
        VitalStatus.normal => AppColors.success,
        VitalStatus.watch => AppColors.warning,
        VitalStatus.alert => AppColors.danger,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: _statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: _statusColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: AppTypography.caption.copyWith(
                  fontSize: 10.sp, color: AppColors.neutral500)),
          Text('$value $unit',
              style: AppTypography.body.copyWith(
                  fontWeight: FontWeight.w600, color: _statusColor)),
        ],
      ),
    );
  }
}

class _VitalRecordTile extends StatelessWidget {
  const _VitalRecordTile({required this.record});
  final HealthRecord record;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      elevation: 0,
      color: AppColors.white,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(12.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDate(record.recordedAt),
                  style: AppTypography.caption.copyWith(
                      color: AppColors.neutral500),
                ),
                if (record.isToday)
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 8.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text('Today',
                        style: AppTypography.caption.copyWith(
                            color: AppColors.primary, fontSize: 10.sp)),
                  ),
              ],
            ),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 4.h,
              children: [
                if (record.bloodPressureSystolic != null)
                  _miniTag(
                      'BP ${record.bloodPressureSystolic!.toInt()}/${record.bloodPressureDiastolic?.toInt() ?? '–'}',
                      record.bpStatus),
                if (record.glucoseLevel != null)
                  _miniTag('Glc ${record.glucoseLevel!.toStringAsFixed(0)}',
                      record.glucoseStatus),
                if (record.heartRate != null)
                  _miniTag(
                      'HR ${record.heartRate!.toStringAsFixed(0)}',
                      record.heartRateStatus),
                if (record.oxygenSaturation != null)
                  _miniTag(
                      'O₂ ${record.oxygenSaturation!.toStringAsFixed(0)}%',
                      record.oxygenStatus),
                if (record.temperature != null)
                  _miniTag(
                      'T ${record.temperature!.toStringAsFixed(1)}°C',
                      record.tempStatus),
                if (record.weight != null)
                  _miniTag('${record.weight!.toStringAsFixed(1)} kg',
                      VitalStatus.normal),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniTag(String text, VitalStatus status) {
    final color = switch (status) {
      VitalStatus.normal => AppColors.success,
      VitalStatus.watch => AppColors.warning,
      VitalStatus.alert => AppColors.danger,
    };
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(text,
          style: AppTypography.caption
              .copyWith(fontSize: 11.sp, color: color)),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour < 12 ? 'AM' : 'PM';
    return '${months[dt.month - 1]} ${dt.day}, $h:$m $period';
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
