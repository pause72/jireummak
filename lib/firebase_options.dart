// This file is a placeholder.
// Run `flutterfire configure` to generate the real firebase_options.dart
// See: https://firebase.flutter.dev/docs/cli

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.\n'
          'Run `flutterfire configure` to generate firebase_options.dart.',
        );
    }
  }

  // TODO: Replace with real values after running `flutterfire configure`
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'TODO',
    appId: 'TODO',
    messagingSenderId: 'TODO',
    projectId: 'TODO',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'TODO',
    appId: 'TODO',
    messagingSenderId: 'TODO',
    projectId: 'TODO',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'TODO',
    appId: 'TODO',
    messagingSenderId: 'TODO',
    projectId: 'TODO',
    iosBundleId: 'TODO',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'TODO',
    appId: 'TODO',
    messagingSenderId: 'TODO',
    projectId: 'TODO',
    iosBundleId: 'TODO',
  );
}
