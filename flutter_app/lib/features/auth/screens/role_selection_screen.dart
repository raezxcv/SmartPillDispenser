import 'package:flutter/material.dart';

class RoleSelectionScreen extends StatelessWidget {
  final Function(String role) onRoleSelected;

  const RoleSelectionScreen({super.key, required this.onRoleSelected});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981).withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(Icons.medication_rounded, color: Colors.white, size: 36),
              ),
              const SizedBox(height: 20),
              const Text(
                'Smart Pill Dispenser',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Select your user role to enter the app',
                style: TextStyle(fontSize: 15, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 36),
              
              // Patient Role Card
              _buildRoleCard(
                context,
                title: 'Patient',
                subtitle: 'View today\'s doses, countdowns & dispense meds',
                icon: Icons.person_rounded,
                color: const Color(0xFF10B981),
                roleKey: 'patient',
              ),
              const SizedBox(height: 16),

              // Caregiver Role Card
              _buildRoleCard(
                context,
                title: 'Caregiver / Family',
                subtitle: 'Manage schedules, monitor adherence & alerts',
                icon: Icons.family_restroom_rounded,
                color: const Color(0xFF3B82F6),
                roleKey: 'caregiver',
              ),
              const SizedBox(height: 16),

              // Admin Role Card
              _buildRoleCard(
                context,
                title: 'Technician / Sysadmin',
                subtitle: 'Fleet diagnostics, logs, device actions & OTA',
                icon: Icons.admin_panel_settings_rounded,
                color: const Color(0xFF8B5CF6),
                roleKey: 'admin',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String roleKey,
  }) {
    return InkWell(
      onTap: () => onRoleSelected(roleKey),
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF9CA3AF), size: 16),
          ],
        ),
      ),
    );
  }
}
