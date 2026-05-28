import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../bloc/trends/trends_bloc.dart';
import '../bloc/trends/trends_event.dart';
import '../bloc/trends/trends_state.dart';
import '../../domain/entities/health_trend.dart';

class TrendsDetailPage extends StatefulWidget {
  const TrendsDetailPage({super.key});

  @override
  State<TrendsDetailPage> createState() => _TrendsDetailPageState();
}

class _TrendsDetailPageState extends State<TrendsDetailPage> {
  int _selectedDays = 30;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<TrendsBloc>().add(TrendsRequested(days: _selectedDays));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Trends', style: AppTypography.title),
        backgroundColor: AppColors.white,
        elevation: 0,
        actions: [
          _PeriodSelector(
            selected: _selectedDays,
            onChanged: (days) {
              setState(() => _selectedDays = days);
              context
                  .read<TrendsBloc>()
                  .add(TrendsPeriodChanged(days));
            },
          ),
        ],
      ),
      body: BlocBuilder<TrendsBloc, TrendsState>(
        builder: (context, state) {
          if (state is TrendsLoading) {
            return const Center(
                child:
                    CircularProgressIndicator(color: AppColors.primary));
          }
          if (state is TrendsFailure) {
            return Center(child: Text(state.message));
          }
          if (state is TrendsLoaded) {
            return _TrendsContent(data: state.data);
          }
          return const Center(
              child: CircularProgressIndicator(color: AppColors.primary));
        },
      ),
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({required this.selected, required this.onChanged});
  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 8.w),
      child: Row(
        children: [7, 30, 90].map((days) {
          final isSelected = selected == days;
          return GestureDetector(
            onTap: () => onChanged(days),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 2.w),
              padding:
                  EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.neutral100,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                '${days}d',
                style: AppTypography.caption.copyWith(
                  color: isSelected ? AppColors.white : AppColors.neutral500,
                  fontWeight: FontWeight.w600,
                  fontSize: 11.sp,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _TrendsContent extends StatelessWidget {
  const _TrendsContent({required this.data});
  final HealthTrendsData data;

  @override
  Widget build(BuildContext context) {
    final metrics = [
      if (data.systolic != null)
        _MetricConfig(
            trend: data.systolic!,
            label: 'Systolic BP',
            color: AppColors.danger),
      if (data.diastolic != null)
        _MetricConfig(
            trend: data.diastolic!,
            label: 'Diastolic BP',
            color: AppColors.warning),
      if (data.glucose != null)
        _MetricConfig(
            trend: data.glucose!,
            label: 'Blood Glucose',
            color: AppColors.info),
      if (data.heartRate != null)
        _MetricConfig(
            trend: data.heartRate!,
            label: 'Heart Rate',
            color: AppColors.accent),
      if (data.temperature != null)
        _MetricConfig(
            trend: data.temperature!,
            label: 'Temperature',
            color: AppColors.warning),
      if (data.oxygenSaturation != null)
        _MetricConfig(
            trend: data.oxygenSaturation!,
            label: 'SpO₂',
            color: AppColors.primary),
      if (data.weight != null)
        _MetricConfig(
            trend: data.weight!,
            label: 'Weight',
            color: AppColors.neutral700),
    ];

    if (metrics.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.show_chart, size: 64.r, color: AppColors.neutral300),
            SizedBox(height: 16.h),
            Text('No trend data available', style: AppTypography.subtitle),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.r),
      itemCount: metrics.length,
      itemBuilder: (context, i) => _TrendCard(config: metrics[i]),
    );
  }
}

class _MetricConfig {
  const _MetricConfig({
    required this.trend,
    required this.label,
    required this.color,
  });
  final HealthTrend trend;
  final String label;
  final Color color;
}

class _TrendCard extends StatelessWidget {
  const _TrendCard({required this.config});
  final _MetricConfig config;

  @override
  Widget build(BuildContext context) {
    final trend = config.trend;
    final points = trend.points;

    return Card(
      elevation: 0,
      color: AppColors.white,
      margin: EdgeInsets.only(bottom: 16.h),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(config.label,
                    style: AppTypography.body
                        .copyWith(fontWeight: FontWeight.w600)),
                Row(
                  children: [
                    _TrendArrow(direction: trend.trendDirection,
                        color: config.color),
                    SizedBox(width: 4.w),
                    Text(
                      '${trend.average.toStringAsFixed(1)} ${trend.unit}',
                      style: AppTypography.caption
                          .copyWith(color: AppColors.neutral500),
                    ),
                  ],
                ),
              ],
            ),
            if (trend.insight != null) ...[
              SizedBox(height: 4.h),
              Text(trend.insight!,
                  style: AppTypography.caption
                      .copyWith(color: AppColors.neutral500)),
            ],
            SizedBox(height: 16.h),
            SizedBox(
              height: 150.h,
              child: points.length < 2
                  ? Center(
                      child: Text('Not enough data',
                          style: AppTypography.caption
                              .copyWith(color: AppColors.neutral300)))
                  : LineChart(_buildChart(trend, config.color)),
            ),
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatLabel('Min', trend.minimum.toStringAsFixed(1)),
                _StatLabel('Avg', trend.average.toStringAsFixed(1)),
                _StatLabel('Max', trend.maximum.toStringAsFixed(1)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  LineChartData _buildChart(HealthTrend trend, Color color) {
    final spots = trend.points
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.value))
        .toList();

    final minY = trend.minimum - (trend.maximum - trend.minimum) * 0.1;
    final maxY = trend.maximum + (trend.maximum - trend.minimum) * 0.1;

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawHorizontalLine: true,
        drawVerticalLine: false,
        horizontalInterval: (maxY - minY) / 4,
        getDrawingHorizontalLine: (_) => FlLine(
          color: AppColors.neutral300,
          strokeWidth: 0.5,
        ),
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 36.w,
            interval: (maxY - minY) / 4,
            getTitlesWidget: (value, meta) => Text(
              value.toStringAsFixed(0),
              style: AppTypography.caption
                  .copyWith(fontSize: 9.sp, color: AppColors.neutral500),
            ),
          ),
        ),
        bottomTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: (spots.length - 1).toDouble(),
      minY: minY,
      maxY: maxY,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: color,
          barWidth: 2.5,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: spots.length <= 10,
            getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
              radius: 3,
              color: color,
              strokeColor: Colors.white,
              strokeWidth: 1.5,
            ),
          ),
          belowBarData: BarAreaData(
            show: true,
            color: color.withValues(alpha: 0.08),
          ),
        ),
      ],
      // Shaded normal band
      extraLinesData: (trend.normalMin != null && trend.normalMax != null)
          ? ExtraLinesData(
              horizontalLines: [
                HorizontalLine(
                  y: trend.normalMin!,
                  color: AppColors.success.withValues(alpha: 0.3),
                  strokeWidth: 1,
                  dashArray: [4, 4],
                ),
                HorizontalLine(
                  y: trend.normalMax!,
                  color: AppColors.success.withValues(alpha: 0.3),
                  strokeWidth: 1,
                  dashArray: [4, 4],
                ),
              ],
            )
          : null,
    );
  }
}

class _TrendArrow extends StatelessWidget {
  const _TrendArrow({required this.direction, required this.color});
  final String direction;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final icon = switch (direction) {
      'increasing' => Icons.trending_up,
      'decreasing' => Icons.trending_down,
      _ => Icons.trending_flat,
    };
    return Icon(icon, color: color, size: 18.r);
  }
}

class _StatLabel extends StatelessWidget {
  const _StatLabel(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label,
            style: AppTypography.caption
                .copyWith(color: AppColors.neutral500, fontSize: 10.sp)),
        Text(value,
            style: AppTypography.body
                .copyWith(fontWeight: FontWeight.w600, fontSize: 13.sp)),
      ],
    );
  }
}
