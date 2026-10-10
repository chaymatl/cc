// lib/firebase_options.dart
// ─────────────────────────────────────────────────────────────────────────────
// Options Firebase pour Android et iOS uniquement.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'Plateforme non supportée : $defaultTargetPlatform',
        );
    }
  }

  /// ── Configuration Android ────────────────────────────────────────────────
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA_u6ShMPHJO9DzTlB3Z9zllM6rBwq496I',
    authDomain: 'ecorewind-6b5d6.firebaseapp.com',
    databaseURL: 'https://ecorewind-6b5d6-default-rtdb.europe-west1.firebasedatabase.app',
    projectId: 'ecorewind-6b5d6',
    storageBucket: 'ecorewind-6b5d6.firebasestorage.app',
    messagingSenderId: '539828926028',
    appId: '1:539828926028:android:fe11ba83a73176a54726e9',
  );

  /// ── Configuration iOS ────────────────────────────────────────────────────
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA_u6ShMPHJO9DzTlB3Z9zllM6rBwq496I',
    authDomain: 'ecorewind-6b5d6.firebaseapp.com',
    databaseURL: 'https://ecorewind-6b5d6-default-rtdb.europe-west1.firebasedatabase.app',
    projectId: 'ecorewind-6b5d6',
    storageBucket: 'ecorewind-6b5d6.firebasestorage.app',
    messagingSenderId: '539828926028',
    appId: '1:539828926028:ios:REMPLACER_PAR_IOS_APP_ID',
  );
}
