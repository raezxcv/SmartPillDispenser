import 'package:flutter/material.dart';

class CaregiverDashboardScreen extends StatelessWidget {
  final VoidCallback onSwitchRole;

  const CaregiverDashboardScreen({super.key, required this.onSwitchRole});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Caregiver Portal',
          style: TextStyle(color: Color(0xFF1F2937), fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz_rounded, color: Color(0xFF3B82F6)),
            onPressed: onSwitchRole,
            tooltip: 'Switch Role',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Patient overview card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                      color: Color(0xFFD1FAE5),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Text('MD', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 18)),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Maria Delgado', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
                        Text('Dispenser M2 · Adherence: 94%', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                      ],
                    ),
                  ),
                  const Chip(
                    label: Text('Tray Clear', style: TextStyle(color: Color(0xFF10B981), fontSize: 12, fontWeight: FontWeight.bold)),
                    backgroundColor: Color(0xFFD1FAE5),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Text('Caregiver Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(child: _buildActionTile(Icons.schedule_rounded, 'Manage Schedule', Colors.blue)),
                const SizedBox(width: 12),
                Expanded(child: _buildActionTile(Icons.medical_services_rounded, 'Emergency Dispense', Colors.amber)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildActionTile(Icons.camera_alt_rounded, 'Live Camera', Colors.purple)),
                const SizedBox(width: 12),
                Expanded(child: _buildActionTile(Icons.bar_chart_rounded, 'Adherence Reports', Colors.green)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(IconData icon, String label, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1F2937))),
        ],
      ),
    );
  }
}
