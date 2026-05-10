// lib/firebase_options.dart
// ─────────────────────────────────────────────────────────────────────────────
// Options Firebase pour toutes les plateformes.
//
// ⚠️  CONFIGURATION WEB REQUISE :
//   1. Ouvrir Firebase Console → Paramètres du projet → Vos applications
//   2. Ajouter une application Web (si pas encore fait)
//   3. Copier l'appId web (format : 1:539828926028:web:XXXXXXXXXXXX)
//   4. Remplacer la valeur TODO ci-dessous
// ─────────────────────────────────────────────────────────────────────────────

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
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

  /// ── Configuration Web ────────────────────────────────────────────────────
  /// ⚠️  Remplacez appId par la valeur de Firebase Console → Web App
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA_u6ShMPHJO9DzTlB3Z9zllM6rBwq496I',
    authDomain: 'ecorewind-6b5d6.firebaseapp.com',
    databaseURL: 'https://ecorewind-6b5d6-default-rtdb.europe-west1.firebasedatabase.app',
    projectId: 'ecorewind-6b5d6',
    storageBucket: 'ecorewind-6b5d6.firebasestorage.app',
    messagingSenderId: '539828926028',
    appId: '1:539828926028:web:403f2f0420d1f1aa4726e9',
  );

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

  /// ── Configuration iOS (à compléter si besoin) ────────────────────────────
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
