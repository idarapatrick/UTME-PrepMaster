# 🔧 Google Sign-In Setup Guide

## The Issue
The "channel-error" you're seeing means Google Sign-In is not properly configured in Firebase Console.

## 🔍 Step-by-Step Fix

### 1. Enable Google Sign-In in Firebase Console
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project: `utme-prepmaster`
3. Go to **Authentication** → **Sign-in method**
4. Click on **Google** provider
5. **Enable** Google Sign-In
6. Add your **support email**
7. Click **Save**

### 2. Get Correct SHA-1 Fingerprint
Run this command to get your debug SHA-1:
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

### 3. Add SHA-1 to Firebase
1. In Firebase Console, go to **Project Settings**
2. Scroll down to **Your apps** section
3. Click on your Android app
4. Click **Add fingerprint**
5. Paste your SHA-1 fingerprint

### 4. Download Updated google-services.json
1. In Firebase Console, go to **Project Settings**
2. Scroll down to **Your apps**
3. Click **Download google-services.json**
4. Replace the file in `android/app/google-services.json`

### 5. Test the App
1. Clean and rebuild:
```bash
flutter clean
flutter pub get
flutter run
```

## 🚨 Common Issues

### Issue: "channel-error"
- **Cause**: Google Sign-In not enabled in Firebase
- **Fix**: Enable Google Sign-In in Firebase Console

### Issue: "SHA-1 mismatch"
- **Cause**: Wrong SHA-1 fingerprint in Firebase
- **Fix**: Update SHA-1 in Firebase Console

### Issue: "Google Play Services not available"
- **Cause**: Emulator/device doesn't have Google Play Services
- **Fix**: Use a device with Google Play Services or Google Play Services emulator

## ✅ Verification
After setup, Google Sign-In should work without the "channel-error" message.

## 📞 Need Help?
If you still get errors, check:
1. Firebase Console → Authentication → Sign-in methods → Google (should be enabled)
2. Firebase Console → Project Settings → Your apps → SHA-1 fingerprints
3. Device/emulator has Google Play Services 