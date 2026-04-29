import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/notification_item.dart';
import '../bloc/notifications_list_bloc.dart';
import '../bloc/notifications_list_event.dart';
import '../bloc/notifications_list_state.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    context
        .read<NotificationsListBloc>()
        .add(const NotificationsListRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Notifications', style: AppTypography.title),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.neutral900,
        elevation: 0,
        actions: [
          BlocBuilder<NotificationsListBloc, NotificationsListState>(
            builder: (context, state) {
              final hasUnread =
                  state.notifications.any((n) => !n.isRead);
              if (!hasUnread) return const SizedBox.shrink();
              return TextButton(
                onPressed: () => context
                    .read<NotificationsListBloc>()
                    .add(const NotificationsAllMarkedRead()),
                child: const Text('Mark all read'),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificationsListBloc, NotificationsListState>(
        builder: (context, state) {
          if (state.isLoading && state.notifications.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.errorMessage != null && state.notifications.isEmpty) {
            return _ErrorView(
              message: state.errorMessage!,
              onRetry: () => context
                  .read<NotificationsListBloc>()
                  .add(const NotificationsListRequested()),
            );
          }
          if (state.notifications.isEmpty) {
            return const _EmptyView();
          }
          return RefreshIndicator(
            onRefresh: () async => context
                .read<NotificationsListBloc>()
                .add(const NotificationsListRefreshed()),
            child: ListView.separated(
              itemCount: state.notifications.length,
              separatorBuilder: (_, __) =>
                  Divider(height: 1, color: AppColors.neutral300),
              itemBuilder: (_, i) {
                final item = state.notifications[i];
                return _NotificationTile(
                  item: item,
                  onTap: () {
                    if (!item.isRead) {
                      context
                          .read<NotificationsListBloc>()
                          .add(NotificationMarkedRead(item.id));
                    }
                    _handleDeepLink(context, item);
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _handleDeepLink(BuildContext context, NotificationItem item) {
    // Deep link handled by notification service; here we just mark read
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.item, required this.onTap});
  final NotificationItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: item.isRead
            ? Colors.transparent
            : AppColors.primary.withValues(alpha: 0.04),
        padding:
            EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _NotificationIcon(type: item.type),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(item.title,
                            style: AppTypography.body.copyWith(
                                fontWeight: item.isRead
                                    ? FontWeight.w400
                                    : FontWeight.w600)),
                      ),
                      if (!item.isRead)
                        Container(
                          width: 8.w,
                          height: 8.w,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(item.body,
                      style: AppTypography.caption,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  SizedBox(height: 4.h),
                  Text(
                    _formatTime(item.createdAt),
                    style: AppTypography.overline,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class _NotificationIcon extends StatelessWidget {
  const _NotificationIcon({required this.type});
  final String type;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (type) {
      'appointment_reminder' => (
          Icons.calendar_month_outlined,
          AppColors.info
        ),
      'queue_called' => (Icons.queue_outlined, AppColors.success),
      'prediction_ready' => (
          Icons.health_and_safety_outlined,
          AppColors.primary
        ),
      'medication_reminder' => (
          Icons.medication_outlined,
          AppColors.warning
        ),
      _ => (Icons.notifications_outlined, AppColors.neutral500),
    };
    return Container(
      width: 40.w,
      height: 40.w,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 20.sp, color: color),
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
          Icon(Icons.notifications_none_outlined,
              size: 64.sp, color: AppColors.neutral300),
          SizedBox(height: 16.h),
          Text('No notifications', style: AppTypography.subtitle),
          SizedBox(height: 8.h),
          Text("You're all caught up!", style: AppTypography.body),
        ],
      ),
    );
  }
}
