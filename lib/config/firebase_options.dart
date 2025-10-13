import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
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
    apiKey: '',
    appId: '',
    messagingSenderId: '',
    projectId: 'utme-prepmaster',
    authDomain: 'utme-prepmaster.firebaseapp.com',
    storageBucket: 'utme-prepmaster.firebasestorage.app',
    measurementId: null, // Set to null when Google Analytics not enabled
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: '',
    appId: '',
    messagingSenderId: '',
    projectId: 'utme-prepmaster',
    storageBucket: 'utme-prepmaster.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: '',
    appId: 'ios-app-id',
    messagingSenderId: 'sender-id',
    projectId: 'utme-prep-master',
    storageBucket: 'utme-prep-master.appspot.com',
    iosBundleId: 'com.example.utmePrepMaster',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'macos-api-key',
    appId: 'macos-app-id',
    messagingSenderId: 'sender-id',
    projectId: 'utme-prep-master',
    storageBucket: 'utme-prep-master.appspot.com',
    iosBundleId: 'com.example.utmePrepMaster',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'windows-api-key',
    appId: 'windows-app-id',
    messagingSenderId: 'sender-id',
    projectId: 'utme-prep-master',
    storageBucket: 'utme-prep-master.appspot.com',
  );
}
