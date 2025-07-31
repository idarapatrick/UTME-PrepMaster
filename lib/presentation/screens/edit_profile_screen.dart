import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import '../../data/services/firestore_service.dart';
import '../theme/app_colors.dart';
import '../../data/nigerian_universities.dart';
import '../widgets/searchable_dropdown.dart';
import '../utils/responsive_helper.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _firstName;
  String? _lastName;
  String? _email;
  String? _phone;
  String? _university1;
  String? _university2;
  String? _university3;
  String? _avatarAsset = 'assets/avatars/avatar1.png';

  // Avatar options
  static const List<Map<String, String>> kAvatars = [
    {'asset': 'assets/avatars/avatar1.png'},
    {'asset': 'assets/avatars/avatar2.png'},
    {'asset': 'assets/avatars/avatar3.png'},
    {'asset': 'assets/avatars/avatar4.png'},
    {'asset': 'assets/avatars/avatar5.png'},
    {'asset': 'assets/avatars/avatar6.png'},
    {'asset': 'assets/avatars/avatar7.png'},
    {'asset': 'assets/avatars/avatar8.png'},
  ];

  @override
  void initState() {
    super.initState();
    _loadExistingUserData();
  }

  Future<void> _loadExistingUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final userData = await FirestoreService.getUserProfile(user.uid);
        if (userData != null) {
          setState(() {
            _firstName = userData['firstName'] ?? '';
            _lastName = userData['lastName'] ?? '';
            _email = userData['email'] ?? '';
            _phone = userData['phone'] ?? '';
            _university1 = userData['university1'] ?? '';
            _university2 = userData['university2'] ?? '';
            _university3 = userData['university3'] ?? '';
            _avatarAsset = userData['avatarUrl'] ?? 'assets/avatars/avatar1.png';
          });
        }
      } catch (e) {
        print('Error loading user data: $e');
      }
    }
  }

  void _changeAvatar() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Select Avatar',
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 18),
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: ResponsiveHelper.getResponsiveGridCrossAxisCount(context),
                crossAxisSpacing: ResponsiveHelper.getResponsiveSpacing(context),
                mainAxisSpacing: ResponsiveHelper.getResponsiveSpacing(context),
              ),
              itemCount: kAvatars.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _avatarAsset = kAvatars[index]['asset']!;
                    });
                    _saveAvatarToFirestore(kAvatars[index]['asset']!);
                    Navigator.pop(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _avatarAsset == kAvatars[index]['asset']
                            ? AppColors.dominantPurple
                            : Colors.grey.shade300,
                        width: _avatarAsset == kAvatars[index]['asset'] ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveBorderRadius(context)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveBorderRadius(context)),
                      child: Image.asset(
                        kAvatars[index]['asset']!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveAvatarToFirestore(String avatarPath) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirestoreService.updateUserProfile(user.uid, {'avatarUrl': avatarPath});
      } catch (e) {
        print('Error saving avatar: $e');
      }
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  Future<void> _checkEmailForAnonymousUser(String email) async {
    if (!_isValidEmail(email)) {
      return; // Don't check invalid emails
    }

    try {
      // Try to create a user with the email to check if it exists
      final tempPassword = _generateRandomPassword();
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.trim(),
        password: tempPassword,
      );
      
      // If successful, the email doesn't exist, so delete the temporary user
      final tempUser = FirebaseAuth.instance.currentUser;
      if (tempUser != null && tempUser.email == email.trim()) {
        await tempUser.delete();
      }
      
      // Show dialog to create account
      if (mounted) {
        _showAccountCreationDialog(email.trim());
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        // Email exists, show error
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Email already in use. Please choose a different email.',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
                ),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Error checking email: $e');
    }
  }

  void _showAccountCreationDialog(String email) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Create Account',
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 18),
            ),
          ),
          content: Text(
            'This email is not registered. Would you like to create an account with this email?',
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showCannotContinueDialog();
              },
              child: Text(
                'No',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _createAccountForAnonymousUser();
              },
              child: Text(
                'Yes',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showCannotContinueDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Cannot Continue',
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 18),
            ),
          ),
          content: Text(
            'You cannot continue editing your profile without creating an account.',
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text(
                'OK',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _generateRandomPassword() {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return String.fromCharCodes(
      Iterable.generate(12, (_) => chars.codeUnitAt(Random().nextInt(chars.length))),
    );
  }

  Future<void> _createAccountForAnonymousUser() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.isAnonymous && _email != null && _email!.isNotEmpty) {
        final password = _generateRandomPassword();
        
        // Create new user with email/password
        final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _email!.trim(),
          password: password,
        );
        
        // Update display name
        await credential.user?.updateDisplayName('${_firstName ?? ''} ${_lastName ?? ''}'.trim());
        
        // Save all profile data to Firestore for the new UID
        final profileData = {
          'firstName': _firstName,
          'lastName': _lastName,
          'email': _email,
          'phone': _phone,
          'university1': _university1,
          'university2': _university2,
          'university3': _university3,
          'avatarUrl': _avatarAsset,
          'lastUpdated': FieldValue.serverTimestamp(),
          'isAnonymous': false,
        };
        
        await FirestoreService.saveFullUserProfile(credential.user!.uid, profileData);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Account created successfully!',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
                ),
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      print('Error creating account: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error creating account. Please try again.',
              style: TextStyle(
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
              ),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      if (_university1 == null || _university1!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Please select your 1st choice university.',
              style: TextStyle(
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
              ),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    _formKey.currentState!.save();
    
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        // Prepare profile data
        final profileData = {
          'firstName': _firstName,
          'lastName': _lastName,
          'email': _email,
          'phone': _phone,
          'university1': _university1,
          'university2': _university2,
          'university3': _university3,
          'avatarUrl': _avatarAsset,
          'lastUpdated': FieldValue.serverTimestamp(),
          'isAnonymous': user.isAnonymous,
        };

        // Save to Firestore
        await FirestoreService.saveFullUserProfile(user.uid, profileData);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Profile updated successfully!',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
                ),
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        print('Error saving profile: $e');
        print('University values: $_university1, $_university2, $_university3');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error saving profile. Please try again.',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
                ),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: TextStyle(
            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 20),
          ),
        ),
        backgroundColor: AppColors.dominantPurple,
        foregroundColor: Colors.white,
      ),
      backgroundColor: isDark
          ? const Color(0xFF181A20)
          : AppColors.backgroundPrimary,
      body: ResponsiveHelper.responsiveSingleChildScrollView(
        context: context,
        child: Padding(
          padding: ResponsiveHelper.getResponsiveEdgeInsets(context),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar Section
                _buildAvatarSection(context, isDark),
                
                SizedBox(height: ResponsiveHelper.getResponsivePadding(context)),
                
                // Personal Information Section
                _buildPersonalInfoSection(context, isDark),
                
                SizedBox(height: ResponsiveHelper.getResponsivePadding(context)),
                
                // University Choices Section
                _buildUniversitySection(context, isDark),
                
                SizedBox(height: ResponsiveHelper.getResponsivePadding(context) * 2),
                
                // Save Button
                _buildSaveButton(context),
                
                SizedBox(height: ResponsiveHelper.getResponsivePadding(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection(BuildContext context, bool isDark) {
    return ResponsiveHelper.responsiveCard(
      context: context,
      color: isDark ? const Color(0xFF23243B) : Colors.white,
      child: Column(
        children: [
          Text(
            'Profile Picture',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          SizedBox(height: ResponsiveHelper.getResponsivePadding(context)),
          GestureDetector(
            onTap: () => _changeAvatar(),
            child: CircleAvatar(
              radius: ResponsiveHelper.getResponsiveIconSize(context, 50),
              backgroundColor: AppColors.dominantPurple.withValues(alpha: 0.1),
              backgroundImage: _avatarAsset != null && _avatarAsset!.isNotEmpty
                  ? AssetImage(_avatarAsset!)
                  : null,
              child: _avatarAsset == null || _avatarAsset!.isEmpty
                  ? Icon(
                      Icons.person,
                      color: AppColors.dominantPurple,
                      size: ResponsiveHelper.getResponsiveIconSize(context, 50),
                    )
                  : null,
            ),
          ),
          SizedBox(height: ResponsiveHelper.getResponsivePadding(context) / 2),
          Text(
            'Tap to change avatar',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection(BuildContext context, bool isDark) {
    return ResponsiveHelper.responsiveCard(
      context: context,
      color: isDark ? const Color(0xFF23243B) : Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personal Information',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          SizedBox(height: ResponsiveHelper.getResponsivePadding(context)),
          
          // First Name
          ResponsiveHelper.responsiveTextField(
            context: context,
            label: 'First Name',
            controller: TextEditingController(text: _firstName),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your first name';
              }
              return null;
            },
            onChanged: (value) => _firstName = value,
          ),
          
          SizedBox(height: ResponsiveHelper.getResponsivePadding(context)),
          
          // Last Name
          ResponsiveHelper.responsiveTextField(
            context: context,
            label: 'Last Name',
            controller: TextEditingController(text: _lastName),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your last name';
              }
              return null;
            },
            onChanged: (value) => _lastName = value,
          ),
          
          SizedBox(height: ResponsiveHelper.getResponsivePadding(context)),
          
          // Email
          ResponsiveHelper.responsiveTextField(
            context: context,
            label: 'Email',
            controller: TextEditingController(text: _email),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!value.contains('@')) {
                return 'Please enter a valid email';
              }
              return null;
            },
            onChanged: (value) => _email = value,
            onEditingComplete: () {
              final user = FirebaseAuth.instance.currentUser;
              if (user != null && user.isAnonymous && _email != null && _email!.isNotEmpty) {
                _checkEmailForAnonymousUser(_email!);
              }
            },
          ),
          
          SizedBox(height: ResponsiveHelper.getResponsivePadding(context)),
          
          // Phone
          ResponsiveHelper.responsiveTextField(
            context: context,
            label: 'Phone Number',
            controller: TextEditingController(text: _phone),
            keyboardType: TextInputType.phone,
            onChanged: (value) => _phone = value,
          ),
        ],
      ),
    );
  }

  Widget _buildUniversitySection(BuildContext context, bool isDark) {
    return ResponsiveHelper.responsiveCard(
      context: context,
      color: isDark ? const Color(0xFF23243B) : Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'University Choices',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          SizedBox(height: ResponsiveHelper.getResponsivePadding(context)),
          
          // 1st Choice
          SearchableDropdown(
            options: nigerianUniversities,
            value: _university1,
            onChanged: (value) {
              setState(() => _university1 = value);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _formKey.currentState?.validate();
              });
            },
            label: '1st Choice University *',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select your 1st choice university';
              }
              return null;
            },
          ),
          
          SizedBox(height: ResponsiveHelper.getResponsivePadding(context)),
          
          // 2nd Choice
          SearchableDropdown(
            options: nigerianUniversities,
            value: _university2,
            onChanged: (value) => setState(() => _university2 = value),
            label: '2nd Choice University',
          ),
          
          SizedBox(height: ResponsiveHelper.getResponsivePadding(context)),
          
          // 3rd Choice
          SearchableDropdown(
            options: nigerianUniversities,
            value: _university3,
            onChanged: (value) => setState(() => _university3 = value),
            label: '3rd Choice University',
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return ResponsiveHelper.responsiveButton(
      context: context,
      text: 'Save Changes',
      onPressed: _saveProfile,
      backgroundColor: AppColors.dominantPurple,
      foregroundColor: Colors.white,
    );
  }
}
