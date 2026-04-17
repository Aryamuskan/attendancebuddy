import 'package:firebase_core/firebase_core.dart';
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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  /// 🔹 WEB CONFIG
  static const FirebaseOptions web = FirebaseOptions(
    apiKey:"AIzaSyDWrjs2M-2Wdrqeo7NYb_deB8N_jvNa-pg",
    authDomain: "attendancebuddy-f2f46.firebaseapp.com",
    projectId: "attendancebuddy-f2f46",
    storageBucket:"attendancebuddy-f2f46.firebasestorage.app",
    messagingSenderId: "320678037132",
    appId: "1:320678037132:web:daea256c2317183c88dda9",
  );

  /// 🔹 ANDROID CONFIG
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyB3wu4RKhxMt_KQ8uSiq6JavzlN-4z5v3Y",
    appId: "1:320678037132:android:4c0d043cdd17dc1788dda9",
    messagingSenderId: "320678037132",
    projectId: "attendancebuddy-f2f46",
    storageBucket: "attendancebuddy-f2f46.firebasestorage.app",
  );
}