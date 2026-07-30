import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatelessWidget {
  final VoidCallback onSwitchRole;

  const AdminDashboardScreen({super.key, required this.onSwitchRole});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Admin & Technician Portal',
          style: TextStyle(color: Color(0xFF1F2937), fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz_rounded, color: Color(0xFF8B5CF6)),
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
            // Fleet Overview Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1F2937),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('FLEET HARDWARE STATUS', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                      Chip(
                        label: Text('Project: smart-pill-dispenser-baa02', style: TextStyle(color: Colors.white, fontSize: 10)),
                        backgroundColor: Color(0xFF374151),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMetric('Online', '98', const Color(0xFF10B981)),
                      _buildMetric('Offline', '4', const Color(0xFFEF4444)),
                      _buildMetric('Emergencies', '0', const Color(0xFFF59E0B)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Text('Admin Controls', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
            const SizedBox(height: 12),

            _buildAdminRow(Icons.developer_board_rounded, 'Device Management', 'Restart, disable, or reassign dispensers'),
            const SizedBox(height: 10),
            _buildAdminRow(Icons.monitor_heart_rounded, 'Hardware Diagnostics', 'Subsystem health: servo, rtc, ir, camera, wifi'),
            const SizedBox(height: 10),
            _buildAdminRow(Icons.history_rounded, 'System Logs', 'Audit timeline of all dispense & hardware events'),
            const SizedBox(height: 10),
            _buildAdminRow(Icons.system_update_rounded, 'Firmware OTA', 'Deploy v1.2.4 or trigger emergency rollback'),
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(String label, String val, Color col) {
    return Column(
      children: [
        Text(val, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: col)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.white70)),
      ],
    );
  }

  Widget _buildAdminRow(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF8B5CF6), size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1F2937))),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF9CA3AF)),
        ],
      ),
    );
  }
}
