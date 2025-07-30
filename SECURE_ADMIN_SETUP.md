# 🔐 Secure Admin Setup Guide

## ⚠️ Security First Approach

**Never hardcode credentials in your code or documentation!** This guide shows you how to set up admin users securely using Firebase Console.

## 🛠️ Proper Admin Setup Process

### Step 1: Firebase Console Setup

1. **Go to Firebase Console**
   - Visit: https://console.firebase.google.com
   - Select your UTME PrepMaster project

2. **Create Admin User in Authentication**
   - Go to Authentication → Users
   - Click "Add User"
   - Enter your admin email (use your actual email)
   - Enter a strong password (12+ characters, mix of letters, numbers, symbols)
   - Click "Add User"

3. **Set User Role in Firestore**
   - Go to Firestore Database
   - Navigate to `users` collection
   - Create document with the user's UID (from Authentication)
   - Add this data structure:

```json
{
  "email": "your-actual-email@domain.com",
  "role": "admin",
  "adminCode": "YOUR_SECURE_ADMIN_CODE",
  "permissions": ["upload", "verify", "delete", "manage"],
  "createdAt": "2024-01-01",
  "isActive": true,
  "displayName": "Admin User"
}
```

### Step 2: Environment Variables (Recommended)

For production, use environment variables:

1. **Create `.env` file** (add to .gitignore):
```env
ADMIN_EMAIL=your-admin@domain.com
ADMIN_CODE=your-secure-admin-code
```

2. **Use in your app**:
```dart
// Load from environment variables
final adminEmail = const String.fromEnvironment('ADMIN_EMAIL');
final adminCode = const String.fromEnvironment('ADMIN_CODE');
```

### Step 3: Firebase Security Rules

Set up proper Firestore security rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only read their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Only admins can access admin collections
    match /admin/{document=**} {
      allow read, write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
  }
}
```

## 🔒 Security Best Practices

### ✅ Do's:
- Use Firebase Console for user management
- Store credentials in environment variables
- Use strong passwords (12+ characters)
- Enable 2FA for admin accounts
- Regularly rotate admin codes
- Monitor admin activity in Firebase Console
- Use Firebase Security Rules

### ❌ Don'ts:
- Never hardcode credentials in code
- Never commit credentials to Git
- Never share admin codes publicly
- Never use weak passwords
- Never give admin access to untrusted users

## 🚀 How to Access Admin

1. **Tap "Version 1.0.0" 5 times** on welcome screen
2. **Click "Continue"** in admin dialog
3. **Enter your Firebase admin credentials**
4. **Access admin dashboard**

## 🔍 Testing Admin Features

### Upload Questions:
- Go to Admin Dashboard
- Click "Upload Questions"
- Select PDF file
- Enter subject and details

### Verify Questions:
- View pending questions
- Mark as verified
- Manage question quality

### View Analytics:
- Check question statistics
- Monitor user activity
- System overview

## 🛡️ Additional Security Measures

1. **Firebase Authentication Rules**
2. **Firestore Security Rules**
3. **Environment Variables**
4. **Regular Security Audits**
5. **Admin Activity Monitoring**

## 📝 Production Checklist

- [ ] Set up admin user in Firebase Console
- [ ] Configure Firestore security rules
- [ ] Set up environment variables
- [ ] Enable 2FA for admin accounts
- [ ] Test admin access
- [ ] Monitor admin activity
- [ ] Document admin procedures
- [ ] Train admin users on security 