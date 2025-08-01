import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
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
            _avatarAsset =
                userData['avatarUrl'] ?? 'assets/avatars/avatar1.png';

            // Update controllers with loaded data
            _firstNameController.text = _firstName ?? '';
            _lastNameController.text = _lastName ?? '';
            _emailController.text = _email ?? '';
            _phoneController.text = _phone ?? '';
          });
        }
      } catch (e) {
        // Error loading user data
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
                crossAxisCount:
                    ResponsiveHelper.getResponsiveGridCrossAxisCount(context),
                crossAxisSpacing: ResponsiveHelper.getResponsiveSpacing(
                  context,
                ),
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
                            : AppColors.getBorderLight(context),
                        width: _avatarAsset == kAvatars[index]['asset'] ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(
                        ResponsiveHelper.getResponsiveBorderRadius(context),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        ResponsiveHelper.getResponsiveBorderRadius(context),
                      ),
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
        await FirestoreService.updateUserProfile(user.uid, {
          'avatarUrl': avatarPath,
        });
      } catch (e) {
        // Error saving avatar
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    // Get values from controllers
    _firstName = _firstNameController.text.trim();
    _lastName = _lastNameController.text.trim();
    _email = _emailController.text.trim();
    _phone = _phoneController.text.trim();

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

        // Also update using the model method for consistency
        final userProfile = {
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

        await FirestoreService.updateUserProfile(user.uid, userProfile);

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
        // Error saving profile
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

                SizedBox(
                  height: ResponsiveHelper.getResponsivePadding(context),
                ),

                // Personal Information Section
                _buildPersonalInfoSection(context, isDark),

                SizedBox(
                  height: ResponsiveHelper.getResponsivePadding(context),
                ),

                // University Choices Section
                _buildUniversitySection(context, isDark),

                SizedBox(
                  height: ResponsiveHelper.getResponsivePadding(context) * 2,
                ),

                // Save Button
                _buildSaveButton(context),

                SizedBox(
                  height: ResponsiveHelper.getResponsivePadding(context),
                ),
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
            controller: _firstNameController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your first name';
              }
              return null;
            },
          ),

          SizedBox(height: ResponsiveHelper.getResponsivePadding(context)),

          // Last Name
          ResponsiveHelper.responsiveTextField(
            context: context,
            label: 'Last Name',
            controller: _lastNameController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your last name';
              }
              return null;
            },
          ),

          SizedBox(height: ResponsiveHelper.getResponsivePadding(context)),

          // Email
          ResponsiveHelper.responsiveTextField(
            context: context,
            label: 'Email',
            controller: _emailController,
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
          ),

          SizedBox(height: ResponsiveHelper.getResponsivePadding(context)),

          // Phone
          ResponsiveHelper.responsiveTextField(
            context: context,
            label: 'Phone Number',
            controller: _phoneController,
            keyboardType: TextInputType.phone,
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.dominantPurple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '1st Choice',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.dominantPurple,
                  ),
                ),
              ),
              SizedBox(
                height: ResponsiveHelper.getResponsivePadding(context) * 0.5,
              ),
              SearchableDropdown(
                options: nigerianUniversities,
                value: _university1,
                onChanged: (value) {
                  setState(() => _university1 = value);
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _formKey.currentState?.validate();
                  });
                },
                label: 'Select your 1st choice university *',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select your 1st choice university';
                  }
                  return null;
                },
              ),
            ],
          ),

          SizedBox(height: ResponsiveHelper.getResponsivePadding(context)),

          // 2nd Choice
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '2nd Choice',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
              SizedBox(
                height: ResponsiveHelper.getResponsivePadding(context) * 0.5,
              ),
              SearchableDropdown(
                options: nigerianUniversities,
                value: _university2,
                onChanged: (value) => setState(() => _university2 = value),
                label: 'Select your 2nd choice university',
              ),
            ],
          ),

          SizedBox(height: ResponsiveHelper.getResponsivePadding(context)),

          // 3rd Choice
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '3rd Choice',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
              SizedBox(
                height: ResponsiveHelper.getResponsivePadding(context) * 0.5,
              ),
              SearchableDropdown(
                options: nigerianUniversities,
                value: _university3,
                onChanged: (value) => setState(() => _university3 = value),
                label: 'Select your 3rd choice university',
              ),
            ],
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