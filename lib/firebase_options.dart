// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        return windows;
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
    apiKey: 'AIzaSyCblGhl385ffHpSfmNN6lE5TBDe1lQV1z4',
    appId: '1:469454593920:web:d984a35008749e6764ab65',
    messagingSenderId: '469454593920',
    projectId: 'packmate-c344f',
    authDomain: 'packmate-c344f.firebaseapp.com',
    storageBucket: 'packmate-c344f.appspot.com',
    measurementId: 'G-813CNYHMW2',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAZBLIhL7cPGkftcZqk9oPZD2zbETgWDnc',
    appId: '1:469454593920:android:439eaedf285558f064ab65',
    messagingSenderId: '469454593920',
    projectId: 'packmate-c344f',
    storageBucket: 'packmate-c344f.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBMJZMMBR0zkR9MktXHHzfBU-8-DKM7NuI',
    appId: '1:469454593920:ios:d5083b4e4e651c6764ab65',
    messagingSenderId: '469454593920',
    projectId: 'packmate-c344f',
    storageBucket: 'packmate-c344f.appspot.com',
    iosBundleId: 'com.example.packMate',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCblGhl385ffHpSfmNN6lE5TBDe1lQV1z4',
    appId: '1:469454593920:web:efe611ab648b0ff764ab65',
    messagingSenderId: '469454593920',
    projectId: 'packmate-c344f',
    authDomain: 'packmate-c344f.firebaseapp.com',
    storageBucket: 'packmate-c344f.appspot.com',
    measurementId: 'G-0VXMJ83NP0',
  );
}
