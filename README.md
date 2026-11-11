# ChatUp – WhatsApp-style chat app in Flutter + Firebase

A full real-time chat app built in Flutter with Firebase Authentication, Cloud Firestore and Firebase Storage.

## Features
- Email/password sign up and login
- Chat list with last message, time and unread badges (All / Unread filter)
- Real-time one-to-one messaging
- Blue read ticks, "typing..." indicator, online dot and last seen
- Send photos (Firebase Storage)
- Profile screen (name + about)
- Long-press to delete a message for everyone
- Firestore and Storage security rules

## Run it
1. Create a Firebase project and enable **Authentication (Email/Password)**, **Cloud Firestore** and **Storage**.
2. Connect it to the app (this replaces `lib/firebase_options.dart`):
   ```
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
3. Deploy the security rules:
   ```
   firebase deploy --only firestore:rules,storage
   ```
4. Run:
   ```
   flutter pub get
   flutter run
   ```

Optional: run against the Firebase Local Emulator Suite with `--dart-define=EMULATOR=true`.

Built for the Orhan Yazdan YouTube channel.
