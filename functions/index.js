const functions = require('firebase-functions');
const admin = require('firebase-admin');
const nodemailer = require('nodemailer');

admin.initializeApp();

// Configure email transporter using environment variables
const transporter = nodemailer.createTransporter({
  service: 'gmail',
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS,
  },
});

// Send OTP Email
exports.sendOtpEmail = functions.https.onCall(async (data, context) => {
  try {
    const { email } = data;
    
    if (!email) {
      return { success: false, error: 'Email is required' };
    }

    // Generate 6-digit OTP
    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    
    // Store OTP in Firestore with expiration (5 minutes)
    await admin.firestore().collection('otp_codes').doc(email).set({
      otp: otp,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      expires_at: new Date(Date.now() + 5 * 60 * 1000), // 5 minutes
      verified: false,
    });

    // Email content
    const mailOptions = {
      from: process.env.EMAIL_USER,
      to: email,
      subject: 'UTME PrepMaster - Email Verification Code',
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h2 style="color: #6B46C1;">UTME PrepMaster</h2>
          <h3>Email Verification Code</h3>
          <p>Your verification code is:</p>
          <div style="background-color: #F3F4F6; padding: 20px; text-align: center; border-radius: 8px;">
            <h1 style="color: #6B46C1; font-size: 32px; margin: 0;">${otp}</h1>
          </div>
          <p>This code will expire in 5 minutes.</p>
          <p>If you didn't request this code, please ignore this email.</p>
          <hr>
          <p style="color: #6B7280; font-size: 12px;">
            This is an automated email from UTME PrepMaster.
          </p>
        </div>
      `,
    };

    // Send email
    await transporter.sendMail(mailOptions);

    return { success: true };
  } catch (error) {
    console.error('Error sending OTP email:', error);
    return { success: false, error: error.message };
  }
});

// Verify OTP
exports.verifyOtp = functions.https.onCall(async (data, context) => {
  try {
    const { email, otp } = data;
    
    if (!email || !otp) {
      return { success: false, error: 'Email and OTP are required' };
    }

    // Get OTP from Firestore
    const doc = await admin.firestore().collection('otp_codes').doc(email).get();
    
    if (!doc.exists) {
      return { success: false, error: 'OTP not found' };
    }

    const data = doc.data();
    const storedOtp = data.otp;
    const timestamp = data.timestamp;
    const verified = data.verified || false;

    if (verified) {
      return { success: false, error: 'OTP already used' };
    }

    // Check if OTP is expired (5 minutes)
    const now = admin.firestore.Timestamp.now();
    const difference = now.seconds - timestamp.seconds;
    
    if (difference > 300) { // 5 minutes = 300 seconds
      return { success: false, error: 'OTP expired' };
    }

    if (storedOtp === otp) {
      // Mark OTP as verified
      await admin.firestore().collection('otp_codes').doc(email).update({
        verified: true,
      });
      
      return { success: true };
    } else {
      return { success: false, error: 'Invalid OTP' };
    }
  } catch (error) {
    console.error('Error verifying OTP:', error);
    return { success: false, error: error.message };
  }
});

// Welcome Email
exports.sendWelcomeEmail = functions.https.onCall(async (data, context) => {
  try {
    const { email, displayName } = data;
    
    const mailOptions = {
      from: process.env.EMAIL_USER,
      to: email,
      subject: 'Welcome to UTME PrepMaster!',
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h2 style="color: #6B46C1;">Welcome to UTME PrepMaster!</h2>
          <p>Hi ${displayName},</p>
          <p>Thank you for joining UTME PrepMaster! Your account has been successfully created.</p>
          <p>Start your journey to UTME success with:</p>
          <ul>
            <li>Practice tests and questions</li>
            <li>AI-powered learning assistance</li>
            <li>Progress tracking and analytics</li>
            <li>Leaderboards and achievements</li>
          </ul>
          <p>Ready to ace your UTME? Let's get started!</p>
          <hr>
          <p style="color: #6B7280; font-size: 12px;">
            This is an automated email from UTME PrepMaster.
          </p>
        </div>
      `,
    };

    await transporter.sendMail(mailOptions);
    return { success: true };
  } catch (error) {
    console.error('Error sending welcome email:', error);
    return { success: false, error: error.message };
  }
});