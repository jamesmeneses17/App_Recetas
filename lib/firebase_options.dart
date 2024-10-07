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
        return macos;
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
    apiKey: 'AIzaSyCClnAEpepbfbAp-1OAASt1nxzUauEXwBY',
    appId: '1:639962325386:web:20a509d2e6932dee3de873',
    messagingSenderId: '639962325386',
    projectId: 'app-recetas-31869',
    authDomain: 'app-recetas-31869.firebaseapp.com',
    storageBucket: 'app-recetas-31869.appspot.com',
    measurementId: 'G-MZ4VX3089Y',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDbjKdlWhsr9ZO9zxzKrTRa2Qpjmy1LDfE',
    appId: '1:639962325386:android:014bd8d47eaa1c943de873',
    messagingSenderId: '639962325386',
    projectId: 'app-recetas-31869',
    storageBucket: 'app-recetas-31869.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD_1OjB8peexDM_v1Ui-kvsNGutQ72sQow',
    appId: '1:639962325386:ios:74f835e747235bcc3de873',
    messagingSenderId: '639962325386',
    projectId: 'app-recetas-31869',
    storageBucket: 'app-recetas-31869.appspot.com',
    iosBundleId: 'com.example.flutterApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyD_1OjB8peexDM_v1Ui-kvsNGutQ72sQow',
    appId: '1:639962325386:ios:74f835e747235bcc3de873',
    messagingSenderId: '639962325386',
    projectId: 'app-recetas-31869',
    storageBucket: 'app-recetas-31869.appspot.com',
    iosBundleId: 'com.example.flutterApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCClnAEpepbfbAp-1OAASt1nxzUauEXwBY',
    appId: '1:639962325386:web:c566a175fde242903de873',
    messagingSenderId: '639962325386',
    projectId: 'app-recetas-31869',
    authDomain: 'app-recetas-31869.firebaseapp.com',
    storageBucket: 'app-recetas-31869.appspot.com',
    measurementId: 'G-C7S65JBTWW',
  );
}