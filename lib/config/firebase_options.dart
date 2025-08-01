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
    apiKey: 'AIzaSyAAONZbhfELy4FB2ncbz23iiyAVnEQzC7A',
    appId: '1:997858029975:web:ab63d15df44bc4720914d2',
    messagingSenderId: '997858029975',
    projectId: 'utme-prepmaster',
    authDomain: 'utme-prepmaster.firebaseapp.com',
    storageBucket: 'utme-prepmaster.firebasestorage.app',
    measurementId: null, // Set to null if Google Analytics not enabled
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC6lKUP-geQzkyhsYZPyWRrZ9L2Ub_FFpw',
    appId: '1:997858029975:android:f1f3405c19d969b70914d2',
    messagingSenderId: '997858029975',
    projectId: 'utme-prepmaster',
    storageBucket: 'utme-prepmaster.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'your-ios-api-key',
    appId: 'your-ios-app-id',
    messagingSenderId: 'your-sender-id',
    projectId: 'utme-prep-master',
    storageBucket: 'utme-prep-master.appspot.com',
    iosBundleId: 'com.example.utmePrepMaster',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'your-macos-api-key',
    appId: 'your-macos-app-id',
    messagingSenderId: 'your-sender-id',
    projectId: 'utme-prep-master',
    storageBucket: 'utme-prep-master.appspot.com',
    iosBundleId: 'com.example.utmePrepMaster',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'your-windows-api-key',
    appId: 'your-windows-app-id',
    messagingSenderId: 'your-sender-id',
    projectId: 'utme-prep-master',
    storageBucket: 'utme-prep-master.appspot.com',
  );
}
