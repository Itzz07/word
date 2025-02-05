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
    apiKey: 'AIzaSyAYe-jmGyX50r-j9L8NlsnO8_GG1Vhfbkg',
    appId: '1:1040858746613:web:a28b2dc286b8e42fdebfbc',
    messagingSenderId: '1040858746613',
    projectId: 'bliss-8ded3',
    authDomain: 'bliss-8ded3.firebaseapp.com',
    storageBucket: 'bliss-8ded3.appspot.com',
    measurementId: 'G-5XQPLFS6WT',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC9EOut1l_m4qkWwidS5MHLsY_Mq-kWJmE',
    appId: '1:1040858746613:android:e2749eb6253f330cdebfbc',
    messagingSenderId: '1040858746613',
    projectId: 'bliss-8ded3',
    storageBucket: 'bliss-8ded3.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBP0MvNh-7KB_hY2fLf1HueREJTZkJZLdA',
    appId: '1:1040858746613:ios:a7ba8f3bf56d0a3edebfbc',
    messagingSenderId: '1040858746613',
    projectId: 'bliss-8ded3',
    storageBucket: 'bliss-8ded3.appspot.com',
    iosBundleId: 'com.example.word',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBP0MvNh-7KB_hY2fLf1HueREJTZkJZLdA',
    appId: '1:1040858746613:ios:cef57ede30dddb63debfbc',
    messagingSenderId: '1040858746613',
    projectId: 'bliss-8ded3',
    storageBucket: 'bliss-8ded3.appspot.com',
    iosBundleId: 'com.example.word.RunnerTests',
  );
}
