import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/pairing_service.dart';

class ConfirmPairingDialog extends StatefulWidget {
  final Map<String, dynamic> patientData;

  const ConfirmPairingDialog({super.key, required this.patientData});

  @override
  State<ConfirmPairingDialog> createState() => _ConfirmPairingDialogState();
}

class _ConfirmPairingDialogState extends State<ConfirmPairingDialog> {
  final PairingService _pairingService = PairingService();
  final String? _caregiverUid = FirebaseAuth.instance.currentUser?.uid;
  final String _caregiverName = FirebaseAuth.instance.currentUser?.displayName ?? 'Caregiver';
  final String _caregiverEmail = FirebaseAuth.instance.currentUser?.email ?? '';

  String _selectedRelationship = 'Daughter';
  bool _isSubmitting = false;

  final List<String> _relationships = [
    'Daughter',
    'Son',
    'Spouse',
    'Parent',
    'Sibling',
    'Grandchild',
    'Other',
  ];

  Future<void> _sendRequest() async {
    if (_caregiverUid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to send pairing request.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await _pairingService.sendPairingRequest(
        patientUid: widget.patientData['patientUid'],
        patientName: widget.patientData['name'] ?? 'Patient',
        caregiverUid: _caregiverUid!,
        caregiverName: _caregiverName,
        caregiverEmail: _caregiverEmail,
        relationship: _selectedRelationship,
      );

      if (mounted) {
        setState(() => _isSubmitting = false);
        Navigator.pop(context); // Close dialog

        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: const Text('Request Sent!'),
            content: Text(
              'A connection request has been sent to ${widget.patientData['name']}. Once approved, you will be connected.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('OK', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const emerald = Color(0xFF10B981);
    final patientName = widget.patientData['name'] ?? 'Patient';
    final patientEmail = widget.patientData['email'] ?? '';
    final age = widget.patientData['age'];

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Patient Avatar
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Color(0xFFECFDF5),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                patientName.isNotEmpty ? patientName[0].toUpperCase() : 'P',
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: emerald),
              ),
            ),
            const SizedBox(height: 16),

            // Patient Name & Info
            Text(
              patientName,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
              textAlign: TextAlign.center,
            ),
            if (patientEmail.isNotEmpty || age != null) ...[
              const SizedBox(height: 4),
              Text(
                '${age != null ? 'Age $age · ' : ''}$patientEmail',
                style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                textAlign: TextAlign.center,
              ),
            ],

            const SizedBox(height: 20),
            const Divider(height: 1, color: Color(0xFFF3F4F6)),
            const SizedBox(height: 20),

            // Relationship Selector Title
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Select Your Relationship',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF374151)),
              ),
            ),
            const SizedBox(height: 12),

            // Relationship Choice Chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _relationships.map((rel) {
                final isSelected = _selectedRelationship == rel;
                return ChoiceChip(
                  label: Text(rel),
                  selected: isSelected,
                  selectedColor: emerald,
                  backgroundColor: const Color(0xFFF3F4F6),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF4B5563),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  side: BorderSide.none,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedRelationship = rel);
                    }
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Send Connection Request Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _sendRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: emerald,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Send Connection Request',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
