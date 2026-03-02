# MG Expense Tracker 💰

A cross-platform expense tracking app built with Flutter & Firebase.

## Features
- 🔐 Firebase Authentication (Email/Password)
- 💳 Card Management (Debit/Credit/UPI)
- 📊 Expense Tracking with Categories
- 📱 Works on Android, iOS & Web

## Tech Stack
- **Flutter** - Cross-platform UI
- **Firebase Auth** - Authentication
- **Cloud Firestore** - Database
- **Riverpod** - State Management

## Setup

### Prerequisites
- Flutter SDK >= 3.0.0
- Firebase project configured

### Firebase Setup (Required)
1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Add Android, iOS & Web apps to your Firebase project
3. Download and place the config files:
   - `google-services.json` → `android/app/`
   - `GoogleService-Info.plist` → `ios/Runner/`
4. Run FlutterFire CLI:
   ```bash
   flutterfire configure
   ```
   This generates `lib/firebase_options.dart`

### Run the App
```bash
flutter pub get
flutter run
```

## Platform Requirements
- Android: minSdk 21+
- iOS: 15.0+
- Web: Modern browsers

## Note
Firebase config files (`google-services.json`, `GoogleService-Info.plist`,
`lib/firebase_options.dart`) are excluded from this repo for security.
You must configure your own Firebase project to run this app.