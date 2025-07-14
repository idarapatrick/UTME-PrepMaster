import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

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
                        onTap: () {
                          // TODO: Implement avatar upload
                        },
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
                      onSaved: (v) => _firstName = v,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(labelText: 'Last Name'),
                      onSaved: (v) => _lastName = v,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                onSaved: (v) => _email = v,
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
                onSaved: (v) => _phone = v,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Gender'),
                value: _gender,
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
                items: _nigerianInstitutions
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
                items: _nigerianInstitutions
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
                items: _nigerianInstitutions
                    .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                    .toList(),
                onChanged: (v) => setState(() => _university3 = v),
                onSaved: (v) => _university3 = v,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      _formKey.currentState?.save();
                      // TODO: Save profile changes
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.dominantPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
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
