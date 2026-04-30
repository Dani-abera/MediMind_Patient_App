import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'app.dart';
import 'bootstrap.dart';
import 'core/services/crashlytics_service.dart';

void main() {
  runZonedGuarded<Future<void>>(
    () async {
      await bootstrap();

      FlutterError.onError = (details) {
        FlutterError.presentError(details);
        if (!kDebugMode && Firebase.apps.isNotEmpty) {
          CrashlyticsService.instance.recordFlutterError(details);
        }
      };

      PlatformDispatcher.instance.onError = (error, stack) {
        if (!kDebugMode && Firebase.apps.isNotEmpty) {
          CrashlyticsService.instance.recordError(error, stack, fatal: true);
        }
        return true;
      };

      runApp(const MediMindApp());

      // Defer non-critical Firebase init to after first frame.
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await CrashlyticsService.instance.init();
      });
    },
    (error, stack) {
      if (!kDebugMode && Firebase.apps.isNotEmpty) {
        CrashlyticsService.instance.recordError(error, stack, fatal: false);
      } else {
        // ignore: avoid_print
        print('Uncaught error: $error\n$stack');
      }
    },
  );
}
