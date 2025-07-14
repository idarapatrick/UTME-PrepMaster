import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import '../services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _firstName;
  String? _lastName;
  String? _email;
  String? _phone;
  String? _gender;
  DateTime? _birthday;
  String? _university1;
  String? _university2;
  String? _university3;
  // TODO: Replace with actual avatar logic
  String _avatarUrl = '';
  String? _avatarDownloadUrl;
  bool _saving = false;

  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _nigerianInstitutions = [
    // TODO: Replace with full list
    'University of Lagos',
    'Obafemi Awolowo University',
    'Ahmadu Bello University',
    'University of Ibadan',
    'Covenant University',
    'Yaba College of Technology',
    'Federal Polytechnic Bida',
    'Nigerian Army University',
    'Federal College of Education Zaria',
    'Lagos State Polytechnic',
    'Babcock University',
    'Nile University',
    'Auchi Polytechnic',
    'Federal University of Technology Akure',
    'Nnamdi Azikiwe University',
    'Federal University of Agriculture Abeokuta',
    'Kaduna Polytechnic',
    'National Open University of Nigeria',
    'Others...',
  ];

  Future<void> _pickBirthday() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthday ?? DateTime(now.year - 16),
      firstDate: DateTime(1970),
      lastDate: DateTime(now.year - 10),
    );
    if (picked != null) {
      setState(() => _birthday = picked);
    }
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final url = await FirestoreService.uploadFile(
          user.uid,
          'avatar',
          'avatar.jpg',
          bytes,
        );
        setState(() {
          _avatarDownloadUrl = url;
          _avatarUrl = url;
        });
      }
    }
  }

  void _saveProfile() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    _formKey.currentState?.save();
    setState(() => _saving = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirestoreService.saveFullUserProfile(user.uid, {
        'firstName': _firstName,
        'lastName': _lastName,
        'email': _email,
        'phone': _phone,
        'gender': _gender,
        'birthday': _birthday?.toIso8601String(),
        'university1': _university1,
        'university2': _university2,
        'university3': _university3,
        'avatarUrl': _avatarDownloadUrl ?? _avatarUrl,
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile updated!')));
    }
    setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: AppColors.dominantPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: isDark
          ? const Color(0xFF181A20)
          : AppColors.backgroundPrimary,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: AppColors.dominantPurple.withOpacity(
                        0.1,
                      ),
                      backgroundImage: _avatarUrl.isNotEmpty
                          ? NetworkImage(_avatarUrl)
                          : null,
                      child: _avatarUrl.isEmpty
                          ? const Icon(
                              Icons.person,
                              size: 44,
                              color: AppColors.dominantPurple,
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickAvatar,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.accentAmber,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(6),
                          child: const Icon(
                            Icons.upload,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'First Name',
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Required' : null,
                      onSaved: (v) => _firstName = v,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(labelText: 'Last Name'),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Required' : null,
                      onSaved: (v) => _lastName = v,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                onSaved: (v) => _email = v,
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                onSaved: (v) => _phone = v,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Gender'),
                value: _gender,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                items: _genders
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (v) => setState(() => _gender = v),
                onSaved: (v) => _gender = v,
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _pickBirthday,
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: const InputDecoration(labelText: 'Birthday'),
                    controller: TextEditingController(
                      text: _birthday != null
                          ? '${_birthday!.year}-${_birthday!.month.toString().padLeft(2, '0')}-${_birthday!.day.toString().padLeft(2, '0')}'
                          : '',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Intended University Choices
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: '1st Choice University',
                ),
                value: _university1,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                items: FirestoreService.nigerianInstitutions()
                    .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                    .toList(),
                onChanged: (v) => setState(() => _university1 = v),
                onSaved: (v) => _university1 = v,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: '2nd Choice University',
                ),
                value: _university2,
                items: FirestoreService.nigerianInstitutions()
                    .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                    .toList(),
                onChanged: (v) => setState(() => _university2 = v),
                onSaved: (v) => _university2 = v,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: '3rd Choice University',
                ),
                value: _university3,
                items: FirestoreService.nigerianInstitutions()
                    .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                    .toList(),
                onChanged: (v) => setState(() => _university3 = v),
                onSaved: (v) => _university3 = v,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.dominantPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _saving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Save Changes',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
