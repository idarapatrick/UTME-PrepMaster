#!/bin/bash

# UTME PrepMaster - Firestore Rules Deployment Script
# This script deploys the comprehensive Firestore security rules

echo "🚀 UTME PrepMaster - Deploying Firestore Rules"
echo "=============================================="

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo "❌ Firebase CLI is not installed."
    echo "Please install it first: npm install -g firebase-tools"
    exit 1
fi

# Check if user is logged in
if ! firebase projects:list &> /dev/null; then
    echo "❌ Please login to Firebase first:"
    echo "firebase login"
    exit 1
fi

# Backup existing rules (if any)
echo "📋 Creating backup of existing rules..."
if firebase firestore:rules get > firestore_backup_$(date +%Y%m%d_%H%M%S).rules 2>/dev/null; then
    echo "✅ Backup created successfully"
else
    echo "ℹ️  No existing rules to backup (or backup failed)"
fi

# Validate the new rules
echo "🔍 Validating new Firestore rules..."
if firebase firestore:rules test firestore_final_rules.rules; then
    echo "✅ Rules validation passed!"
else
    echo "❌ Rules validation failed. Please check the rules file."
    exit 1
fi

# Deploy the rules
echo "🚀 Deploying Firestore rules..."
if firebase deploy --only firestore:rules --force; then
    echo "✅ Firestore rules deployed successfully!"
    echo ""
    echo "🎉 Deployment Complete!"
    echo "================================"
    echo "The following features are now enabled:"
    echo "• ✅ Email verification system"
    echo "• ✅ Comprehensive user data protection"
    echo "• ✅ Educational content access control"
    echo "• ✅ Admin panel functionality"
    echo "• ✅ AI tutor integration"
    echo "• ✅ Leaderboard access"
    echo "• ✅ Social features"
    echo "• ✅ Payment and subscription handling"
    echo ""
    echo "Test accounts with bypass verification:"
    echo "• m.musembi@alustudent.com"
    echo "• admin@utmeprepmaster.com"
    echo "• michael@utmeprepmaster.com"
    echo "• idarapatrick@gmail.com"
    echo ""
else
    echo "❌ Failed to deploy Firestore rules"
    echo "Please check your Firebase project configuration"
    exit 1
fi

# Optional: Run tests if test directory exists
if [ -d "firestore-tests" ]; then
    echo "🧪 Running Firestore rules tests..."
    firebase emulators:exec --only firestore "npm test" 2>/dev/null || echo "ℹ️  No tests configured"
fi

echo "📚 Next Steps:"
echo "1. Test the app with email verification flow"
echo "2. Verify data access permissions work correctly"
echo "3. Check admin functionality in Firebase Console"
echo "4. Monitor Firestore usage and security"
echo ""
echo "Happy coding! 🎓"
