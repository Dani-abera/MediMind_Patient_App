# MediMind v1.0.0 Release Checklist

## Functional Requirements

| ID | Requirement | Screen / Feature | Status |
|----|-------------|-----------------|--------|
| FR001 | Phone + OTP authentication | PhoneEntryPage, OtpVerificationPage | ✅ |
| FR002 | New patient registration | ProfileCompletionPage | ✅ |
| FR003 | Session token refresh | AuthInterceptor (401 handling) | ✅ |
| FR004 | Browse medical centers with map | CenterSearchPage, GoogleMaps | ✅ |
| FR005 | Browse doctors by specialization | CenterDoctorsPage, DoctorDetailPage | ✅ |
| FR006 | Book in-person appointment | BookPage → SlotPickerPage → BookingSummaryPage | ✅ |
| FR007 | Book video consultation appointment | BookPage (video type) | ✅ |
| FR008 | View upcoming/past/cancelled appointments | AppointmentsPage (tabs) | ✅ |
| FR009 | Real-time queue tracking via SignalR | QueueStatusPage | ✅ |
| FR010 | WebRTC video consultation | VideoCallPage | ✅ |
| FR011 | Log vitals (BP, HR, temp, weight, O2, sugar) | LogVitalsPage | ✅ |
| FR012 | View health trends charts | TrendsDetailPage | ✅ |
| FR013 | AI health predictions | RequestPredictionPage, PredictionDetailPage | ✅ |
| FR014 | View active/expired prescriptions with QR | PrescriptionsListPage, PrescriptionDetailPage | ✅ |
| FR015 | Medical history (blood type, conditions, allergies, lifestyle) | MedicalHistoryPage | ✅ |
| FR016 | Emergency contacts (max 3, primary) | EmergencyContactsPage, AddEditContactPage | ✅ |
| FR017 | Favorite doctors and centers | FavoritesPage | ✅ |
| FR018 | Leave doctor reviews | LeaveReviewPage | ✅ |
| FR019 | Payment history with receipt | PaymentHistoryPage (paginated) | ✅ |
| FR020 | Push notifications via FCM | NotificationService, NotificationsPage | ✅ |
| FR021 | Notification preferences per category | NotificationPreferencesPage | ✅ |
| FR022 | Medication reminders with local notifications | MedicationRemindersPage, AddReminderPage | ✅ |
| FR023 | Edit profile + avatar upload | EditProfilePage | ✅ |
| FR024 | Theme switching (light/dark/system) | SettingsPage → SettingsBloc | ✅ |
| FR025 | Language switching (English/Amharic) | SettingsPage → EasyLocalization | ✅ |
| FR026 | Delete account | SettingsPage | ✅ |
| FR027 | In-app coach mark tutorial (4 steps) | CoachMarkOverlay | ✅ |
| FR028 | Maintenance mode gate | MaintenanceScreen (Remote Config) | ✅ |
| FR029 | Force/flexible in-app update | AppUpdateService (in_app_update) | ✅ |
| FR030 | Deep link handling (medimind:// + https://app.medimind.et) | AndroidManifest, iOS Info.plist | ✅ |

## Non-Functional Requirements

| ID | Requirement | Implementation | Status |
|----|-------------|---------------|--------|
| NFR001 | Offline banner with cached data | ConnectivityCubit + HiveCache | ✅ |
| NFR002 | SSL certificate pinning (release) | SslPinningInterceptor | ✅ |
| NFR003 | Root/jailbreak detection warning | SecurityService → AppShell dialog | ✅ |
| NFR004 | Firebase Crashlytics (release only) | CrashlyticsService + runZonedGuarded | ✅ |
| NFR005 | Firebase Analytics + screen tracking | AnalyticsService + GoRouter observers | ✅ |
| NFR006 | Firebase Remote Config feature flags | RemoteConfigService | ✅ |
| NFR007 | Hive TTL cache for GET responses | HiveCache (centers 5min, doctors 5min, predictions 10min) | ✅ |
| NFR008 | 70%+ test coverage | 114 passing tests | ✅ |
| NFR009 | flutter analyze = 0 issues | Verified | ✅ |
| NFR010 | Android minSdk 23, targetSdk 35 | build.gradle.kts | ✅ |
| NFR011 | iOS portrait-only orientation | AndroidManifest + Info.plist | ✅ |
| NFR012 | i18n English + Amharic | en-US.json, am-ET.json (complete) | ✅ |
| NFR013 | CI/CD: PR gate + release pipeline | .github/workflows/ci.yaml | ✅ |
| NFR014 | Hashed user ID in analytics (no PII) | hashCode.toUnsigned(32).toRadixString(16) | ✅ |
| NFR015 | FCM token register on login, unregister on logout | NotificationService + AuthBloc | ✅ |

## Pre-Release Actions

- [ ] Replace placeholder `assets/certs/medimind.cer` with real DER certificate
- [ ] Add `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
- [ ] Set production `API_BASE_URL` in `.env`
- [ ] Set `GOOGLE_MAPS_API_KEY` in `.env`
- [ ] Configure Android signing keystore and `key.properties`
- [ ] Run `dart run flutter_launcher_icons` with real `app_icon.png`
- [ ] Run `dart run flutter_native_splash:create` with real `splash_logo.png`
- [ ] Configure GitHub Actions secrets (see CI/CD section in README)
- [ ] Set Firebase Remote Config values in Firebase Console
- [ ] Set `min_required_version` and `latest_version` in Remote Config
- [ ] Add real `FIREBASE_APP_ID_ANDROID` and `FIREBASE_SERVICE_ACCOUNT` to CI secrets
- [ ] Test force update path end-to-end on a real device
- [ ] Test FCM push notification delivery
- [ ] Test deep links (medimind://appointments on Android + iOS)
- [ ] Verify Crashlytics collection in Firebase Console after a test crash
- [ ] Submit for internal testing via Firebase App Distribution

## Known Issues / v1.0.0 Scope

- Biometric login UI toggle is present in Settings but the authentication flow uses PIN fallback (biometric SDK wiring deferred to v1.1)
- In-app update flexible path completes immediately (Play Store must have a published update available)
- Remote Config maintenance mode check is evaluated once on app shell init; requires app restart to exit maintenance mode
- Screenshot disable on sensitive screens (prescriptions, payments) deferred to v1.1 (requires `flutter_windowmanager` platform channel)

## v1.0.0 Release Notes

**New in v1.0.0:**
- Complete patient app with 20+ features
- Real-time queue tracking via SignalR
- WebRTC video consultations
- AI-powered health predictions
- Full Amharic localization
- Dark mode and system theme support
- Firebase Analytics, Crashlytics, and Remote Config integration
