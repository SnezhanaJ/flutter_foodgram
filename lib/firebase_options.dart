// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB7tG91DOwPPbRs1wIHJWBMPWsKO-rpLPA',
    appId: '1:58747088362:web:87911927b89b3b5d1d9693',
    messagingSenderId: '58747088362',
    projectId: 'flutter-foodgram',
    authDomain: 'flutter-foodgram.firebaseapp.com',
    storageBucket: 'flutter-foodgram.appspot.com',
    measurementId: 'G-GRCGZN6Z4G',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBSpPUFwPNxiOuIxIdbq1Wmu8T42xi2SIo',
    appId: '1:58747088362:android:635a095a3799e8461d9693',
    messagingSenderId: '58747088362',
    projectId: 'flutter-foodgram',
    storageBucket: 'flutter-foodgram.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA9ZSx5xR1nB2WCjlXQHjm9tRJ1dC8SeTo',
    appId: '1:58747088362:ios:3ba5824e51ea24541d9693',
    messagingSenderId: '58747088362',
    projectId: 'flutter-foodgram',
    storageBucket: 'flutter-foodgram.appspot.com',
    iosBundleId: 'com.example.foodgram',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA9ZSx5xR1nB2WCjlXQHjm9tRJ1dC8SeTo',
    appId: '1:58747088362:ios:c1d2ece24399c4461d9693',
    messagingSenderId: '58747088362',
    projectId: 'flutter-foodgram',
    storageBucket: 'flutter-foodgram.appspot.com',
    iosBundleId: 'com.example.foodgram.RunnerTests',
  );
}