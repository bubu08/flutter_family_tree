# Family Tree

Flutter application for exploring, editing, and sharing family tree data. The
app was originally built as a tech challenge and demonstrates a layered
architecture with repositories, BLoC state management, and Firebase
integration.

## Features
- Email/password authentication backed by Firebase Authentication
- Google Sign-In flow via `google_sign_in`
- Profile editing flow for people in the tree (names, relationships, notes)
- Floating action menu for adding people or sharing the tree
- Modular architecture using repositories, Cubits/BLoCs, and Formz input
  validation

## Project Structure
- `lib/app.dart` – composition root wiring repositories and the global
  `AuthenticationBloc`
- `lib/authentication` – authentication BLoC, models, and events
- `lib/home` – main signed-in experience with shortcuts to profile/person flows
- `lib/person` – cubit and form widgets for editing people in the tree
- `packages/authentication_repository` – Firebase Auth wrapper
- `packages/database_repository` – Firestore data access for family tree data
- `assets/` – shared images and custom fonts used throughout the UI

## Prerequisites
- Flutter SDK (3.x recommended). Verify with `flutter --version`.
- Dart SDK comes bundled with Flutter.
- Firebase project with Authentication and Firestore enabled.
- Optional: Xcode (iOS), Android Studio/SDK (Android), or Chrome (web) depending
  on the targets you plan to run.

## Getting Started
1. **Clone the repository**
   ```bash
   git clone <your fork or the original repo url>
   cd flutter_family_tree
   ```
2. **Install dependencies**
   ```bash
   flutter pub get
   ```
3. **Configure Firebase (required)**
   - Create a Firebase project and enable Email/Password and Google sign-in in
     *Authentication → Sign-in methods*.
   - Add iOS, Android, and/or Web apps in the Firebase console to obtain the
     platform-specific configuration files.
   - Replace the placeholders in this repo with your configuration:
     - Android: download `google-services.json` and place it in
       `android/app/google-services.json` (overwriting the sample file).
     - iOS: download `GoogleService-Info.plist` and add it to
       `ios/Runner/GoogleService-Info.plist` via Xcode or by copying into the
       project directory.
     - Web: update the `FirebaseOptions` inside `lib/main.dart` with the values
       from your Firebase web app (apiKey, authDomain, etc.).
   - Ensure Firestore has a `family_trees` collection and any seed data you want
     the app to display. The current repository uses a document with the id
     `test` for development.
4. **Run the application**
   ```bash
   flutter run
   ```
   Flutter will prompt you to select a device/emulator. Use `flutter run -d
   chrome` for the web build.

## Usage
- Launch the app to land on the splash screen, which routes to the login flow.
- Sign in with email/password or use the Google sign-in button.
- After authentication you are taken to the home screen where you can:
  - Tap the profile icon to access and edit your user profile.
  - Use the floating action button to add new people to the tree (opens the
    person editor) or share the tree.
  - Open the person editor to input first/last names, relationships, and notes.
- Sign out via the logout button in the app bar.

## Development Workflow
- **State management:** BLoC/Cubit (`flutter_bloc`) centralizes business logic.
  Add new flows by introducing a cubit/BLoC and connecting it through the
  appropriate page widget.
- **Validation:** `formz` handles input validation. Extend the existing input
  classes in `lib/authentication/models` or create new ones for additional
  fields.
- **Repositories:** `AuthenticationRepository` and `DataBaseRepository` provide
  the abstraction layer for external services (Firebase Auth, Firestore). Add
  new data access methods here when expanding functionality.

## Running Tests
```bash
flutter test
```

## Troubleshooting
- If Firebase initialization fails on the web, confirm that the `FirebaseOptions`
  constants in `lib/main.dart` match your Firebase project and that you are
  serving over HTTPS (Chrome requirement).
- For Android/iOS builds, make sure Gradle/CocoaPods are up to date and that the
  native config files (`google-services.json` / `GoogleService-Info.plist`) have
  been added before running `flutter run`.
- Clear build caches if you encounter stale dependency issues:
  ```bash
  flutter clean
  flutter pub get
  ```

## Useful Commands
- `flutter format .` – format Dart code
- `flutter analyze` – static analysis
- `flutter pub run build_runner watch` – if you add code generation in the
  future (not required today but handy to note)

---

Feel free to adapt these instructions to document environment-specific details
or deployment workflows for your team.
