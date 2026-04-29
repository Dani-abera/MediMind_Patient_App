import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/prescription.dart';
import '../bloc/prescriptions_bloc.dart';
import '../bloc/prescriptions_event.dart';
import '../bloc/prescriptions_state.dart';

class PrescriptionsListPage extends StatefulWidget {
  const PrescriptionsListPage({super.key});

  @override
  State<PrescriptionsListPage> createState() => _PrescriptionsListPageState();
}

class _PrescriptionsListPageState extends State<PrescriptionsListPage> {
  PrescriptionStatus? _filter;

  @override
  void initState() {
    super.initState();
    context.read<PrescriptionsBloc>().add(const PrescriptionsRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Prescriptions', style: AppTypography.title),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.neutral900,
        elevation: 0,
        actions: [
          PopupMenuButton<PrescriptionStatus?>(
            icon: const Icon(Icons.filter_list_rounded),
            onSelected: (v) => setState(() => _filter = v),
            itemBuilder: (_) => [
              const PopupMenuItem(value: null, child: Text('All')),
              const PopupMenuItem(
                  value: PrescriptionStatus.active, child: Text('Active')),
              const PopupMenuItem(
                  value: PrescriptionStatus.expired, child: Text('Expired')),
              const PopupMenuItem(
                  value: PrescriptionStatus.dispensed,
                  child: Text('Dispensed')),
            ],
          ),
        ],
      ),
      body: BlocBuilder<PrescriptionsBloc, PrescriptionsState>(
        builder: (context, state) {
          if (state is PrescriptionsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is PrescriptionsFailure) {
            return _ErrorView(
              message: state.message,
              onRetry: () => context
                  .read<PrescriptionsBloc>()
                  .add(const PrescriptionsRequested()),
            );
          }
          if (state is PrescriptionsLoaded) {
            final items = _filter == null
                ? state.prescriptions
                : state.prescriptions
                    .where((p) => p.status == _filter)
                    .toList();
            if (items.isEmpty) {
              return const _EmptyView();
            }
            return RefreshIndicator(
              onRefresh: () async => context
                  .read<PrescriptionsBloc>()
                  .add(const PrescriptionsRefreshed()),
              child: ListView.separated(
                padding: EdgeInsets.all(16.w),
                itemCount: items.length,
                separatorBuilder: (_, __) => SizedBox(height: 12.h),
                itemBuilder: (_, i) => _PrescriptionCard(
                  prescription: items[i],
                  onTap: () =>
                      context.pushNamed(RouteNames.prescriptionDetail,
                          pathParameters: {'id': items[i].id}),
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _PrescriptionCard extends StatelessWidget {
  const _PrescriptionCard(
      {required this.prescription, required this.onTap});

  final Prescription prescription;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (prescription.status) {
      PrescriptionStatus.active => AppColors.success,
      PrescriptionStatus.expired => AppColors.danger,
      PrescriptionStatus.dispensed => AppColors.neutral500,
    };
    final statusLabel = switch (prescription.status) {
      PrescriptionStatus.active => 'Active',
      PrescriptionStatus.expired => 'Expired',
      PrescriptionStatus.dispensed => 'Dispensed',
    };

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.neutral900.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(prescription.referenceNumber,
                      style: AppTypography.subtitle),
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(statusLabel,
                      style: AppTypography.caption
                          .copyWith(color: statusColor)),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(prescription.diagnosis, style: AppTypography.body),
            SizedBox(height: 4.h),
            Text('Dr. ${prescription.doctorName}',
                style: AppTypography.caption),
            SizedBox(height: 4.h),
            Text(
              '${prescription.medications.length} medication${prescription.medications.length == 1 ? '' : 's'}',
              style: AppTypography.caption,
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline,
              size: 48.sp, color: AppColors.neutral500),
          SizedBox(height: 12.h),
          Text(message, style: AppTypography.body, textAlign: TextAlign.center),
          SizedBox(height: 16.h),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.description_outlined,
              size: 64.sp, color: AppColors.neutral300),
          SizedBox(height: 16.h),
          Text('No prescriptions yet', style: AppTypography.subtitle),
          SizedBox(height: 8.h),
          Text('Your prescriptions will appear here',
              style: AppTypography.body),
        ],
      ),
    );
  }
}
