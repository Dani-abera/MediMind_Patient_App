import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../appointments/presentation/bloc/booking_flow/booking_flow_bloc.dart';
import '../../../appointments/presentation/bloc/booking_flow/booking_flow_event.dart';
import '../../domain/entities/payment.dart';
import '../../domain/usecases/get_payment_status_usecase.dart';

class PaymentWebViewPage extends StatefulWidget {
  const PaymentWebViewPage({
    super.key,
    required this.checkoutUrl,
    required this.paymentId,
  });

  final String checkoutUrl;
  final String paymentId;

  @override
  State<PaymentWebViewPage> createState() => _PaymentWebViewPageState();
}

class _PaymentWebViewPageState extends State<PaymentWebViewPage> {
  late final WebViewController _controller;
  bool _isLoading = true;
  Timer? _pollTimer;
  int _pollCount = 0;
  static const _maxPolls = 10;
  static const _pollInterval = Duration(seconds: 3);

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _isLoading = true),
          onPageFinished: (_) => setState(() => _isLoading = false),
          onUrlChange: (change) {
            final url = change.url ?? '';
            if (url.contains('/payment/success')) {
              _onSuccess();
            } else if (url.contains('/payment/failed')) {
              _onFailed();
            } else if (url.contains('/payment/cancelled')) {
              _onCancelled();
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));
    _startPolling();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollTimer = Timer.periodic(_pollInterval, (_) async {
      if (_pollCount >= _maxPolls) {
        _pollTimer?.cancel();
        return;
      }
      _pollCount++;
      final result =
          await sl<GetPaymentStatusUsecase>()(widget.paymentId);
      result.fold((_) {}, (payment) {
        if (payment.status == PaymentStatus.completed) {
          _pollTimer?.cancel();
          _onSuccess();
        } else if (payment.status == PaymentStatus.failed) {
          _pollTimer?.cancel();
          _onFailed();
        }
      });
    });
  }

  void _onSuccess() {
    if (!mounted) return;
    context
        .read<BookingFlowBloc>()
        .add(const PaymentCompleted());
    context.pushReplacementNamed(RouteNames.appointmentSuccess);
  }

  void _onFailed() {
    if (!mounted) return;
    _showResultDialog(
      title: 'Payment Failed',
      message: 'Your payment could not be processed.',
      onRetry: () {
        Navigator.of(context).pop();
        _pollCount = 0;
        _controller.loadRequest(Uri.parse(widget.checkoutUrl));
      },
    );
  }

  void _onCancelled() {
    if (!mounted) return;
    context.pop();
  }

  Future<void> _showResultDialog({
    required String title,
    required String message,
    VoidCallback? onRetry,
  }) async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          if (onRetry != null)
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.pop();
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<bool> _confirmCancel() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancel Payment?'),
        content: const Text(
            'Your booking is reserved. You can complete payment later.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Stay'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Leave',
                style:
                    TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final router = GoRouter.of(context);
        if (await _confirmCancel()) {
          if (mounted) router.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.background,
          surfaceTintColor: Colors.transparent,
          title: const Text('Payment'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () async {
              final router = GoRouter.of(context);
              if (await _confirmCancel()) router.pop();
            },
          ),
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Text(
              'Secured by Chapa Payment Gateway',
              style:
                  AppTypography.caption.copyWith(color: AppColors.neutral500),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
