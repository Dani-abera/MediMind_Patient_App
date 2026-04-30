import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'failures.dart';

/// Translates domain [Failure]s to user-facing i18n keys and records
/// non-fatal events to Crashlytics.
class ErrorHandler {
  ErrorHandler._();

  /// Returns an easy_localization key for the given [failure].
  static String toMessageKey(Failure failure) {
    return switch (failure) {
      NetworkFailure() => 'errors.network',
      AuthFailure() => 'errors.unauthorized',
      ValidationFailure() => 'errors.validation',
      CacheFailure() => 'errors.cache',
      ServerFailure(code: final c) when c == 404 => 'errors.notFound',
      ServerFailure(code: final c) when c == 403 => 'errors.forbidden',
      ServerFailure(code: final c) when (c ?? 0) >= 500 => 'errors.server',
      ServerFailure() => 'errors.server',
      _ => 'errors.unexpected',
    };
  }

  /// Returns the translated message string using the failure's own message as
  /// fallback when no i18n context is available.
  static String toMessage(Failure failure) => failure.message;

  /// Records a non-fatal error to Firebase Crashlytics.
  /// Only active when Crashlytics collection is enabled (release mode).
  static void recordError(
    Object error,
    StackTrace? stack, {
    String? reason,
    Iterable<Object> information = const [],
  }) {
    FirebaseCrashlytics.instance.recordError(
      error,
      stack,
      reason: reason,
      information: information,
      fatal: false,
    );
  }

  /// Logs a non-fatal failure from a Bloc/UseCase result.
  static void recordFailure(Failure failure, {StackTrace? stack}) {
    final info = [
      'type: ${failure.runtimeType}',
      'message: ${failure.message}',
      if (failure.code != null) 'code: ${failure.code}',
    ];
    FirebaseCrashlytics.instance.recordError(
      Exception('Failure: ${failure.runtimeType} — ${failure.message}'),
      stack ?? StackTrace.current,
      reason: 'domain_failure',
      information: info,
      fatal: false,
    );
  }
}
