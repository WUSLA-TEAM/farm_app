// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;



// ...



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
    apiKey: 'AIzaSyDE3-c2oXRBMeVoq05GSAmpijTG_1OK-u4',
    appId: '1:836881895565:web:347f410d6a75ff1b27d2c4',
    messagingSenderId: '836881895565',
    projectId: 'cowecoomerce',
    authDomain: 'cowecoomerce.firebaseapp.com',
    storageBucket: 'cowecoomerce.appspot.com',
    measurementId: 'G-9SYV60HRWB',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCwxVDq2dmOvTMBZF69vr00mdwGJgmRlIM',
    appId: '1:836881895565:android:0211509c973906cc27d2c4',
    messagingSenderId: '836881895565',
    projectId: 'cowecoomerce',
    storageBucket: 'cowecoomerce.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCl47-A87ILF-17Hnbz653pMP0SbOj5kC8',
    appId: '1:836881895565:ios:71c95840222b006427d2c4',
    messagingSenderId: '836881895565',
    projectId: 'cowecoomerce',
    storageBucket: 'cowecoomerce.appspot.com',
    androidClientId: '836881895565-m45lhhmnp5hlvqaii7p1ccjkfv8gnrum.apps.googleusercontent.com',
    iosClientId: '836881895565-r8iabbg3o7tbsc8dvj19ep6lpsertn6h.apps.googleusercontent.com',
    iosBundleId: 'com.example.farmApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCl47-A87ILF-17Hnbz653pMP0SbOj5kC8',
    appId: '1:836881895565:ios:71c95840222b006427d2c4',
    messagingSenderId: '836881895565',
    projectId: 'cowecoomerce',
    storageBucket: 'cowecoomerce.appspot.com',
    androidClientId: '836881895565-m45lhhmnp5hlvqaii7p1ccjkfv8gnrum.apps.googleusercontent.com',
    iosClientId: '836881895565-r8iabbg3o7tbsc8dvj19ep6lpsertn6h.apps.googleusercontent.com',
    iosBundleId: 'com.example.farmApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDE3-c2oXRBMeVoq05GSAmpijTG_1OK-u4',
    appId: '1:836881895565:web:3478a7fc7a646a6d27d2c4',
    messagingSenderId: '836881895565',
    projectId: 'cowecoomerce',
    authDomain: 'cowecoomerce.firebaseapp.com',
    storageBucket: 'cowecoomerce.appspot.com',
    measurementId: 'G-0992X1NXZ4',
  );
}
