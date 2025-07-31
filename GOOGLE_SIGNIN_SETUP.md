# Google Sign-In Setup for Physical Devices

## Overview
Google Sign-In on physical devices requires proper configuration of OAuth 2.0 credentials and SHA-1 fingerprints. This guide will help you set up Google Sign-In to work on both emulators and physical devices.

## Prerequisites
1. Google Cloud Console project
2. Firebase project
3. Android Studio or command line tools
4. Physical Android device

## Step 1: Get SHA-1 Fingerprints

### For Debug Builds:
```bash
# Navigate to your project directory
cd android

# Get debug SHA-1
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

### For Release Builds:
```bash
# If you have a release keystore
keytool -list -v -keystore your-release-key.keystore -alias your-key-alias
```

### For Google Play App Signing:
1. Go to Google Play Console
2. Navigate to Setup > App Signing
3. Copy the SHA-1 from the "App signing certificate" section

## Step 2: Configure Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Go to Project Settings (gear icon)
4. Scroll down to "Your apps" section
5. Select your Android app
6. Click "Add fingerprint"
7. Add all your SHA-1 fingerprints:
   - Debug SHA-1
   - Release SHA-1 (if different)
   - Google Play App Signing SHA-1

## Step 3: Configure Google Cloud Console

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your project
3. Go to APIs & Services > Credentials
4. Find your OAuth 2.0 Client ID for Android
5. Add your package name and SHA-1 fingerprints

## Step 4: Update Android Configuration

### Update `android/app/build.gradle`:
```gradle
android {
    defaultConfig {
        applicationId "com.example.utme_prep_master"
        minSdkVersion 21
        targetSdkVersion 33
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
    }
}
```

### Update `android/app/src/main/AndroidManifest.xml`:
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.INTERNET"/>
    
    <application
        android:label="UTME PrepMaster"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            
            <meta-data
                android:name="io.flutter.embedding.android.NormalTheme"
                android:resource="@style/NormalTheme" />
            
            <intent-filter android:autoVerify="true">
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
        
        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>
</manifest>
```

## Step 5: Update Flutter Code

### Update Google Sign-In configuration:
```dart
final GoogleSignIn googleSignIn = GoogleSignIn(
  scopes: ['email', 'profile'],
  // Remove clientId for Android - it's only needed for web
  // clientId: 'your-web-client-id.apps.googleusercontent.com',
);
```

### Add error handling:
```dart
Future<void> _signInWithGoogle() async {
  try {
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    
    if (googleUser == null) {
      // User cancelled sign-in
      return;
    }
    
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    
    final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
    
    // Handle successful sign-in
    print('Google Sign-In successful: ${userCredential.user?.email}');
    
  } on PlatformException catch (e) {
    print('Google Sign-In Platform Exception: ${e.code} - ${e.message}');
    // Handle specific platform errors
    switch (e.code) {
      case 'SIGN_IN_CANCELLED':
        print('User cancelled sign-in');
        break;
      case 'SIGN_IN_FAILED':
        print('Sign-in failed');
        break;
      case 'NETWORK_ERROR':
        print('Network error occurred');
        break;
      default:
        print('Unknown error: ${e.message}');
    }
  } catch (e) {
    print('Unexpected error during Google Sign-In: $e');
  }
}
```

## Step 6: Test on Physical Device

1. Connect your physical device
2. Enable USB debugging
3. Run the app:
```bash
flutter run
```

## Common Issues and Solutions

### Issue 1: "Sign in failed" error
**Solution:**
- Check SHA-1 fingerprints in Firebase Console
- Ensure package name matches exactly
- Verify Google Cloud Console configuration

### Issue 2: "Network error" on physical device
**Solution:**
- Check internet connection
- Ensure device has Google Play Services
- Verify Google account is added to device

### Issue 3: "Developer error" or "Invalid client"
**Solution:**
- Add SHA-1 fingerprint to Firebase Console
- Wait 5-10 minutes for changes to propagate
- Clear app data and try again

### Issue 4: App not appearing in Google Sign-In dialog
**Solution:**
- Ensure app is signed with correct keystore
- Check package name in build.gradle
- Verify OAuth 2.0 client configuration

## Debugging Tips

1. **Enable verbose logging:**
```dart
GoogleSignIn.debug = true;
```

2. **Check SHA-1 fingerprints:**
```bash
# For debug builds
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

# For release builds
keytool -list -v -keystore your-release-key.keystore -alias your-key-alias
```

3. **Verify Firebase configuration:**
- Check `google-services.json` is in `android/app/`
- Verify package name matches
- Ensure SHA-1 fingerprints are added

4. **Test with different accounts:**
- Try with different Google accounts
- Clear app data between tests
- Test on different devices

## Production Considerations

1. **Use release keystore SHA-1**
2. **Configure Google Play App Signing**
3. **Test on multiple devices**
4. **Monitor Firebase Analytics for sign-in events**
5. **Implement proper error handling**
6. **Add user feedback for sign-in states**

## Troubleshooting Checklist

- [ ] SHA-1 fingerprints added to Firebase Console
- [ ] Package name matches in all configurations
- [ ] Google Cloud Console OAuth 2.0 client configured
- [ ] `google-services.json` in correct location
- [ ] Device has Google Play Services
- [ ] Internet connection available
- [ ] Google account added to device
- [ ] App signed with correct keystore
- [ ] Firebase project linked to Google Cloud project

## Additional Resources

- [Firebase Authentication Documentation](https://firebase.google.com/docs/auth)
- [Google Sign-In for Android](https://developers.google.com/identity/sign-in/android)
- [Flutter Firebase Plugin](https://pub.dev/packages/firebase_auth)
- [Google Sign-In Flutter Plugin](https://pub.dev/packages/google_sign_in) 