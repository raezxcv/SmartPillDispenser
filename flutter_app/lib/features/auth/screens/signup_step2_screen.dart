import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Signup Step 2 of 3 — "Personal Information"
class SignupStep2Screen extends StatefulWidget {
  final String initialName;
  final VoidCallback onBack;
  final Function(
    String name,
    String phone,
    String? dob,
    String? gender,
    String? address,
  ) onNext;

  const SignupStep2Screen({
    super.key,
    required this.initialName,
    required this.onBack,
    required this.onNext,
  });

  @override
  State<SignupStep2Screen> createState() => _SignupStep2ScreenState();
}

class _SignupStep2ScreenState extends State<SignupStep2Screen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  DateTime? _selectedDob;
  String? _selectedGender;
  bool _dobTouched = false;

  // Gender options with icons
  static const List<({String label, IconData icon})> _genders = [
    (label: 'Male', icon: Icons.male_rounded),
    (label: 'Female', icon: Icons.female_rounded),
    (label: 'Non-binary', icon: Icons.transgender_rounded),
    (label: 'Prefer not to say', icon: Icons.do_not_disturb_on_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.initialName.toUpperCase());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDob ?? DateTime(now.year - 30),
      firstDate: DateTime(1920),
      lastDate: DateTime(now.year - 1),
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF00A36C)),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _selectedDob = picked;
        _dobTouched = true;
      });
    } else {
      setState(() => _dobTouched = true);
    }
  }

  void _submitStep2() {
    setState(() => _dobTouched = true);
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDob == null) return;

    widget.onNext(
      _nameController.text.trim(),
      _phoneController.text.trim(),
      DateFormat('yyyy-MM-dd').format(_selectedDob!),
      _selectedGender,
      _addressController.text.trim().isEmpty
          ? null
          : _addressController.text.trim(),
    );
  }

  // ── Phone validator ──────────────────────────────────────────────────────────
  String? _validatePhone(String? v) {
    if (v == null || v.trim().isEmpty) return 'Phone number is required';
    final digits = v.trim().replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('09') && digits.length == 11) return null;
    if (digits.startsWith('63') && digits.length == 12) return null;
    return 'Enter 11 digits starting with 09 or 12 digits starting with 63';
  }

  @override
  Widget build(BuildContext context) {
    final bool dobError = _dobTouched && _selectedDob == null;

    return Column(
      children: [
        // ── Scrollable Form ────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        const Text(
                          'Personal Information',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1F2937),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Tell us a bit about yourself to set up your profile.',
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // ── FULL NAME ──────────────────────────────────
                        const _FieldLabel(
                          icon: Icons.badge_rounded,
                          label: 'FULL NAME',
                          required: true,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _nameController,
                          textCapitalization: TextCapitalization.characters,
                          inputFormatters: [_UpperCaseFormatter()],
                          decoration:
                              _buildPillInputDecoration('JUAN DELA CRUZ'),
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Full name is required'
                              : null,
                        ),

                        const SizedBox(height: 18),

                        // ── PHONE NUMBER ───────────────────────────────
                        const _FieldLabel(
                          icon: Icons.phone_rounded,
                          label: 'PHONE NUMBER',
                          required: true,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            _DynamicPhoneFormatter(),
                          ],
                          decoration: _buildPillInputDecoration(
                              '09XX-XXX-XXXX'),
                          validator: _validatePhone,
                        ),

                        const SizedBox(height: 18),

                        // ── DATE OF BIRTH ──────────────────────────────
                        const _FieldLabel(
                          icon: Icons.cake_rounded,
                          label: 'DATE OF BIRTH',
                          required: true,
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: _pickDateOfBirth,
                          child: Container(
                            height: 56,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: dobError
                                    ? const Color(0xFFEF4444)
                                    : const Color(0xFFE5E7EB),
                                width: dobError ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  _selectedDob == null
                                      ? 'Select date of birth'
                                      : DateFormat('MMMM d, yyyy')
                                          .format(_selectedDob!),
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: _selectedDob == null
                                        ? const Color(0xFF9CA3AF)
                                        : const Color(0xFF1F2937),
                                  ),
                                ),
                                const Spacer(),
                                Icon(
                                  Icons.calendar_today_rounded,
                                  color: dobError
                                      ? const Color(0xFFEF4444)
                                      : const Color(0xFF6B7280),
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (dobError) ...[
                          const SizedBox(height: 6),
                          const Padding(
                            padding: EdgeInsets.only(left: 16),
                            child: Text(
                              'Date of birth is required',
                              style: TextStyle(
                                color: Color(0xFFEF4444),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 18),

                        // ── GENDER ─────────────────────────────────────
                        const _FieldLabel(
                          icon: Icons.people_alt_rounded,
                          label: 'GENDER',
                          required: true,
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedGender,
                          hint: const Text('Select gender',
                              style: TextStyle(
                                  color: Color(0xFF9CA3AF), fontSize: 15)),
                          decoration: _buildPillInputDecoration(''),
                          items: _genders
                              .map((g) => DropdownMenuItem(
                                    value: g.label,
                                    child: Row(
                                      children: [
                                        Icon(g.icon,
                                            size: 20,
                                            color: const Color(0xFF00A36C)),
                                        const SizedBox(width: 10),
                                        Text(g.label),
                                      ],
                                    ),
                                  ))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _selectedGender = v),
                          validator: (v) =>
                              v == null ? 'Please select a gender' : null,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded,
                              color: Color(0xFF6B7280)),
                          dropdownColor: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),

                        const SizedBox(height: 18),

                        // ── ADDRESS (OPTIONAL) ─────────────────────────
                        const _FieldLabel(
                          icon: Icons.location_on_rounded,
                          label: 'ADDRESS',
                          required: false,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _addressController,
                          maxLines: 2,
                          decoration: _buildPillInputDecoration(
                                  'e.g. 123 Rizal St., Manila')
                              .copyWith(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 16),
                          ),
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Continue Button ────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00C882), Color(0xFF00A36C)],
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color:
                            const Color(0xFF00A36C).withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _submitStep2,
                      borderRadius: BorderRadius.circular(28),
                      child: const Center(
                        child: Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
  }

  InputDecoration _buildPillInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 15),
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: const BorderSide(color: Color(0xFF00A36C), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: const BorderSide(color: Color(0xFFEF4444)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
      ),
    );
  }
}

// ─── Field Label with Icon ────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool required;

  const _FieldLabel({
    required this.icon,
    required this.label,
    required this.required,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: const Color(0xFF00A36C)),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: Color(0xFF6B7280),
            letterSpacing: 0.8,
          ),
        ),
        if (required) ...[
          const SizedBox(width: 3),
          const Text(
            '*',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Color(0xFFEF4444),
            ),
          ),
        ] else ...[
          const SizedBox(width: 3),
          const Text(
            '(OPTIONAL)',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF9CA3AF),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ],
    );
  }
}

// ─── Dynamic Phone Input Formatter ────────────────────────────────────────────

class _DynamicPhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String text = newValue.text;
    if (text.startsWith('09') && text.length > 11) {
      text = text.substring(0, 11);
    } else if (text.startsWith('63') && text.length > 12) {
      text = text.substring(0, 12);
    } else if (!text.startsWith('09') && !text.startsWith('63') && text.length > 12) {
      text = text.substring(0, 12);
    }
    return newValue.copyWith(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

// ─── Uppercase Input Formatter ────────────────────────────────────────────────

class _UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}


