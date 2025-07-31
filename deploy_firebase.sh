#!/bin/bash

# UTME PrepMaster - Firebase Deployment Script
# This script helps deploy your Firestore rules and test the setup

echo "🚀 UTME PrepMaster - Firebase Deployment"
echo "========================================"

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo "❌ Firebase CLI not found. Installing..."
    npm install -g firebase-tools
fi

echo "📋 Deployment Steps:"
echo "1. Login to Firebase"
echo "2. Deploy Firestore Rules"
echo "3. Test the deployment"

# Login to Firebase
echo "🔐 Logging into Firebase..."
firebase login

# Check if firebase.json exists
if [ ! -f "firebase.json" ]; then
    echo "⚠️  firebase.json not found. Initializing Firebase..."
    firebase init firestore
fi

# Deploy rules
echo "📤 Deploying Firestore rules..."
firebase deploy --only firestore:rules

if [ $? -eq 0 ]; then
    echo "✅ Firestore rules deployed successfully!"
    echo ""
    echo "🧪 Testing recommendations:"
    echo "1. Test user authentication and data access"
    echo "2. Verify offline functionality works"
    echo "3. Check admin permissions are properly restricted"
    echo "4. Monitor Firebase Console for any rule violations"
    echo ""
    echo "📊 Monitor your deployment:"
    echo "- Firebase Console: https://console.firebase.google.com/"
    echo "- Firestore Database > Rules tab"
    echo "- Firestore Database > Usage tab"
else
    echo "❌ Deployment failed. Check the error messages above."
    echo "💡 Common solutions:"
    echo "- Ensure you're logged into the correct Firebase project"
    echo "- Check firestore.rules syntax for errors"
    echo "- Verify you have permission to deploy to this project"
fi

echo ""
echo "📖 For detailed instructions, see:"
echo "- FIRESTORE_RULES_DEPLOYMENT.md"
echo "- FIRESTORE_INTEGRATION_GUIDE.md"
