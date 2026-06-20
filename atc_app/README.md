# Attendance QR Flutter App (Teacher MVP)

This workspace contains a minimal Flutter app that lets a teacher create sessions and generate QR codes for students to scan. It includes local session persistence and a simple attendance monitor (with a "Simulate Join" button). For real-time attendance across devices, integrate a backend such as Firebase Realtime Database or Firestore.

Quick start

1. Install Flutter: https://flutter.dev/docs/get-started/install
2. Open this folder in VS Code: `/home/xpine/Documents/MY APP`
3. Get packages:

```bash
flutter pub get
```

4. Run on an emulator or device:

```bash
flutter run
```

Notes and next steps

- The app stores sessions locally using `shared_preferences`.
- After creating a session the app shows a QR code containing a JSON payload with `sessionId`, `name`, `module`, `date`, and `url`.
- The attendance monitor in this project is local and uses a simulated join button. To enable true real-time attendance you can:
  - Add Firebase: include `firebase_core` and `cloud_firestore` and set up a small student endpoint that writes `{sessionId, studentId, name, timestamp}` into Firestore; the teacher app can listen to that collection.
  - Or deploy a small WebSocket/HTTP service that the student client calls when scanning.

Files of interest

- `lib/main.dart` — app entry and provider setup
- `lib/models/session.dart` — session model
- `lib/services/session_service.dart` — local persistence (SharedPreferences)
- `lib/screens/*` — UI screens (login, home, create session, QR, monitor)

If you want, I can:

- Wire Firebase Firestore listeners and write logic (you'll need to provide Firebase config), or
- Scaffold a simple student web endpoint that accepts QR payload submissions and updates attendance in a lightweight backend.
