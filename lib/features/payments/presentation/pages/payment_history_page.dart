import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/payment_record.dart';
import '../bloc/payments_history_bloc.dart';
import '../bloc/payments_history_event.dart';
import '../bloc/payments_history_state.dart';

class PaymentHistoryPage extends StatefulWidget {
  const PaymentHistoryPage({super.key});

  @override
  State<PaymentHistoryPage> createState() => _PaymentHistoryPageState();
}

class _PaymentHistoryPageState extends State<PaymentHistoryPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context
        .read<PaymentsHistoryBloc>()
        .add(const PaymentsHistoryRequested());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context
          .read<PaymentsHistoryBloc>()
          .add(const PaymentsHistoryNextPageRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Payment History', style: AppTypography.title),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.neutral900,
        elevation: 0,
      ),
      body: BlocBuilder<PaymentsHistoryBloc, PaymentsHistoryState>(
        builder: (context, state) {
          if (state is PaymentsHistoryLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is PaymentsHistoryFailure) {
            return _ErrorView(
              message: state.message,
              onRetry: () => context
                  .read<PaymentsHistoryBloc>()
                  .add(const PaymentsHistoryRequested()),
            );
          }
          if (state is PaymentsHistoryLoaded) {
            if (state.records.isEmpty) return const _EmptyView();
            return RefreshIndicator(
              onRefresh: () async => context
                  .read<PaymentsHistoryBloc>()
                  .add(const PaymentsHistoryRefreshed()),
              child: ListView.separated(
                controller: _scrollController,
                padding: EdgeInsets.all(16.w),
                itemCount: state.records.length +
                    (state.isLoadingMore ? 1 : 0),
                separatorBuilder: (_, __) => SizedBox(height: 12.h),
                itemBuilder: (_, i) {
                  if (i >= state.records.length) {
                    return const Center(
                        child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ));
                  }
                  return _PaymentRecordCard(record: state.records[i]);
                },
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _PaymentRecordCard extends StatelessWidget {
  const _PaymentRecordCard({required this.record});
  final PaymentRecord record;

  @override
  Widget build(BuildContext context) {
    final (statusColor, statusLabel) = switch (record.status) {
      PaymentStatus.completed => (AppColors.success, 'Completed'),
      PaymentStatus.pending => (AppColors.warning, 'Pending'),
      PaymentStatus.failed => (AppColors.danger, 'Failed'),
      PaymentStatus.refunded => (AppColors.info, 'Refunded'),
    };

    return Container(
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
                child: Text(
                  '${record.currency} ${record.amount.toStringAsFixed(2)}',
                  style: AppTypography.title,
                ),
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
          if (record.doctorName != null) ...[
            SizedBox(height: 8.h),
            Text('Dr. ${record.doctorName}', style: AppTypography.body),
          ],
          if (record.appointmentSummary != null) ...[
            SizedBox(height: 4.h),
            Text(record.appointmentSummary!,
                style: AppTypography.caption),
          ],
          SizedBox(height: 8.h),
          Row(
            children: [
              Text(_formatDate(record.createdAt),
                  style: AppTypography.caption),
              const Spacer(),
              if (record.receiptUrl != null)
                TextButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.receipt_outlined, size: 14.sp),
                  label: const Text('Receipt'),
                  style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) =>
      '${dt.day}/${dt.month}/${dt.year}';
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
          Icon(Icons.error_outline, size: 48.sp, color: AppColors.neutral500),
          SizedBox(height: 12.h),
          Text(message,
              style: AppTypography.body, textAlign: TextAlign.center),
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
          Icon(Icons.receipt_long_outlined,
              size: 64.sp, color: AppColors.neutral300),
          SizedBox(height: 16.h),
          Text('No payments yet', style: AppTypography.subtitle),
        ],
      ),
    );
  }
}
