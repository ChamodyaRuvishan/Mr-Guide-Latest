import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user.dart';

class RegisterScreen extends StatefulWidget {
  final Function(User) onLogin;

  const RegisterScreen({super.key, required this.onLogin});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _mobileController = TextEditingController();

  // Authentic user fields
  final _titleController = TextEditingController();
  final _educationController = TextEditingController();
  final _jobTitleController = TextEditingController();
  final _ageController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _businessTypeController = TextEditingController();
  final _businessDescController = TextEditingController();

  String _error = '';
  bool _loading = false;
  String _role = 'user';
  bool _hasBusiness = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  // Country selection
  final List<Map<String, String>> _countries = [
    {'value': 'US', 'label': 'United States', 'code': '+1', 'flag': 'US'},
    {'value': 'LK', 'label': 'Sri Lanka', 'code': '+94', 'flag': 'LK'},
    {'value': 'IN', 'label': 'India', 'code': '+91', 'flag': 'IN'},
    {'value': 'GB', 'label': 'United Kingdom', 'code': '+44', 'flag': 'GB'},
    {'value': 'AU', 'label': 'Australia', 'code': '+61', 'flag': 'AU'},
    {'value': 'CA', 'label': 'Canada', 'code': '+1', 'flag': 'CA'},
    {'value': 'DE', 'label': 'Germany', 'code': '+49', 'flag': 'DE'},
    {'value': 'FR', 'label': 'France', 'code': '+33', 'flag': 'FR'},
    {'value': 'JP', 'label': 'Japan', 'code': '+81', 'flag': 'JP'},
    {'value': 'CN', 'label': 'China', 'code': '+86', 'flag': 'CN'},
    {'value': 'BR', 'label': 'Brazil', 'code': '+55', 'flag': 'BR'},
    {'value': 'AE', 'label': 'UAE', 'code': '+971', 'flag': 'AE'},
    {'value': 'SG', 'label': 'Singapore', 'code': '+65', 'flag': 'SG'},
    {'value': 'MY', 'label': 'Malaysia', 'code': '+60', 'flag': 'MY'},
    {'value': 'TH', 'label': 'Thailand', 'code': '+66', 'flag': 'TH'},
  ];
  int _selectedCountryIndex = 1; // Sri Lanka default

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _error = 'Passwords do not match');
      return;
    }

    setState(() {
      _loading = true;
      _error = '';
    });

    final country = _countries[_selectedCountryIndex];
    final formData = <String, dynamic>{
      'username': _usernameController.text.trim(),
      'email': _emailController.text.trim(),
      'password': _passwordController.text,
      'confirmPassword': _confirmPasswordController.text,
      'mobileNumber': _mobileController.text.trim(),
      'countryCode': country['code'],
      'country': country['label'],
      'role': _role,
    };

    if (_role == 'authentic_user') {
      formData['title'] = _titleController.text.trim();
      formData['education'] = _educationController.text.trim();
      formData['jobTitle'] = _jobTitleController.text.trim();
      formData['age'] = _ageController.text.trim();
      formData['description'] = _descriptionController.text.trim();
      formData['hasBusiness'] = _hasBusiness;
      if (_hasBusiness) {
        formData['businessName'] = _businessNameController.text.trim();
        formData['businessType'] = _businessTypeController.text.trim();
        formData['businessDescription'] =
            _businessDescController.text.trim();
      }
    }

    final result = await AuthService.register(formData);

    setState(() => _loading = false);

    if (result['success']) {
      widget.onLogin(result['user'] as User);
      if (mounted) Navigator.pop(context);
    } else {
      setState(() => _error = result['error']);
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _mobileController.dispose();
    _titleController.dispose();
    _educationController.dispose();
    _jobTitleController.dispose();
    _ageController.dispose();
    _descriptionController.dispose();
    _businessNameController.dispose();
    _businessTypeController.dispose();
    _businessDescController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final country = _countries[_selectedCountryIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Create Account',
            style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Join the community of travelers and explorers',
                style: TextStyle(color: Colors.white60, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              if (_error.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border.all(color: Colors.red.withValues(alpha: 0.3)),
                  ),
                  child: Text(_error,
                      style: const TextStyle(color: Colors.redAccent)),
                ),

              // Basic Information Section
              _sectionTitle('Basic Information'),
              const SizedBox(height: 12),

              _buildLabel('Username *'),
              const SizedBox(height: 6),
              _buildTextField(_usernameController, 'Choose a unique username',
                  validator: (v) => v != null && v.length < 3
                      ? 'Min 3 characters'
                      : null),
              const SizedBox(height: 16),

              _buildLabel('Email Address *'),
              const SizedBox(height: 6),
              _buildTextField(_emailController, 'your.email@example.com',
                  keyboard: TextInputType.emailAddress,
                  validator: (v) =>
                      v == null || !v.contains('@') ? 'Invalid email' : null),
              const SizedBox(height: 16),

              // Country Selector
              _buildLabel('Country *'),
              const SizedBox(height: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color:
                          const Color(0xFFFFD700).withValues(alpha: 0.3)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _selectedCountryIndex,
                    isExpanded: true,
                    dropdownColor: const Color(0xFF1A2942),
                    style: const TextStyle(color: Colors.white),
                    items: _countries.asMap().entries.map((entry) {
                      return DropdownMenuItem<int>(
                        value: entry.key,
                        child: Text(
                            '${entry.value['label']} (${entry.value['code']})'),
                      );
                    }).toList(),
                    onChanged: (v) =>
                        setState(() => _selectedCountryIndex = v!),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Mobile Number
              _buildLabel('Mobile Number *'),
              const SizedBox(height: 6),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: const Color(0xFFFFD700)
                              .withValues(alpha: 0.3)),
                    ),
                    child: Text(country['code']!,
                        style: const TextStyle(
                            color: Color(0xFFFFD700),
                            fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildTextField(
                        _mobileController, 'Enter your mobile number',
                        keyboard: TextInputType.phone,
                        validator: (v) => v == null || v.isEmpty
                            ? 'Enter mobile number'
                            : null),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Password
              _buildLabel('Password *'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Minimum 6 characters').copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.white38),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                validator: (v) =>
                    v != null && v.length < 6 ? 'Min 6 characters' : null,
              ),
              const SizedBox(height: 16),

              _buildLabel('Confirm Password *'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirm,
                style: const TextStyle(color: Colors.white),
                decoration:
                    _inputDecoration('Re-enter your password').copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                        _obscureConfirm
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.white38),
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
                validator: (v) => v != _passwordController.text
                    ? 'Passwords do not match'
                    : null,
              ),
              const SizedBox(height: 24),

              // Account Type
              _sectionTitle('Account Type'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _roleCard(
                      'user',
                      Icons.person_outline,
                      'Regular User',
                      'Explore places, add reviews',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _roleCard(
                      'authentic_user',
                      Icons.verified_outlined,
                      'Authentic User',
                      'Share expert knowledge',
                    ),
                  ),
                ],
              ),

              // Authentic User Fields
              if (_role == 'authentic_user') ...[
                const SizedBox(height: 24),
                _sectionTitle('Authentic User Profile'),
                const SizedBox(height: 12),

                _buildLabel('Title/Position'),
                const SizedBox(height: 6),
                _buildTextField(
                    _titleController, 'e.g., Dr., Prof., Manager'),
                const SizedBox(height: 16),

                _buildLabel('Educational Qualifications'),
                const SizedBox(height: 6),
                _buildTextField(
                    _educationController, 'Your educational background...',
                    maxLines: 3),
                const SizedBox(height: 16),

                _buildLabel('Job Title'),
                const SizedBox(height: 6),
                _buildTextField(
                    _jobTitleController, 'Your current position'),
                const SizedBox(height: 16),

                _buildLabel('Age'),
                const SizedBox(height: 6),
                _buildTextField(_ageController, 'Your age',
                    keyboard: TextInputType.number),
                const SizedBox(height: 16),

                _buildLabel('About You'),
                const SizedBox(height: 6),
                _buildTextField(
                    _descriptionController, 'Brief description about yourself...',
                    maxLines: 4),
                const SizedBox(height: 16),

                // Business checkbox
                Row(
                  children: [
                    Checkbox(
                      value: _hasBusiness,
                      onChanged: (v) =>
                          setState(() => _hasBusiness = v ?? false),
                      activeColor: const Color(0xFFFFD700),
                      checkColor: Colors.black,
                    ),
                    const Text('I have business information to share',
                        style: TextStyle(color: Colors.white70)),
                  ],
                ),

                if (_hasBusiness) ...[
                  const SizedBox(height: 16),
                  _buildLabel('Business Name *'),
                  const SizedBox(height: 6),
                  _buildTextField(
                      _businessNameController, 'Your business name'),
                  const SizedBox(height: 16),

                  _buildLabel('Business Type *'),
                  const SizedBox(height: 6),
                  _buildTextField(_businessTypeController,
                      'e.g., Hotel, Restaurant, Tour Agency'),
                  const SizedBox(height: 16),

                  _buildLabel('Business Description *'),
                  const SizedBox(height: 6),
                  _buildTextField(_businessDescController,
                      'Describe your business and services...',
                      maxLines: 4),
                ],
              ],

              const SizedBox(height: 30),

              // Submit Button
              ElevatedButton(
                onPressed: _loading ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.black))
                    : const Text('Create Account',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have an account? ',
                      style: TextStyle(color: Colors.white60)),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/login');
                    },
                    child: const Text('Sign In',
                        style: TextStyle(
                            color: Color(0xFFFFD700),
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(text,
        style: const TextStyle(
            color: Color(0xFFFFD700),
            fontSize: 18,
            fontWeight: FontWeight.bold));
  }

  Widget _buildLabel(String text) {
    return Text(text,
        style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w500));
  }

  Widget _buildTextField(TextEditingController controller, String hint,
      {TextInputType keyboard = TextInputType.text,
      int maxLines = 1,
      String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: _inputDecoration(hint),
      validator: validator,
    );
  }

  Widget _roleCard(String role, IconData icon, String title, String desc) {
    final isActive = _role == role;
    return GestureDetector(
      onTap: () => setState(() => _role = role),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFFFFD700).withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive
                ? const Color(0xFFFFD700)
                : Colors.white.withValues(alpha: 0.1),
            width: isActive ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon,
                color: isActive ? const Color(0xFFFFD700) : Colors.white54,
                size: 32),
            const SizedBox(height: 8),
            Text(title,
                style: TextStyle(
                    color: isActive ? const Color(0xFFFFD700) : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13),
                textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text(desc,
                style: const TextStyle(color: Colors.white54, fontSize: 11),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white30),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.05),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            BorderSide(color: const Color(0xFFFFD700).withValues(alpha: 0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            BorderSide(color: const Color(0xFFFFD700).withValues(alpha: 0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFFFD700)),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
