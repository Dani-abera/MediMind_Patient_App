import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/dialogs/confirm_dialog.dart';
import '../widgets/feedback/app_toast.dart';

extension BuildContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  void push(String location) => GoRouter.of(this).push(location);
  void pop<T>([T? result]) => GoRouter.of(this).pop(result);
  void go(String location) => GoRouter.of(this).go(location);
  void pushNamed(String name, {Map<String, String> pathParameters = const {}}) =>
      GoRouter.of(this).pushNamed(name, pathParameters: pathParameters);
  void goNamed(String name, {Map<String, String> pathParameters = const {}}) =>
      GoRouter.of(this).goNamed(name, pathParameters: pathParameters);

  void showToast(String message) => AppToast.info(this, message);
  void showSuccess(String message) => AppToast.success(this, message);
  void showError(String message) => AppToast.error(this, message);
  void showWarning(String message) => AppToast.warning(this, message);

  Future<bool> showConfirm({
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    bool isDestructive = false,
  }) =>
      ConfirmDialog.show(
        this,
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        isDestructive: isDestructive,
      );
}
