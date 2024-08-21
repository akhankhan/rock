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
    apiKey: 'AIzaSyDY405i2nIlytAYAiJNQlA08YSMCEr_QJs',
    appId: '1:115887973200:web:4e17ca7e2aaeaea8e24255',
    messagingSenderId: '115887973200',
    projectId: 'fine-rock',
    authDomain: 'fine-rock.firebaseapp.com',
    storageBucket: 'fine-rock.appspot.com',
    measurementId: 'G-8H73WX35QK',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAI1G__WsfD-jFq0qSeFsVxMF0FhkECv9k',
    appId: '1:115887973200:android:cecd7646a98219b6e24255',
    messagingSenderId: '115887973200',
    projectId: 'fine-rock',
    storageBucket: 'fine-rock.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBrfICoU7mhfCPXTj31kVZ5N_sJkcU2Qaw',
    appId: '1:115887973200:ios:9d369b5721cd6ee5e24255',
    messagingSenderId: '115887973200',
    projectId: 'fine-rock',
    storageBucket: 'fine-rock.appspot.com',
    iosBundleId: 'com.example.fineRock',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDY405i2nIlytAYAiJNQlA08YSMCEr_QJs',
    appId: '1:115887973200:web:5981278f3b182511e24255',
    messagingSenderId: '115887973200',
    projectId: 'fine-rock',
    authDomain: 'fine-rock.firebaseapp.com',
    storageBucket: 'fine-rock.appspot.com',
    measurementId: 'G-JGJMV6B6H3',
  );
}
