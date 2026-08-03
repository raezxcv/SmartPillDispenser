import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Signup Step 2 of 3 — "Personal Information"
/// Stepper is rendered by the parent fixed header in main.dart.
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
  final void Function(VoidCallback) onRegisterSubmit;

  const SignupStep2Screen({
    super.key,
    required this.initialName,
    required this.onBack,
    required this.onNext,
    required this.onRegisterSubmit,
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

  static const List<({String label, IconData icon})> _genders = [
    (label: 'Male', icon: Icons.male_rounded),
    (label: 'Female', icon: Icons.female_rounded),
    (label: 'Non-binary', icon: Icons.transgender_rounded),
    (label: 'Prefer not to say', icon: Icons.do_not_disturb_on_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    // Register submit handler with the parent's fixed bottom bar
    widget.onRegisterSubmit(_submitStep2);
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

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: EdgeInsets.zero,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 20, 28, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Title & Subtitle
                    const SizedBox(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Personal Information',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1F2937),
                              letterSpacing: -0.5,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Tell us a bit about yourself to set up your profile.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // FULL NAME
                    const _FieldLabel(icon: Icons.person_rounded, label: 'FULL NAME', required: true),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      style: const TextStyle(color: Color(0xFF1F2937), fontSize: 16, fontWeight: FontWeight.w700),
                      decoration: _pillDecoration('e.g. Juan dela Cruz'),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Full name is required';
                        if (v.trim().split(' ').length < 2) return 'Please enter first and last name';
                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    // MOBILE NUMBER
                    const _FieldLabel(icon: Icons.phone_rounded, label: 'MOBILE NUMBER', required: true),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(color: Color(0xFF1F2937), fontSize: 16, fontWeight: FontWeight.w700),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        _DynamicPhoneFormatter(),
                      ],
                      decoration: _pillDecoration('09XX-XXX-XXXX'),
                      validator: _validatePhone,
                    ),

                    const SizedBox(height: 18),

                    // DATE OF BIRTH
                    const _FieldLabel(icon: Icons.cake_rounded, label: 'DATE OF BIRTH', required: true),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _pickDateOfBirth,
                      child: Container(
                        height: 56,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: dobError ? const Color(0xFFEF4444) : const Color(0xFFE5E7EB),
                            width: dobError ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              _selectedDob == null
                                  ? 'Select date of birth'
                                  : DateFormat('MMMM d, yyyy').format(_selectedDob!),
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: _selectedDob == null ? const Color(0xFF9CA3AF) : const Color(0xFF1F2937),
                              ),
                            ),
                            const Spacer(),
                            Icon(Icons.calendar_today_rounded,
                                color: dobError ? const Color(0xFFEF4444) : const Color(0xFF6B7280), size: 20),
                          ],
                        ),
                      ),
                    ),
                    if (dobError) ...[
                      const SizedBox(height: 6),
                      const Padding(
                        padding: EdgeInsets.only(left: 16),
                        child: Text('Date of birth is required',
                            style: TextStyle(color: Color(0xFFEF4444), fontSize: 12, fontWeight: FontWeight.w700)),
                      ),
                    ],

                    const SizedBox(height: 18),

                    // GENDER
                    const _FieldLabel(icon: Icons.wc_rounded, label: 'GENDER', required: false),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedGender,
                      style: const TextStyle(color: Color(0xFF1F2937), fontSize: 16, fontWeight: FontWeight.w700),
                      decoration: _pillDecoration('Select gender'),
                      items: _genders
                          .map((g) => DropdownMenuItem<String>(
                                value: g.label,
                                child: Row(
                                  children: [
                                    Icon(g.icon, size: 20, color: const Color(0xFF00A36C)),
                                    const SizedBox(width: 10),
                                    Text(g.label,
                                        style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1F2937))),
                                  ],
                                ),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedGender = v),
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF6B7280)),
                      dropdownColor: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),

                    const SizedBox(height: 18),

                    // HOME ADDRESS
                    const _FieldLabel(icon: Icons.home_rounded, label: 'HOME ADDRESS', required: false),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _addressController,
                      textCapitalization: TextCapitalization.words,
                      maxLines: 2,
                      style: const TextStyle(color: Color(0xFF1F2937), fontSize: 16, fontWeight: FontWeight.w700),
                      decoration: _pillDecoration('House #, Street, City')
                          .copyWith(contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
                    ),

                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  InputDecoration _pillDecoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 15, fontWeight: FontWeight.w500),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: const BorderSide(color: Color(0xFF00A36C), width: 2)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: const BorderSide(color: Color(0xFFEF4444))),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2)),
      );
}

class _FieldLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool required;

  const _FieldLabel({required this.icon, required this.label, required this.required});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: const Color(0xFF00A36C)),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF6B7280), letterSpacing: 0.8)),
        if (required) ...[
          const SizedBox(width: 3),
          const Text('*', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFFEF4444))),
        ] else ...[
          const SizedBox(width: 3),
          const Text('(OPTIONAL)',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF9CA3AF), letterSpacing: 0.5)),
        ],
      ],
    );
  }
}


class _DynamicPhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String text = newValue.text;
    if (text.startsWith('09') && text.length > 11) {
      text = text.substring(0, 11);
    } else if (text.startsWith('63') && text.length > 12) {
      text = text.substring(0, 12);
    } else if (!text.startsWith('09') && !text.startsWith('63') && text.length > 12) {
      text = text.substring(0, 12);
    }
    return newValue.copyWith(text: text, selection: TextSelection.collapsed(offset: text.length));
  }
}
