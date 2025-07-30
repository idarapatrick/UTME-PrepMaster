# 🔐 Admin Setup Guide

## How to Create Admin Users

### Method 1: Firebase Console (Recommended)

1. **Go to Firebase Console**
   - Visit: https://console.firebase.google.com
   - Select your UTME PrepMaster project

2. **Create User in Authentication**
   - Go to Authentication → Users
   - Click "Add User"
   - Enter your admin email (e.g., `your-admin@yourdomain.com`)
   - Enter a strong password
   - Click "Add User"

3. **Set User Role in Firestore**
   - Go to Firestore Database
   - Navigate to `users` collection
   - Create document with the user's UID (from Authentication)
   - Add this data structure:

```json
{
  "email": "your-admin@yourdomain.com",
  "role": "admin",
  "adminCode": "YOUR_SECURE_ADMIN_CODE",
  "permissions": ["upload", "verify", "delete", "manage"],
  "createdAt": "2024-01-01",
  "isActive": true,
  "displayName": "Admin User"
}
```

### Method 2: Using Firebase Admin SDK (For Developers)

You can also create admin users programmatically using Firebase Admin SDK:

```javascript
// Example using Firebase Admin SDK
const admin = require('firebase-admin');

async function createAdminUser(email, password, adminCode) {
  const userRecord = await admin.auth().createUser({
    email: email,
    password: password,
  });

  await admin.firestore().collection('users').doc(userRecord.uid).set({
    email: email,
    role: 'admin',
    adminCode: adminCode,
    permissions: ['upload', 'verify', 'delete', 'manage'],
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    isActive: true,
  });
}
```

## Admin Login Process

### How to Access Admin:
1. **Tap "Version 1.0.0" 5 times** on welcome screen
2. **Click "Continue"** in admin dialog
3. **Enter your admin credentials** in admin login screen
4. **Access admin dashboard**

### Security Features:
- ✅ Admin access is hidden from regular users
- ✅ Role verification happens in Firestore
- ✅ Admin code provides additional security
- ✅ Only admins can upload/verify questions
- ✅ No hardcoded credentials in code

## Testing Admin Features

1. **Upload Questions**
   - Go to Admin Dashboard
   - Click "Upload Questions"
   - Select PDF file
   - Enter subject and details

2. **Verify Questions**
   - View pending questions
   - Mark as verified
   - Manage question quality

3. **View Analytics**
   - Check question statistics
   - Monitor user activity
   - System overview

## Important Security Notes

- 🔒 **Never commit admin credentials to Git**
- 🔒 **Use strong passwords for admin accounts**
- 🔒 **Change admin codes regularly**
- 🔒 **Limit admin access to trusted users only**
- 🔒 **Monitor admin activity in Firebase Console** 