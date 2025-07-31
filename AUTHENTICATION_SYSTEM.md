# UTME PrepMaster Authentication System

## Overview

The UTME PrepMaster app now implements a secure OTP-based authentication system that ensures one email cannot be registered multiple times and provides a seamless user experience.

## Features

### 1. OTP-Based Authentication
- **Account Creation**: Users receive a 6-digit OTP via email during sign-up
- **Sign In**: Users receive a 6-digit OTP via email during sign-in
- **Google Sign In**: OTP verification is also required for Google authentication
- **Guest Access**: Anonymous users can still access the app without OTP

### 2. Email Uniqueness
- Prevents multiple registrations with the same email address
- Checks email existence before allowing sign-up
- Validates email format and availability

### 3. Security Features
- OTP expires after 5 minutes
- OTP can only be used once
- Rate limiting on OTP resend (60-second cooldown)
- Secure Firebase authentication integration

## Authentication Flow

### Sign Up Process
1. User enters email and password
2. System checks if email is already registered
3. If email is available, creates Firebase user
4. Sends 6-digit OTP to user's email
5. User enters OTP in verification screen
6. Upon successful verification, creates user profile
7. Sends welcome email
8. Navigates to home screen

### Sign In Process
1. User enters email (password field hidden for sign-in)
2. System checks if email is registered
3. If email exists, sends 6-digit OTP to user's email
4. User enters OTP in verification screen
5. Upon successful verification, updates last login
6. Navigates to home screen

### Google Sign In Process
1. User clicks "Continue with Google"
2. Google authentication completes
3. System checks if email is already registered
4. Sends 6-digit OTP to user's email
5. User enters OTP in verification screen
6. Upon successful verification:
   - For new users: Creates user profile and sends welcome email
   - For existing users: Updates last login
7. Navigates to home screen

### Guest Access
1. User clicks "Continue as Guest"
2. Creates anonymous Firebase user
3. Creates user profile
4. Navigates directly to home screen

## Technical Implementation

### Files Created/Modified

#### New Files:
- `lib/data/services/otp_service.dart` - OTP generation and verification
- `lib/data/services/email_service.dart` - Email sending service (mock implementation)
- `lib/presentation/screens/auth/otp_verification_screen.dart` - OTP input and verification UI

#### Modified Files:
- `lib/presentation/screens/auth/auth_screen.dart` - Updated authentication flow
- `lib/main.dart` - Added OTP verification route

### Key Components

#### OtpService
- Generates 6-digit OTPs
- Stores OTPs in Firestore with expiration
- Verifies OTPs and marks them as used
- Checks email registration status
- Creates user profiles
- Updates last login timestamps

#### EmailService
- Mock email service for demonstration
- Sends OTP emails
- Sends welcome emails
- In production, integrate with SendGrid, Mailgun, or AWS SES

#### OtpVerificationScreen
- 6-digit OTP input with auto-focus
- Resend functionality with 60-second cooldown
- Error handling and validation
- Navigation to home screen upon success

## Testing

### OTP Testing
For testing purposes, OTPs are printed to the console:
```
📧 Email sent to user@example.com with OTP: 123456
📧 Subject: Your UTME PrepMaster Verification Code
📧 Body: Your verification code is 123456. This code will expire in 5 minutes.
```

### Test Scenarios
1. **New User Sign Up**: Enter email and password → Receive OTP → Verify → Access app
2. **Existing User Sign In**: Enter email → Receive OTP → Verify → Access app
3. **Google Sign In**: Click Google button → Receive OTP → Verify → Access app
4. **Guest Access**: Click guest button → Direct access to app
5. **Duplicate Email**: Try to sign up with existing email → Error message
6. **Invalid OTP**: Enter wrong OTP → Error message
7. **Expired OTP**: Wait 5 minutes → OTP becomes invalid

## Production Considerations

### Email Service Integration
Replace the mock `EmailService` with a real email service:
- SendGrid
- Mailgun
- AWS SES
- Firebase Functions with email service

### Security Enhancements
- Implement rate limiting on OTP requests
- Add CAPTCHA for OTP requests
- Use Firebase Functions for OTP generation
- Implement proper error handling and logging

### User Experience
- Add email templates with proper branding
- Implement push notifications for OTP delivery
- Add SMS OTP as backup option
- Implement "Remember Me" functionality

## Benefits

1. **Security**: OTP-based authentication is more secure than password-only
2. **Email Verification**: Ensures users have access to their email
3. **No Duplicate Accounts**: Prevents multiple registrations with same email
4. **User-Friendly**: Simple 6-digit code input
5. **Flexible**: Works with email/password and Google authentication
6. **Scalable**: Easy to extend with additional authentication methods

## Future Enhancements

1. **SMS OTP**: Add SMS verification as backup
2. **Biometric Auth**: Add fingerprint/face recognition
3. **Social Login**: Add Facebook, Apple, Twitter login
4. **Two-Factor Auth**: Add 2FA for additional security
5. **Account Recovery**: Implement account recovery process
6. **Session Management**: Add session timeout and auto-logout 