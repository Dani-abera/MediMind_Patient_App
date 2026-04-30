import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class AnalyticsService {
  AnalyticsService._();
  static final AnalyticsService instance = AnalyticsService._();

  FirebaseAnalytics? _analytics;

  bool get _available => Firebase.apps.isNotEmpty;

  FirebaseAnalytics get _fa => _analytics ??= FirebaseAnalytics.instance;

  NavigatorObserver get observer {
    if (!_available) return NavigatorObserver();
    return FirebaseAnalyticsObserver(analytics: _fa);
  }

  // ── Auth ──────────────────────────────────────────────────────────────────

  Future<void> logLoginSuccess() async {
    if (!_available) return;
    await _fa.logLogin(loginMethod: 'phone_otp');
  }

  Future<void> logRegistrationCompleted() async {
    if (!_available) return;
    await _fa.logEvent(name: 'registration_completed');
  }

  // ── Appointments ─────────────────────────────────────────────────────────

  Future<void> logAppointmentBooked({
    required String centerId,
    required String doctorId,
    required String dayOfWeek,
  }) async {
    if (!_available) return;
    await _fa.logEvent(
      name: 'appointment_booked',
      parameters: {
        'center_id': centerId,
        'doctor_id': doctorId,
        'day_of_week': dayOfWeek,
      },
    );
  }

  // ── Payments ─────────────────────────────────────────────────────────────

  Future<void> logPaymentCompleted({required double amountEtb}) async {
    if (!_available) return;
    await _fa.logPurchase(
      currency: 'ETB',
      value: amountEtb,
    );
  }

  // ── Health ────────────────────────────────────────────────────────────────

  Future<void> logPredictionRequested({required int dataDays}) async {
    if (!_available) return;
    await _fa.logEvent(
      name: 'prediction_requested',
      parameters: {'data_days': dataDays},
    );
  }

  Future<void> logVitalsLogged() async {
    if (!_available) return;
    await _fa.logEvent(name: 'vitals_logged');
  }

  // ── Prescriptions ─────────────────────────────────────────────────────────

  Future<void> logPrescriptionViewed({required String prescriptionId}) async {
    if (!_available) return;
    await _fa.logEvent(
      name: 'prescription_viewed',
      parameters: {'prescription_id': prescriptionId},
    );
  }

  // ── Video ─────────────────────────────────────────────────────────────────

  Future<void> logVideoCallStarted({required String consultationId}) async {
    if (!_available) return;
    await _fa.logEvent(
      name: 'video_call_started',
      parameters: {'consultation_id': consultationId},
    );
  }

  Future<void> logVideoCallEnded({
    required String consultationId,
    required int durationSeconds,
  }) async {
    if (!_available) return;
    await _fa.logEvent(
      name: 'video_call_ended',
      parameters: {
        'consultation_id': consultationId,
        'duration_seconds': durationSeconds,
      },
    );
  }

  // ── Screen ────────────────────────────────────────────────────────────────

  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    if (!_available) return;
    await _fa.logScreenView(
      screenName: screenName,
      screenClass: screenClass ?? screenName,
    );
  }

  // ── User ─────────────────────────────────────────────────────────────────

  Future<void> setUserId(String hashedId) async {
    if (!_available) return;
    await _fa.setUserId(id: hashedId);
  }

  Future<void> clearUserId() async {
    if (!_available) return;
    await _fa.setUserId(id: null);
  }
}

/// GoRouter analytics observer — logs screen_view on every navigation.
class AnalyticsRouteObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    _logRoute(route);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    if (newRoute != null) _logRoute(newRoute);
  }

  void _logRoute(Route route) {
    final name = route.settings.name;
    if (name != null) {
      AnalyticsService.instance.logScreenView(screenName: name);
    }
  }
}
