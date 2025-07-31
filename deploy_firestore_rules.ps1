# UTME PrepMaster - Firestore Rules Deployment Script (PowerShell)
# This script deploys the comprehensive Firestore security rules

Write-Host "🚀 UTME PrepMaster - Deploying Firestore Rules" -ForegroundColor Green
Write-Host "==============================================" -ForegroundColor Green

# Check if Firebase CLI is installed
try {
    $null = Get-Command firebase -ErrorAction Stop
    Write-Host "✅ Firebase CLI found" -ForegroundColor Green
} catch {
    Write-Host "❌ Firebase CLI is not installed." -ForegroundColor Red
    Write-Host "Please install it first: npm install -g firebase-tools" -ForegroundColor Yellow
    exit 1
}

# Check if user is logged in
try {
    firebase projects:list 2>$null | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "Not logged in"
    }
    Write-Host "✅ Firebase authentication verified" -ForegroundColor Green
} catch {
    Write-Host "❌ Please login to Firebase first:" -ForegroundColor Red
    Write-Host "firebase login" -ForegroundColor Yellow
    exit 1
}

# Check if rules file exists
if (-not (Test-Path "firestore_final_rules.rules")) {
    Write-Host "❌ Rules file 'firestore_final_rules.rules' not found!" -ForegroundColor Red
    exit 1
}

# Backup existing rules (if any)
Write-Host "📋 Creating backup of existing rules..." -ForegroundColor Cyan
$backupFile = "firestore_backup_$(Get-Date -Format 'yyyyMMdd_HHmmss').rules"
try {
    firebase firestore:rules get > $backupFile 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Backup created: $backupFile" -ForegroundColor Green
    } else {
        Write-Host "ℹ️  No existing rules to backup" -ForegroundColor Yellow
    }
} catch {
    Write-Host "ℹ️  Backup failed or no existing rules" -ForegroundColor Yellow
}

# Copy rules file to firestore.rules for deployment
Copy-Item "firestore_final_rules.rules" "firestore.rules" -Force
Write-Host "✅ Rules file prepared for deployment" -ForegroundColor Green

# Deploy the rules
Write-Host "🚀 Deploying Firestore rules..." -ForegroundColor Cyan
try {
    firebase deploy --only firestore:rules --force
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Firestore rules deployed successfully!" -ForegroundColor Green
        
        Write-Host ""
        Write-Host "🎉 Deployment Complete!" -ForegroundColor Green
        Write-Host "================================" -ForegroundColor Green
        Write-Host "The following features are now enabled:" -ForegroundColor White
        Write-Host "• ✅ Email verification system" -ForegroundColor Green
        Write-Host "• ✅ Comprehensive user data protection" -ForegroundColor Green
        Write-Host "• ✅ Educational content access control" -ForegroundColor Green
        Write-Host "• ✅ Admin panel functionality" -ForegroundColor Green
        Write-Host "• ✅ AI tutor integration" -ForegroundColor Green
        Write-Host "• ✅ Leaderboard access" -ForegroundColor Green
        Write-Host "• ✅ Social features" -ForegroundColor Green
        Write-Host "• ✅ Payment and subscription handling" -ForegroundColor Green
        Write-Host ""
        Write-Host "Test accounts with bypass verification:" -ForegroundColor Yellow
        Write-Host "• m.musembi@alustudent.com" -ForegroundColor White
        Write-Host "• admin@utmeprepmaster.com" -ForegroundColor White
        Write-Host "• michael@utmeprepmaster.com" -ForegroundColor White
        Write-Host "• idarapatrick@gmail.com" -ForegroundColor White
        Write-Host ""
        
    } else {
        throw "Deployment failed"
    }
} catch {
    Write-Host "❌ Failed to deploy Firestore rules" -ForegroundColor Red
    Write-Host "Please check your Firebase project configuration" -ForegroundColor Yellow
    exit 1
}

# Clean up
if (Test-Path "firestore.rules") {
    Remove-Item "firestore.rules" -Force
}

Write-Host "📚 Next Steps:" -ForegroundColor Cyan
Write-Host "1. Test the app with email verification flow" -ForegroundColor White
Write-Host "2. Verify data access permissions work correctly" -ForegroundColor White
Write-Host "3. Check admin functionality in Firebase Console" -ForegroundColor White
Write-Host "4. Monitor Firestore usage and security" -ForegroundColor White
Write-Host ""
Write-Host "Happy coding! 🎓" -ForegroundColor Green

# Pause to let user read the output
Write-Host "Press any key to continue..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
