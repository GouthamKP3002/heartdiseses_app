import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  // Common fields
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();

  // Doctor specific fields
  final _specialityController = TextEditingController();
  final _licenseController = TextEditingController();
  final _experienceController = TextEditingController();

  // Patient specific fields
  final _dobController = TextEditingController();
  final _addressController = TextEditingController();
  String? _gender;
  String? _bloodGroup;

  bool _isLoading = false;
  String? _role;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _specialityController.dispose();
    _licenseController.dispose();
    _experienceController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    Map<String, dynamic> profileData = {
      'firstName': _firstNameController.text.trim(),
      'lastName': _lastNameController.text.trim(),
      'phone': _phoneController.text.trim(),
    };

    if (_role == 'doctor') {
      profileData.addAll({
        'speciality': _specialityController.text.trim(),
        'licenseNumber': _licenseController.text.trim(),
        'yearsOfExperience': int.tryParse(_experienceController.text.trim()) ?? 0,
      });
    } else {
      profileData.addAll({
        'dateOfBirth': _dobController.text.trim(),
        'gender': _gender,
        'bloodGroup': _bloodGroup,
        'address': _addressController.text.trim(),
      });
    }

    final success = await _authService.updateProfile(
      uid: _authService.currentUser!.uid,
      profileData: profileData,
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (success) {
      if (_role == 'doctor') {
        Navigator.pushReplacementNamed(context, '/doctor-dashboard');
      } else {
        Navigator.pushReplacementNamed(context, '/patient-dashboard');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save profile. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobController.text =
            '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    _role = args?['role'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  _role == 'doctor'
                      ? Icons.medical_services
                      : Icons.person,
                  size: 60,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Setup Your Profile',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 32),
                // Common Fields
                TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(
                    labelText: 'First Name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your first name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(
                    labelText: 'Last Name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your last name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    if (value.length < 10) {
                      return 'Please enter a valid phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Role-specific fields
                if (_role == 'doctor') ..._buildDoctorFields(),
                if (_role == 'patient') ..._buildPatientFields(),
                const SizedBox(height: 32),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Complete Setup',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildDoctorFields() {
    return [
      TextFormField(
        controller: _specialityController,
        decoration: const InputDecoration(
          labelText: 'Speciality',
          prefixIcon: Icon(Icons.medical_information_outlined),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your speciality';
          }
          return null;
        },
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _licenseController,
        decoration: const InputDecoration(
          labelText: 'Medical License Number',
          prefixIcon: Icon(Icons.badge_outlined),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your license number';
          }
          return null;
        },
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _experienceController,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'Years of Experience',
          prefixIcon: Icon(Icons.work_outline),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter years of experience';
          }
          if (int.tryParse(value) == null) {
            return 'Please enter a valid number';
          }
          return null;
        },
      ),
    ];
  }

  List<Widget> _buildPatientFields() {
    return [
      TextFormField(
        controller: _dobController,
        readOnly: true,
        onTap: _selectDate,
        decoration: const InputDecoration(
          labelText: 'Date of Birth',
          prefixIcon: Icon(Icons.calendar_today_outlined),
          suffixIcon: Icon(Icons.arrow_drop_down),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select your date of birth';
          }
          return null;
        },
      ),
      const SizedBox(height: 16),
      DropdownButtonFormField<String>(
        value: _gender,
        decoration: const InputDecoration(
          labelText: 'Gender',
          prefixIcon: Icon(Icons.person_outline),
        ),
        items: ['Male', 'Female', 'Other']
            .map((gender) => DropdownMenuItem(
                  value: gender,
                  child: Text(gender),
                ))
            .toList(),
        onChanged: (value) {
          setState(() => _gender = value);
        },
        validator: (value) {
          if (value == null) {
            return 'Please select your gender';
          }
          return null;
        },
      ),
      const SizedBox(height: 16),
      DropdownButtonFormField<String>(
        value: _bloodGroup,
        decoration: const InputDecoration(
          labelText: 'Blood Group',
          prefixIcon: Icon(Icons.bloodtype_outlined),
        ),
        items: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
            .map((blood) => DropdownMenuItem(
                  value: blood,
                  child: Text(blood),
                ))
            .toList(),
        onChanged: (value) {
          setState(() => _bloodGroup = value);
        },
        validator: (value) {
          if (value == null) {
            return 'Please select your blood group';
          }
          return null;
        },
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _addressController,
        maxLines: 3,
        decoration: const InputDecoration(
          labelText: 'Address',
          prefixIcon: Icon(Icons.home_outlined),
          alignLabelWithHint: true,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your address';
          }
          return null;
        },
      ),
    ];
  }
}