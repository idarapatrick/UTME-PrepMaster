# 🔐 UTME PrepMaster - Firestore Security Rules

## Overview

This document contains comprehensive Firestore security rules for the UTME PrepMaster application. These rules implement a robust email verification system and secure access controls for all app data.

## 🚀 Quick Deployment

### Option 1: PowerShell (Windows)
```powershell
.\deploy_firestore_rules.ps1
```

### Option 2: Bash (Linux/Mac/WSL)
```bash
chmod +x deploy_firestore_rules.sh
./deploy_firestore_rules.sh
```

### Option 3: Manual Deployment
```bash
# Copy rules to firestore.rules
cp firestore_final_rules.rules firestore.rules

# Deploy to Firebase
firebase deploy --only firestore:rules
```

## 🔑 Key Features

### Email Verification System
- **Required for all users** except test accounts
- **Automatic bypass** for admin emails
- **Real-time verification** status tracking
- **Comprehensive logging** for debugging

### Security Levels
1. **Public Access**: Legal documents (terms, privacy)
2. **Authenticated Only**: Basic app features, FAQs
3. **Verified Users**: Full app functionality
4. **Admin Only**: Content management, user administration

### Test Accounts (Email Verification Bypass)
- `m.musembi@alustudent.com`
- `admin@utmeprepmaster.com`
- `michael@utmeprepmaster.com`
- `idarapatrick@gmail.com`

## 📊 Collection Security Overview

| Collection Type | Read Access | Write Access | Notes |
|---|---|---|---|
| **User Data** | Owner + Admin | Owner + Admin | Personal data protection |
| **Educational Content** | Verified Users | Admin Only | Questions, subjects, materials |
| **Email Verification** | Owner + Admin | Owner + Admin | Verification tracking |
| **Leaderboards** | Verified Users | Admin Only | Rankings and achievements |
| **AI Sessions** | Owner + Admin | Owner + Admin | Personal AI interactions |
| **System Config** | Authenticated | Admin Only | App configuration |
| **Admin Panel** | Admin Only | Admin Only | Administrative functions |

## 🔧 Troubleshooting

### Common Issues

#### 1. Permission Denied Errors
```
PERMISSION_DENIED: Missing or insufficient permissions
```
**Solutions:**
- Ensure user email is verified
- Check if user is using a test account
- Verify Firebase Authentication is working
- Refresh user token: `user.reload()`

#### 2. Email Verification Not Working
```
User cannot access data despite being authenticated
```
**Solutions:**
- Check if `email_verified` is true in Firebase Auth
- Use test accounts for debugging
- Verify email verification service is configured
- Check verification status in Firestore

#### 3. Admin Access Issues
```
Admin functions not accessible
```
**Solutions:**
- Verify admin email is in the approved list
- Check Firebase Auth email claim
- Ensure proper admin role assignment

### Debugging Tools

#### Check User Authentication Status
```dart
final user = FirebaseAuth.instance.currentUser;
print('User ID: ${user?.uid}');
print('Email: ${user?.email}');
print('Email Verified: ${user?.emailVerified}');
```

#### Test Firestore Rules
```bash
firebase firestore:rules test
```

#### Monitor Firestore in Real-time
```bash
firebase firestore:logs
```

## 📱 Integration with Flutter App

### 1. Email Verification Check
```dart
// Before accessing protected data
if (EmailVerificationService.requiresEmailVerification(user)) {
  // Show verification screen
  return EmailVerificationScreen();
}
```

### 2. Error Handling
```dart
try {
  await firestore.collection('users').doc(userId).get();
} on FirebaseException catch (e) {
  if (e.code == 'permission-denied') {
    // Handle verification requirement
    await EmailVerificationService.sendEmailVerification();
  }
}
```

### 3. Admin Functions
```dart
// Check admin status before showing admin UI
final isAdmin = await AdminService.isUserAdmin();
if (isAdmin) {
  // Show admin panel
}
```

## 🔄 Rule Updates

### When to Update Rules
- Adding new collections
- Changing access patterns
- Security requirement changes
- New user roles or permissions

### Safe Update Process
1. **Test locally** with Firebase emulator
2. **Backup existing rules** (done automatically by deploy script)
3. **Deploy during low-traffic** periods
4. **Monitor logs** for permission errors
5. **Rollback if needed** using backup

### Testing New Rules
```bash
# Start emulator
firebase emulators:start --only firestore

# Run tests
npm test

# Or test manually with emulator UI
open http://localhost:4000
```

## 📈 Monitoring and Analytics

### Key Metrics to Monitor
- **Permission denied errors**: High rates indicate rule issues
- **Verification completion rates**: Track email verification success
- **Admin access patterns**: Monitor administrative activities
- **Data access patterns**: Identify performance bottlenecks

### Firebase Console Monitoring
1. Go to **Firestore > Usage tab**
2. Monitor **Read/Write operations**
3. Check **Security rules evaluation**
4. Review **Error logs** for permission issues

### Custom Analytics
```dart
// Track verification events
Analytics.logEvent('email_verification_sent');
Analytics.logEvent('email_verification_completed');

// Track permission errors
Analytics.logEvent('permission_denied', parameters: {
  'collection': collectionName,
  'user_verified': user.emailVerified,
});
```

## 🚨 Security Best Practices

### 1. Regular Security Audits
- Review access logs monthly
- Check for unusual access patterns
- Validate admin user list
- Monitor failed permission attempts

### 2. User Data Protection
- Never expose sensitive user data
- Implement proper data validation
- Use server-side validation for critical operations
- Regular backup of user data

### 3. Email Verification Security
- Use secure email templates
- Implement rate limiting for verification emails
- Log all verification attempts
- Monitor for verification abuse

### 4. Admin Security
- Use strong authentication for admin accounts
- Implement multi-factor authentication
- Regular admin access reviews
- Separate admin functions from user functions

## 🆘 Emergency Procedures

### 1. Security Breach Response
```bash
# Immediately restrict all access
firebase firestore:rules deploy emergency_lockdown.rules

# Investigate and fix
# Deploy proper rules when safe
firebase firestore:rules deploy firestore_final_rules.rules
```

### 2. Data Recovery
```bash
# Restore from backup if needed
firebase firestore:rules deploy firestore_backup_[timestamp].rules
```

### 3. Emergency Contacts
- Firebase Support: [Firebase Console > Support]
- Development Team: [Your team contact info]
- Security Team: [Security contact info]

## 📚 Additional Resources

- [Firebase Security Rules Documentation](https://firebase.google.com/docs/firestore/security/get-started)
- [Email Verification Best Practices](https://firebase.google.com/docs/auth/web/email-verification)
- [Firestore Security Rules Testing](https://firebase.google.com/docs/firestore/security/test-rules)
- [Firebase Auth Documentation](https://firebase.google.com/docs/auth)

---

**Last Updated**: Generated for UTME PrepMaster v1.0  
**Rule Version**: Final Comprehensive Rules  
**Compatibility**: Firebase v9+, Flutter 3.0+
