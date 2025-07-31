# UTME PrepMaster Demo Checklist

## Demo Requirements from Rubric

### ✅ 1. Cold-start Launch
- [ ] Close app completely
- [ ] Launch app from scratch
- [ ] Show splash screen → onboarding → authentication flow
- [ ] Demonstrate smooth loading and transitions

### ✅ 2. Register → Logout → Login
- [ ] **Email/Password Registration:**
  - [ ] Show password validation (length, uppercase, lowercase, number, special char)
  - [ ] Show email verification flow
  - [ ] Demonstrate error handling for invalid inputs
- [ ] **Google Sign-up:**
  - [ ] Show Google authentication
  - [ ] Show name completion screen
  - [ ] Show email verification for Google users
- [ ] **Logout:**
  - [ ] Navigate to settings
  - [ ] Show logout confirmation
  - [ ] Demonstrate app returning to auth screen
- [ ] **Login:**
  - [ ] Show login with existing account
  - [ ] Show email verification check
  - [ ] Demonstrate successful login

### ✅ 3. Visit Every Screen and Rotate
- [ ] **Home Screen (Dashboard):**
  - [ ] Show user stats (streak, badges, XP)
  - [ ] Show subject cards
  - [ ] Rotate device
- [ ] **Subject Selection:**
  - [ ] Show subject picker
  - [ ] Demonstrate subject saving
  - [ ] Rotate device
- [ ] **Course Content:**
  - [ ] Show syllabi tab with external links
  - [ ] Show quizzes tab
  - [ ] Demonstrate link opening
  - [ ] Rotate device
- [ ] **Mock Tests:**
  - [ ] Show test selection
  - [ ] Show test interface
  - [ ] Rotate device
- [ ] **AI Tutor:**
  - [ ] Show AI interface
  - [ ] Demonstrate AI responses
  - [ ] Rotate device
- [ ] **Profile Screen:**
  - [ ] Show user information
  - [ ] Show achievements
  - [ ] Rotate device
- [ ] **Settings:**
  - [ ] Show settings options
  - [ ] Show theme toggle
  - [ ] Rotate device
- [ ] **My Library:**
  - [ ] Show notes section
  - [ ] Show links section
  - [ ] Rotate device
- [ ] **Badges Screen:**
  - [ ] Show earned badges
  - [ ] Show badge animations
  - [ ] Rotate device
- [ ] **Leaderboard:**
  - [ ] Show rankings
  - [ ] Show user position
  - [ ] Rotate device
- [ ] **Study Partner:**
  - [ ] Show partner interface
  - [ ] Show matching features
  - [ ] Rotate device

### ✅ 4. CRUD Operations in Firestore (with Firebase Console visible)
- [ ] **Create:**
  - [ ] Add a new study note
  - [ ] Show note appearing in Firestore Console
  - [ ] Demonstrate real-time updates
- [ ] **Read:**
  - [ ] Show notes loading from Firestore
  - [ ] Show user data in Firestore Console
  - [ ] Demonstrate data persistence
- [ ] **Update:**
  - [ ] Edit an existing note
  - [ ] Show changes in Firestore Console
  - [ ] Demonstrate real-time updates
- [ ] **Delete:**
  - [ ] Delete a note with confirmation
  - [ ] Show deletion in Firestore Console
  - [ ] Demonstrate data removal

### ✅ 5. State Update Touching Two Widgets
- [ ] **User Stats Update:**
  - [ ] Complete a quiz/test
  - [ ] Show XP increase in home screen
  - [ ] Show XP increase in profile screen
  - [ ] Demonstrate state synchronization
- [ ] **Badge Achievement:**
  - [ ] Trigger a badge unlock
  - [ ] Show badge in home screen
  - [ ] Show badge in badges screen
  - [ ] Demonstrate cross-screen updates

### ✅ 6. SharedPreferences Persistence
- [ ] **Theme Setting:**
  - [ ] Change theme in settings
  - [ ] Show setting saved
  - [ ] Restart app completely
  - [ ] Show theme persisted
- [ ] **User Preferences:**
  - [ ] Toggle notifications setting
  - [ ] Toggle sound setting
  - [ ] Restart app
  - [ ] Show settings persisted

### ✅ 7. Validation Error with Polite Message
- [ ] **Password Validation:**
  - [ ] Try to register with weak password
  - [ ] Show specific validation messages
  - [ ] Demonstrate real-time validation
