# MediMind — Patient Mobile App

> Your Health, Simplified

MediMind is a Flutter-based patient mobile application for the Ethiopian healthcare market. It connects patients with doctors and medical centers, supports appointment booking, AI health predictions, video consultations, and much more.

---

## Prerequisites

| Tool | Version |
|------|---------|
| Flutter | 3.32.x |
| Dart | 3.11.x |
| Java | 17 |
| Xcode (iOS) | 15+ |
| Android Studio | Flamingo+ |

---

## Setup

### 1. Clone and install

```bash
git clone https://github.com/your-org/medimind-mobile.git
cd medimind-mobile
flutter pub get
```

### 2. Environment variables

Copy `.env.example` to `.env` and fill in your values:

```bash
cp .env.example .env
```

Required keys:

```
API_BASE_URL=https://api.medimind.et
GOOGLE_MAPS_API_KEY=your_key_here
```

### 3. Firebase configuration

Place your Firebase config files:

- Android: `android/app/google-services.json`
- iOS: `ios/Runner/GoogleService-Info.plist`

### 4. SSL Certificate

Place your DER-encoded certificate at:

```
assets/certs/medimind.cer
```

### 5. Generate icons and splash screen

```bash
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

---

## Running the app

```bash
# Debug
flutter run

# Release
flutter run --release
```

---

## Building

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ipa --release
```

---

## Testing

```bash
# Run all tests
flutter test

# With coverage
flutter test --coverage
```

---

## Features

| Feature | Description |
|---------|-------------|
| Authentication | Phone + OTP via SMS |
| Appointment Booking | Browse centers & doctors, pick slots |
| Queue Tracking | Real-time SignalR queue status |
| Video Consultation | WebRTC peer-to-peer video calls |
| AI Health Predictions | ML-powered risk analysis |
| Health Records | Log vitals, view lab results & diagnoses |
| Prescriptions | View active/expired prescriptions with QR |
| Medical History | Blood type, conditions, allergies, lifestyle |
| Emergency Contacts | Up to 3 contacts with primary designation |
| Favorites | Save preferred doctors & centers |
| Reviews | Rate and review doctors |
| Payments | Payment history with receipts |
| Notifications | FCM push + preference management |
| Profile | Edit personal info, upload avatar |
| Settings | Theme, language, biometric, account management |
| Offline Support | Offline banner + Hive TTL cache |
| Analytics | Firebase Analytics with screen tracking |
| Crash Reporting | Firebase Crashlytics (release only) |
| Remote Config | Feature flags, force/flexible update, maintenance |

---

## Environment Variables

| Variable | Description |
|----------|-------------|
| `API_BASE_URL` | Base URL for the MediMind REST API |
| `GOOGLE_MAPS_API_KEY` | Google Maps key for center location display |

---

## Architecture

See [docs/architecture.md](docs/architecture.md) for the full architecture overview.

---

## Contributing

See [docs/contributing.md](docs/contributing.md) for the contribution guide.
