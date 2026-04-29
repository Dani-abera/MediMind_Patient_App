import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/queue_status.dart';
import '../bloc/queue_bloc.dart';
import '../bloc/queue_event.dart';
import '../bloc/queue_state.dart';

class QueueStatusPage extends StatefulWidget {
  const QueueStatusPage({super.key, required this.appointmentId});
  final String appointmentId;

  @override
  State<QueueStatusPage> createState() => _QueueStatusPageState();
}

class _QueueStatusPageState extends State<QueueStatusPage>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    context
        .read<QueueBloc>()
        .add(QueueStatusOpened(widget.appointmentId));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    context.read<QueueBloc>().add(const QueueClosed());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<QueueBloc, QueueState>(
      listener: (context, state) {
        if (state is QueueCalled) {
          HapticFeedback.heavyImpact();
        } else if (state is QueueCancelled) {
          context.pop();
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text('Queue Status', style: AppTypography.title),
            backgroundColor: AppColors.white,
            elevation: 0,
            actions: [
              if (state is QueueConnected && state.isPolling)
                Padding(
                  padding: EdgeInsets.only(right: 12.w),
                  child: Tooltip(
                    message: 'Live updates unavailable — polling',
                    child: Icon(Icons.wifi_off,
                        color: AppColors.warning, size: 20.r),
                  ),
                ),
            ],
          ),
          body: switch (state) {
            QueueConnecting() => const _LoadingView(),
            QueueConnected(:final status, :final isPolling) =>
              _ConnectedView(
                status: status,
                isPolling: isPolling,
                pulseAnim: _pulseAnim,
                onCancel: () => _showCancelDialog(context),
              ),
            QueueCalled(:final queueNumber, :final roomNumber) =>
              _CalledView(
                queueNumber: queueNumber,
                roomNumber: roomNumber,
              ),
            QueueCancelled() => const _LoadingView(),
            QueueDisconnectedState() => _DisconnectedView(
                onRetry: () => context
                    .read<QueueBloc>()
                    .add(QueueStatusOpened(widget.appointmentId)),
              ),
            QueueError(:final message) =>
              _ErrorView(message: message),
            _ => const _LoadingView(),
          },
        );
      },
    );
  }

  Future<void> _showCancelDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancel Queue Position?'),
        content: const Text(
            'You will lose your current position in the queue.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Keep Position')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Cancel', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<QueueBloc>().add(const QueueCancelRequested());
    }
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(color: AppColors.primary),
    );
  }
}

class _ConnectedView extends StatelessWidget {
  const _ConnectedView({
    required this.status,
    required this.isPolling,
    required this.pulseAnim,
    required this.onCancel,
  });

  final QueueStatus status;
  final bool isPolling;
  final Animation<double> pulseAnim;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final isWaiting = status.status == QueueStatusType.waiting;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Connection indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 8.r,
              height: 8.r,
              decoration: BoxDecoration(
                color: isPolling ? AppColors.warning : AppColors.success,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 6.w),
            Text(
              isPolling ? 'Polling mode' : 'Live',
              style: AppTypography.caption
                  .copyWith(color: AppColors.neutral700),
            ),
          ],
        ),
        SizedBox(height: 32.h),
        // Pulsing position circle
        ScaleTransition(
          scale: pulseAnim,
          child: Container(
            width: 160.r,
            height: 160.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.12),
              border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.4), width: 3),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '#${status.position}',
                  style: AppTypography.headline.copyWith(
                    color: AppColors.primary,
                    fontSize: 48.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Your Position',
                  style: AppTypography.caption
                      .copyWith(color: AppColors.neutral700),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 32.h),
        // Wait time
        Text(
          isWaiting
              ? 'Est. wait: ${status.estimatedWaitMinutes} min'
              : _statusLabel(status.status),
          style: AppTypography.body.copyWith(color: AppColors.neutral700),
        ),
        SizedBox(height: 8.h),
        // Queue number chip
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: AppColors.neutral100,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Text(
            'Queue #${status.queueNumber}',
            style: AppTypography.caption
                .copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        SizedBox(height: 48.h),
        // Cancel button
        TextButton(
          onPressed: onCancel,
          child: Text(
            'Leave Queue',
            style: AppTypography.body.copyWith(color: AppColors.danger),
          ),
        ),
      ],
    );
  }

  String _statusLabel(QueueStatusType s) => switch (s) {
        QueueStatusType.called => 'You are being called!',
        QueueStatusType.completed => 'Completed',
        QueueStatusType.cancelled => 'Cancelled',
        _ => 'Waiting',
      };
}

class _CalledView extends StatelessWidget {
  const _CalledView({required this.queueNumber, this.roomNumber});
  final int queueNumber;
  final String? roomNumber;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_active,
              color: Colors.white, size: 80.r),
          SizedBox(height: 24.h),
          Text(
            "It's Your Turn!",
            style: AppTypography.headline
                .copyWith(color: Colors.white, fontSize: 28.sp),
          ),
          SizedBox(height: 12.h),
          Text(
            'Queue #$queueNumber',
            style: AppTypography.body
                .copyWith(color: Colors.white.withValues(alpha: 0.85)),
          ),
          if (roomNumber != null) ...[
            SizedBox(height: 8.h),
            Text(
              'Please proceed to Room $roomNumber',
              style: AppTypography.body
                  .copyWith(color: Colors.white.withValues(alpha: 0.85)),
            ),
          ],
          SizedBox(height: 48.h),
          FilledButton(
            onPressed: () => context.pop(),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              minimumSize: Size(200.w, 48.h),
            ),
            child: const Text('Dismiss'),
          ),
        ],
      ),
    );
  }
}

class _DisconnectedView extends StatelessWidget {
  const _DisconnectedView({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.signal_wifi_off,
              color: AppColors.neutral500, size: 64.r),
          SizedBox(height: 16.h),
          Text('Connection lost',
              style: AppTypography.body
                  .copyWith(color: AppColors.neutral700)),
          SizedBox(height: 24.h),
          FilledButton(
            onPressed: onRetry,
            style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: Text(message,
            style: AppTypography.body.copyWith(color: AppColors.danger),
            textAlign: TextAlign.center),
      ),
    );
  }
}