- [ ] **Email Validation:**
  - [ ] Try to register with invalid email
  - [ ] Show polite error message
  - [ ] Demonstrate form validation
- [ ] **Form Validation:**
  - [ ] Try to submit empty forms
  - [ ] Show helpful error messages
  - [ ] Demonstrate user-friendly feedback

## Demo Script Flow

### Opening (30 seconds)
1. **Cold Start:** "Let me start by showing you the app launch from a completely closed state"
2. **Splash Screen:** "You can see our splash screen with the app logo"
3. **Onboarding:** "This is our onboarding flow introducing the app features"

### Authentication (1 minute)
1. **Registration:** "Now I'll demonstrate the registration process with email validation"
2. **Password Validation:** "Notice the real-time password validation with specific requirements"
3. **Email Verification:** "After registration, users must verify their email"
4. **Google Sign-up:** "We also support Google authentication"
5. **Logout/Login:** "Let me show you the logout and login flow"

### Core Features (2 minutes)
1. **Home Dashboard:** "This is our main dashboard showing user progress and subjects"
2. **Subject Selection:** "Users can select their UTME subjects"
3. **Course Content:** "Here's our course content with external links and quizzes"
4. **Mock Tests:** "We have comprehensive mock tests for practice"
5. **AI Tutor:** "Our AI tutor provides personalized help"

### CRUD Operations (1 minute)
1. **Firebase Console:** "I'll keep the Firebase Console visible to show real-time data"
2. **Create Note:** "Let me add a new study note" (show in console)
3. **Read Notes:** "You can see all notes loading from Firestore"
4. **Update Note:** "I'll edit this note" (show changes in console)
5. **Delete Note:** "Now I'll delete it with confirmation" (show removal in console)

### State Management (30 seconds)
1. **Stats Update:** "Watch how completing a quiz updates stats across multiple screens"
2. **Badge System:** "Achievements trigger updates in both home and badges screens"

### Settings & Persistence (30 seconds)
1. **Theme Toggle:** "I'll change the theme setting"
2. **App Restart:** "Now I'll restart the app completely"
3. **Persistence:** "You can see the theme setting persisted"

### Validation (30 seconds)
1. **Password Error:** "Let me show you our validation system"
2. **Email Error:** "We provide helpful, polite error messages"
3. **Form Validation:** "Real-time validation helps users understand requirements"

### Responsiveness (30 seconds)
1. **Screen Rotation:** "Our app is fully responsive"
2. **Different Screens:** "Let me rotate on each screen to show adaptability"

## Technical Requirements

### Firebase Setup
- [ ] Firebase Console open and visible
- [ ] Real-time database updates shown
- [ ] Authentication flow demonstrated
- [ ] Firestore CRUD operations visible

### Device Requirements
- [ ] Physical Android phone (not emulator)
- [ ] Release APK installed
- [ ] Good lighting for video recording
- [ ] Stable internet connection

### Recording Requirements
- [ ] Single continuous recording
- [ ] No slide deck
- [ ] No team introductions
- [ ] Clear audio narration
- [ ] Smooth transitions between features

## Demo Tips

### Before Demo
1. **Test Everything:** Ensure all features work perfectly
2. **Prepare Data:** Have some sample notes and links ready
3. **Check Internet:** Ensure stable connection for Firebase
4. **Clear Cache:** Start with fresh app state
5. **Practice Flow:** Rehearse the demo sequence

### During Demo
1. **Speak Clearly:** Narrate what you're doing
2. **Show Console:** Keep Firebase Console visible
3. **Demonstrate Errors:** Show validation gracefully
4. **Highlight Features:** Point out key functionality
5. **Maintain Pace:** Keep demo moving smoothly

### After Demo
1. **Answer Questions:** Be prepared for technical questions
2. **Show Code:** Be ready to explain implementation
3. **Discuss Architecture:** Explain Firebase integration
4. **Highlight Innovation:** Show unique features

## Success Criteria
- [ ] All 7 rubric points covered
- [ ] Smooth, professional presentation
- [ ] Technical depth demonstrated
- [ ] User experience highlighted
- [ ] Firebase integration showcased
- [ ] Responsive design proven
- [ ] Error handling shown
- [ ] Data persistence demonstrated 