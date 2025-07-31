# Firestore Rules Deployment Guide

## Step 1: Deploy Firestore Security Rules

### Option A: Using Firebase Console (Recommended)

1. **Open Firebase Console**
   - Go to https://console.firebase.google.com/
   - Select your UTME PrepMaster project

2. **Navigate to Firestore Database**
   - Click on "Firestore Database" in the left sidebar
   - Click on the "Rules" tab

3. **Copy and Paste Rules**
   - Delete all existing content in the rules editor
   - Copy the entire content from `firestore.rules` file in your project
   - Paste it into the Firebase Console rules editor

4. **Publish Rules**
   - Click "Publish" button
   - Confirm the deployment

### Option B: Using Firebase CLI

```bash
# Install Firebase CLI if you haven't already
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase in your project (if not done)
firebase init firestore

# Deploy rules
firebase deploy --only firestore:rules
```

## Step 2: Verify Firestore Rules Are Complete

✅ **Your firestore.rules file includes:**

### User Data Protection
- Users can only read/write their own data
- Nested collections (tests, progress, notes) are protected
- Email verification status tracking

### Public Collections (Read-Only)
- Leaderboard data
- Achievements/badges
- Subjects and topics
- Universities data

### Admin Protection
- Admin collections require specific email authentication
- Only designated admins can modify system data

### Data Validation
- Built-in validation functions for user data
- Test result validation
- Progress tracking validation

## Step 3: Test Your Rules

After deployment, test with these scenarios:

### Test 1: User Data Access
```dart
// Should work - user accessing own data
final userDoc = await FirebaseFirestore.instance
    .collection('users')
    .doc(currentUser.uid)
    .get();

// Should fail - user accessing other's data
final otherDoc = await FirebaseFirestore.instance
    .collection('users')
    .doc('other-user-id')
    .get();
```

### Test 2: Public Data Access
```dart
// Should work - reading leaderboard
final leaderboard = await FirebaseFirestore.instance
    .collection('leaderboard')
    .get();

// Should fail - writing to leaderboard
await FirebaseFirestore.instance
    .collection('leaderboard')
    .add({'test': 'data'}); // This should be blocked
```

### Test 3: Offline Functionality
```dart
// Should work offline
await FirebaseFirestore.instance.enablePersistence();
```

## Step 4: Monitor Rules Performance

1. **Check Firebase Console**
   - Go to Firestore Database > Usage tab
   - Monitor read/write operations
   - Check for any security violations

2. **Enable Audit Logs** (Optional)
   - Go to Firestore Database > Rules tab
   - Enable "Rules evaluation" logging

## Step 5: Production Checklist

✅ **Before going live:**

- [ ] Rules deployed successfully
- [ ] Test user data isolation
- [ ] Test admin permissions
- [ ] Verify offline persistence works
- [ ] Monitor initial usage patterns
- [ ] Set up billing alerts
- [ ] Configure backup strategy

## Complete Firestore Rules Summary

Your `firestore.rules` file provides:

1. **Security**: Users can only access their own data
2. **Admin Control**: Protected admin collections
3. **Public Data**: Read-only access to shared resources
4. **Validation**: Built-in data validation functions
5. **Scalability**: Optimized for performance and cost

## Troubleshooting

### Common Issues:

**"Permission denied" errors:**
- Check if user is authenticated
- Verify user is accessing their own data
- Ensure rules are published correctly

**Rules not applying:**
- Wait 1-2 minutes after deployment
- Clear app cache and restart
- Check Firebase Console for rule syntax errors

**Offline data not working:**
- Ensure persistence is enabled in code
- Check device storage permissions
- Verify network connectivity

Your Firestore rules are production-ready and comprehensive! 🚀
