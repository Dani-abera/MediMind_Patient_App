import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class AppToast {
  AppToast._();

  static void success(BuildContext context, String message) => _show(
        context,
        message: message,
        type: ToastificationType.success,
      );

  static void error(BuildContext context, String message) => _show(
        context,
        message: message,
        type: ToastificationType.error,
      );

  static void warning(BuildContext context, String message) => _show(
        context,
        message: message,
        type: ToastificationType.warning,
      );

  static void info(BuildContext context, String message) => _show(
        context,
        message: message,
        type: ToastificationType.info,
      );

  static void _show(
    BuildContext context, {
    required String message,
    required ToastificationType type,
  }) {
    toastification.show(
      context: context,
      type: type,
      style: ToastificationStyle.flat,
      title: Text(message),
      alignment: Alignment.topCenter,
      autoCloseDuration: const Duration(seconds: 3),
      showProgressBar: false,
      closeButton: const ToastCloseButton(showType: CloseButtonShowType.none),
    );
  }
}
