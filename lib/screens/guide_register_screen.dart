import 'package:flutter/material.dart';
import '../services/guide_service.dart';
import '../services/auth_service.dart';
import '../models/user.dart';

class GuideRegisterScreen extends StatefulWidget {
  final User? user;

  const GuideRegisterScreen({super.key, this.user});

  @override
  State<GuideRegisterScreen> createState() => _GuideRegisterScreenState();
}

class _GuideRegisterScreenState extends State<GuideRegisterScreen> {
  int _currentStep = 0;
  bool _isLoading = false;
  String _errorMessage = '';
  bool _isSuccess = false;

  final List<String> _steps = ['Personal', 'Pricing', 'Bank & Card', 'Media'];

  final List<String> _languageOptions = [
    'Sinhala',
    'Tamil',
    'English',
    'Japanese',
    'Chinese',
    'German',
    'French',
    'Spanish',
    'Italian',
  ];

  final List<String> _regionOptions = [
    'Colombo',
    'Kandy',
    'Galle',
    'Ella',
    'Sigiriya',
    'Jaffna',
    'Trincomalee',
    'Anuradhapura',
    'Nuwara Eliya',
    'Negombo',
    'Mirissa',
    'Polonnaruwa',
  ];

  // Controllers - Step 1: Personal
  late final TextEditingController _displayNameController;
  final _phoneController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _nicController = TextEditingController();
  final _bioController = TextEditingController();
  final List<String> _selectedLanguages = [];
  final List<String> _selectedRegions = [];

  // Controllers - Step 2: Pricing
  final _tier1kmController = TextEditingController();
  final _tier5kmController = TextEditingController();
  final _tier10kmController = TextEditingController();
  final _tier20kmController = TextEditingController();
  final _tierPerKmOver20Controller = TextEditingController();

  // Waiting rate controllers
  final Map<String, TextEditingController> _waitRateControllers = {
    'wait_rate_10m': TextEditingController(),
    'wait_rate_20m': TextEditingController(),
    'wait_rate_30m': TextEditingController(),
    'wait_rate_40m': TextEditingController(),
    'wait_rate_1h': TextEditingController(),
    'wait_rate_2h': TextEditingController(),
    'wait_rate_3h': TextEditingController(),
    'wait_rate_5h': TextEditingController(),
    'wait_rate_per_hour': TextEditingController(),
    'wait_rate_per_30m': TextEditingController(),
    'wait_rate_per_15m': TextEditingController(),
  };

  final List<Map<String, String>> _waitRateFields = [
    {'key': 'wait_rate_10m', 'label': '10 Minutes', 'duration': '10 min'},
    {'key': 'wait_rate_20m', 'label': '20 Minutes', 'duration': '20 min'},
    {'key': 'wait_rate_30m', 'label': '30 Minutes', 'duration': '30 min'},
    {'key': 'wait_rate_40m', 'label': '40 Minutes', 'duration': '40 min'},
    {'key': 'wait_rate_1h', 'label': '1 Hour', 'duration': '60 min'},
    {'key': 'wait_rate_2h', 'label': '2 Hours', 'duration': '120 min'},
    {'key': 'wait_rate_3h', 'label': '3 Hours', 'duration': '180 min'},
    {'key': 'wait_rate_5h', 'label': '5 Hours', 'duration': '300 min'},
    {'key': 'wait_rate_per_hour', 'label': 'Per extra hour', 'duration': '60 min'},
    {'key': 'wait_rate_per_30m', 'label': 'Per extra 30m', 'duration': '30 min'},
    {'key': 'wait_rate_per_15m', 'label': 'Per extra 15m', 'duration': '15 min'},
  ];

  // Controllers - Step 3: Bank & Card
  final _bankNameController = TextEditingController();
  final _bankAccountController = TextEditingController();
  final _bankBranchController = TextEditingController();
  final _paymentRefController = TextEditingController();
  final _cardLast4Controller = TextEditingController();
  final _cardExpiryController = TextEditingController();

