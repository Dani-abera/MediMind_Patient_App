import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/di/service_locator.dart';
import 'core/services/notification_service.dart';
import 'features/appointments/appointments_injection.dart';
import 'features/auth/auth_injection.dart';
import 'features/centers/centers_injection.dart';
import 'features/doctors/doctors_injection.dart';
import 'features/emergency_contacts/emergency_contacts_injection.dart';
import 'features/favorites/favorites_injection.dart';
import 'features/home/home_injection.dart';
import 'features/health_records/health_records_injection.dart';
import 'features/medical_history/medical_history_injection.dart';
import 'features/medication_reminders/medication_reminders_injection.dart';
import 'features/notifications/data/datasources/notification_remote_datasource.dart';
import 'features/notifications/notifications_injection.dart';
import 'features/payments/payments_injection.dart';
import 'features/predictions/predictions_injection.dart';
import 'features/prescriptions/prescriptions_injection.dart';
import 'features/profile/profile_injection.dart';
import 'features/queue/queue_injection.dart';
import 'features/reviews/reviews_injection.dart';
import 'features/settings/settings_injection.dart';
import 'features/video_consultation/video_consultation_injection.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  await Firebase.initializeApp();

  await EasyLocalization.ensureInitialized();

  await Hive.initFlutter();

  await initDependencies();

  await initAuthFeature(sl);
  initHomeFeature(sl);
  initNotificationsFeature(sl);
  initCentersFeature(sl);
  initDoctorsFeature(sl);
  initPaymentsFeature(sl);
  initAppointmentsFeature(sl);
  initHealthRecordsFeature(sl);
  initPredictionsFeature(sl);
  initMedicationRemindersFeature(sl);
  initQueueFeature(sl);
  initVideoConsultationFeature(sl);
  initPrescriptionsFeature(sl);
  initMedicalHistoryFeature(sl);
  initEmergencyContactsFeature(sl);
  initFavoritesFeature(sl);
  initReviewsFeature(sl);
  initProfileFeature(sl);
  initSettingsFeature(sl);

  // Wire FCM device token registration/unregistration callbacks
  NotificationService.instance.setTokenCallbacks(
    onRegister: (token, platform) =>
        sl<NotificationRemoteDataSource>()
            .registerDeviceToken(token, platform),
    onUnregister: (token) =>
        sl<NotificationRemoteDataSource>().unregisterDeviceToken(token),
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}