  // Controllers - Step 4: Media
  final _aboutToursController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _displayNameController =
        TextEditingController(text: widget.user?.username ?? '');
    _loadUserIfNull();
  }

  Future<void> _loadUserIfNull() async {
    if (widget.user == null) {
      final u = await AuthService.getCurrentUser();
      if (u != null && mounted) {
        if (_displayNameController.text.isEmpty) {
          setState(() {
            _displayNameController.text = u.username;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();
    _nicController.dispose();
    _bioController.dispose();
    _tier1kmController.dispose();
    _tier5kmController.dispose();
    _tier10kmController.dispose();
    _tier20kmController.dispose();
    _tierPerKmOver20Controller.dispose();
    for (var c in _waitRateControllers.values) {
      c.dispose();
    }
    _bankNameController.dispose();
    _bankAccountController.dispose();
    _bankBranchController.dispose();
    _paymentRefController.dispose();
    _cardLast4Controller.dispose();
    _cardExpiryController.dispose();
    _aboutToursController.dispose();
    super.dispose();
  }

  double _calcFare(double km) {
    final t1 = double.tryParse(_tier1kmController.text.trim()) ?? 0;
    final t5 = double.tryParse(_tier5kmController.text.trim()) ?? 0;
    final t10 = double.tryParse(_tier10kmController.text.trim()) ?? 0;
    final t20 = double.tryParse(_tier20kmController.text.trim()) ?? 0;
    final tExtra = double.tryParse(_tierPerKmOver20Controller.text.trim()) ?? 0;

    if (km <= 1) return t1;
    if (km <= 5) return t5;
    if (km <= 10) return t10;
    if (km <= 20) return t20;
    return t20 + (km - 20) * tExtra;
  }

  String? _validateStep() {
    if (_currentStep == 0) {
      if (_displayNameController.text.trim().isEmpty) {
        return 'Display name is required';
      }
      if (_phoneController.text.trim().isEmpty) {
        return 'Phone number is required';
      }
      if (_nicController.text.trim().isEmpty) {
        return 'NIC number is required for verification';
      }
    } else if (_currentStep == 1) {
      if (_tier1kmController.text.trim().isEmpty ||
          _tier5kmController.text.trim().isEmpty ||
          _tier10kmController.text.trim().isEmpty ||
          _tier20kmController.text.trim().isEmpty ||
          _tierPerKmOver20Controller.text.trim().isEmpty) {
        return 'All 5 distance pricing tiers are required';
      }
    } else if (_currentStep == 2) {
      if (_bankNameController.text.trim().isEmpty ||
          _bankAccountController.text.trim().isEmpty) {
        return 'Bank name and account number are required for payouts';
      }
    }
    return null;
  }

  void _nextStep() {
    final err = _validateStep();
    if (err != null) {
      setState(() => _errorMessage = err);
      return;
    }
    setState(() {
      _errorMessage = '';
      if (_currentStep < _steps.length - 1) {
        _currentStep++;
      }
    });
  }

  void _prevStep() {
    setState(() {
      _errorMessage = '';
      if (_currentStep > 0) {
        _currentStep--;
      }
    });
  }

  Future<void> _submitRegistration() async {
    final err = _validateStep();
    if (err != null) {
      setState(() => _errorMessage = err);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final data = <String, dynamic>{
      'display_name': _displayNameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'whatsapp': _whatsappController.text.trim(),
      'nic_number': _nicController.text.trim(),
      'bio': _bioController.text.trim(),
      'languages': _selectedLanguages,
      'speciality_regions': _selectedRegions,
      'tier_1km': double.tryParse(_tier1kmController.text.trim()) ?? 0,
      'tier_5km': double.tryParse(_tier5kmController.text.trim()) ?? 0,
      'tier_10km': double.tryParse(_tier10kmController.text.trim()) ?? 0,
      'tier_20km': double.tryParse(_tier20kmController.text.trim()) ?? 0,
      'tier_per_km_over20':
          double.tryParse(_tierPerKmOver20Controller.text.trim()) ?? 0,
      'bank_name': _bankNameController.text.trim(),
      'bank_account_number': _bankAccountController.text.trim(),
      'bank_branch': _bankBranchController.text.trim(),
      'payment_ref': _paymentRefController.text.trim(),
      'card_last4': _cardLast4Controller.text.trim(),
      'card_expiry': _cardExpiryController.text.trim(),
      'about_tours': _aboutToursController.text.trim(),
    };

    // Add optional waiting rates
    for (var entry in _waitRateControllers.entries) {
      final val = entry.value.text.trim();
      if (val.isNotEmpty) {
        data[entry.key] = double.tryParse(val) ?? 0;
      }
    }

    final result = await GuideService.registerGuide(data);

    if (mounted) {
      setState(() => _isLoading = false);
      if (result['success'] == true) {
        setState(() => _isSuccess = true);
      } else {
        setState(() {
          _errorMessage = result['error'] ?? 'Registration failed. Please try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: const Text(
          'Register as a Guide',
          style: TextStyle(
            color: Color(0xFFFFD700),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF1B2838),
        elevation: 0,
      ),
      body: _isSuccess ? _buildSuccessView() : _buildFormView(),
    );
  }

  Widget _buildSuccessView() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700).withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFFFD700), width: 2),
              ),
              child: const Icon(
                Icons.check_circle_outline_rounded,
                color: Color(0xFFFFD700),
                size: 54,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Registration Submitted!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Your guide profile has been submitted for admin review. You will be notified once approved (usually within 24 hours).',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 15,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 36),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.home_rounded),
              label: const Text(
                'Back to Home',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                foregroundColor: Colors.black,
                minimumSize: const Size(200, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormView() {
    return Column(
      children: [
        // Progress Steps Indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          color: const Color(0xFF1B2838),
          child: Row(
            children: List.generate(_steps.length, (index) {
              final isActive = index == _currentStep;
              final isDone = index < _currentStep;
              return Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDone
                                  ? const Color(0xFFFFD700)
                                  : isActive
                                      ? const Color(0xFFFFD700).withValues(alpha: 0.2)
                                      : Colors.white.withValues(alpha: 0.1),
                              border: Border.all(
                                color: isActive || isDone
                                    ? const Color(0xFFFFD700)
                                    : Colors.white24,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: isDone
                                  ? const Icon(Icons.check,
                                      size: 18, color: Colors.black)
                                  : Text(
                                      '${index + 1}',
                                      style: TextStyle(
                                        color: isActive
                                            ? const Color(0xFFFFD700)
                                            : Colors.white60,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _steps[index],
                            style: TextStyle(
                              color: isActive
                                  ? const Color(0xFFFFD700)
                                  : isDone
                                      ? Colors.white
                                      : Colors.white38,
                              fontSize: 11,
                              fontWeight: isActive
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (index < _steps.length - 1)
                      Container(
                        width: 20,
                        height: 2,
                        color: isDone
                            ? const Color(0xFFFFD700)
                            : Colors.white24,
                        margin: const EdgeInsets.only(bottom: 16),
                      ),
                  ],
                ),
              );
            }),
          ),
        ),

        // Error message banner
        if (_errorMessage.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.redAccent.withValues(alpha: 0.2),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.redAccent, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.redAccent, size: 16),
                  onPressed: () => setState(() => _errorMessage = ''),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

        // Step Content Body
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_currentStep == 0) _buildStep1Personal(),
                if (_currentStep == 1) _buildStep2Pricing(),
                if (_currentStep == 2) _buildStep3Bank(),
                if (_currentStep == 3) _buildStep4Media(),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),

        // Bottom Navigation Buttons
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Color(0xFF1B2838),
            border: Border(top: BorderSide(color: Colors.white12)),
          ),
          child: Row(
            children: [
              if (_currentStep > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : _prevStep,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white38),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Back'),
                  ),
                ),
              if (_currentStep > 0) const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : (_currentStep == _steps.length - 1
                          ? _submitRegistration
                          : _nextStep),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
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
                            color: Colors.black,
                          ),
                        )
                      : Text(
                          _currentStep == _steps.length - 1
                              ? 'Submit Registration'
                              : 'Next Step →',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────
  // STEP 1: PERSONAL DETAILS
  // ──────────────────────────────────────────────
  Widget _buildStep1Personal() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Personal Details',
          'Provide your real identity so tourists can know who you are.',
        ),
        const SizedBox(height: 18),
        _buildTextField(
          label: 'Display Name *',
          hint: 'e.g. Ruwan Perera',
          controller: _displayNameController,
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 14),
        _buildTextField(
          label: 'Phone Number *',
          hint: '+94 7X XXX XXXX',
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          icon: Icons.phone_outlined,
        ),
        const SizedBox(height: 14),
        _buildTextField(
          label: 'WhatsApp Number',
          hint: '+94 7X XXX XXXX',
          controller: _whatsappController,
          keyboardType: TextInputType.phone,
          icon: Icons.chat_outlined,
        ),
        const SizedBox(height: 14),
        _buildTextField(
          label: 'NIC Number *',
          hint: 'e.g. 199012345678 or 901234567V',
          controller: _nicController,
          helperText: 'Admin verification only, not shown publicly',
          icon: Icons.badge_outlined,
        ),
        const SizedBox(height: 14),
        _buildTextField(
          label: 'Short Bio',
          hint: 'Tell tourists about yourself, your passion, and background...',
          controller: _bioController,
          maxLines: 4,
          maxLength: 500,
          icon: Icons.description_outlined,
        ),
        const SizedBox(height: 14),
        const Text(
          'Languages Spoken',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _languageOptions.map((lang) {
            final isSelected = _selectedLanguages.contains(lang);
            return FilterChip(
              label: Text(lang),
              selected: isSelected,
              selectedColor: const Color(0xFFFFD700),
              checkmarkColor: Colors.black,
              labelStyle: TextStyle(
                color: isSelected ? Colors.black : Colors.white70,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              backgroundColor: const Color(0xFF1B2838),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? const Color(0xFFFFD700) : Colors.white24,
                ),
              ),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedLanguages.add(lang);
                  } else {
                    _selectedLanguages.remove(lang);
                  }
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        const Text(
          'Speciality Regions',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _regionOptions.map((region) {
            final isSelected = _selectedRegions.contains(region);
            return FilterChip(
              label: Text(region),
              selected: isSelected,
              selectedColor: const Color(0xFFFFD700),
              checkmarkColor: Colors.black,
              labelStyle: TextStyle(
                color: isSelected ? Colors.black : Colors.white70,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              backgroundColor: const Color(0xFF1B2838),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? const Color(0xFFFFD700) : Colors.white24,
                ),
              ),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedRegions.add(region);
                  } else {
                    _selectedRegions.remove(region);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────
  // STEP 2: PRICING & TIERS
  // ──────────────────────────────────────────────
  Widget _buildStep2Pricing() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Distance Pricing',
          'Set your distance rates in LKR. Tourists will see these before booking.',
        ),
        const SizedBox(height: 18),
        _buildPriceRow(
          label: 'Up to 1 km (flat rate) *',
          hint: 'e.g. 250',
          controller: _tier1kmController,
        ),
        const SizedBox(height: 12),
        _buildPriceRow(
          label: 'Up to 5 km (flat rate) *',
          hint: 'e.g. 700',
          controller: _tier5kmController,
        ),
        const SizedBox(height: 12),
        _buildPriceRow(
          label: 'Up to 10 km (flat rate) *',
          hint: 'e.g. 1300',
          controller: _tier10kmController,
        ),
        const SizedBox(height: 12),
        _buildPriceRow(
          label: 'Up to 20 km (flat rate) *',
          hint: 'e.g. 2000',
          controller: _tier20kmController,
        ),
        const SizedBox(height: 12),
        _buildPriceRow(
          label: 'Over 20 km (per extra km) *',
          hint: 'e.g. 100',
          controller: _tierPerKmOver20Controller,
          suffix: 'LKR / km',
        ),
        const SizedBox(height: 24),

        // Live Fare Preview Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1B2838),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFFFD700).withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.visibility_outlined,
                      color: Color(0xFFFFD700), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Live Preview (Calculated Fare)',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildFarePreviewItem('1 km', _calcFare(1)),
                  _buildFarePreviewItem('5 km', _calcFare(5)),
                  _buildFarePreviewItem('10 km', _calcFare(10)),
                  _buildFarePreviewItem('25 km', _calcFare(25)),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Example: 28 km trip = LKR ${_calcFare(28).toStringAsFixed(0)} (tier_20km + 8 × per_km)',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ),

        const SizedBox(height: 28),
        const Text(
          'Waiting / Stop Charges',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Optional rates for stops during tours. Enter 0 or leave empty for free waiting.',
          style: TextStyle(color: Colors.white60, fontSize: 13),
        ),
        const SizedBox(height: 14),

        ..._waitRateFields.map((field) {
          final ctrl = _waitRateControllers[field['key']!];
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _buildPriceRow(
              label: '${field['label']!} (${field['duration']!})',
              hint: '0',
              controller: ctrl!,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildFarePreviewItem(String label, double fare) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        const SizedBox(height: 4),
        Text(
          fare > 0 ? 'LKR ${fare.toStringAsFixed(0)}' : '—',
          style: const TextStyle(
            color: Color(0xFFFFD700),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────
  // STEP 3: BANK & PAYMENT DETAILS
  // ──────────────────────────────────────────────
  Widget _buildStep3Bank() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Bank & Payment Details',
          'Where you will receive your weekly tour payouts.',
        ),
        const SizedBox(height: 14),

        // Commission Notice Box
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFD700).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFFFD700).withValues(alpha: 0.4),
            ),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, color: Color(0xFFFFD700), size: 22),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Commission Notice: Mr. Guide charges 5% of every trip fare as platform commission. This is automatically deducted from weekly payouts.',
                  style: TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        _buildTextField(
          label: 'Bank Name *',
          hint: 'e.g. Commercial Bank of Ceylon / Bank of Ceylon',
          controller: _bankNameController,
          icon: Icons.account_balance_outlined,
        ),
        const SizedBox(height: 14),
        _buildTextField(
          label: 'Account Number *',
          hint: 'Enter your bank account number',
          controller: _bankAccountController,
          keyboardType: TextInputType.number,
          icon: Icons.pin_outlined,
        ),
        const SizedBox(height: 14),
        _buildTextField(
          label: 'Branch',
          hint: 'e.g. Colombo Fort / Kandy City',
          controller: _bankBranchController,
          icon: Icons.location_city_outlined,
        ),
        const SizedBox(height: 14),
        _buildTextField(
          label: 'Payment Reference',
          hint: 'e.g. your name or mobile payment reference',
          controller: _paymentRefController,
          helperText: 'Shown to tourists for cash trips',
          icon: Icons.receipt_long_outlined,
        ),
        const SizedBox(height: 24),

        const Text(
          'Card Details (Test Mode)',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white12),
          ),
          child: const Row(
            children: [
              Icon(Icons.science_outlined, color: Colors.cyanAccent, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Test mode: Use test card 4242 4242 4242 4242, any expiry, any CVC.',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                label: 'Card Last 4 Digits',
                hint: '4242',
                controller: _cardLast4Controller,
                keyboardType: TextInputType.number,
                maxLength: 4,
                icon: Icons.credit_card_outlined,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildTextField(
                label: 'Card Expiry (MM/YYYY)',
                hint: '12/2026',
                controller: _cardExpiryController,
                maxLength: 7,
                icon: Icons.calendar_today_outlined,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────
  // STEP 4: MEDIA & STORY
  // ──────────────────────────────────────────────
  Widget _buildStep4Media() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Profile Media & Story',
          'Highlight your local expertise and unique tour experiences.',
        ),
        const SizedBox(height: 18),
        _buildTextField(
          label: 'About My Tours',
          hint:
              'Tell tourists what makes your tours special. Your experience, favorite routes, hidden waterfalls or heritage sites you know...',
          controller: _aboutToursController,
          maxLines: 7,
          icon: Icons.explore_outlined,
        ),
        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1B2838),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white12),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.photo_library_outlined,
                  color: Color(0xFFFFD700), size: 24),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gallery Photos',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'You can upload up to 10 photos of your tours from your Guide Dashboard once your registration is approved.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────
  // REUSABLE FORM COMPONENTS
  // ──────────────────────────────────────────────
  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(color: Colors.white60, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    int? maxLength,
    String? helperText,
    IconData? icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          maxLength: maxLength,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
            prefixIcon: icon != null
                ? Icon(icon, color: const Color(0xFFFFD700), size: 20)
                : null,
            filled: true,
            fillColor: const Color(0xFF1B2838),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Color(0xFFFFD700), width: 1.5),
            ),
            helperText: helperText,
            helperStyle: const TextStyle(color: Colors.white38, fontSize: 11),
            counterStyle: const TextStyle(color: Colors.white38, fontSize: 11),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow({
    required String label,
    required String hint,
    required TextEditingController controller,
    String suffix = 'LKR',
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2838),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              suffix,
              style: const TextStyle(
                color: Color(0xFFFFD700),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: TextField(
              controller: controller,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle:
                    const TextStyle(color: Colors.white24, fontSize: 13),
                isDense: true,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
