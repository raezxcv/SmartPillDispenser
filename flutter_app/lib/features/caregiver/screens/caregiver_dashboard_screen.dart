import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../pairing/services/pairing_service.dart';
import '../../pairing/screens/connect_patient_screen.dart';

class CaregiverDashboardScreen extends StatefulWidget {
  final VoidCallback onSwitchRole;

  const CaregiverDashboardScreen({super.key, required this.onSwitchRole});

  @override
  State<CaregiverDashboardScreen> createState() => _CaregiverDashboardScreenState();
}

class _CaregiverDashboardScreenState extends State<CaregiverDashboardScreen> {
  final PairingService _pairingService = PairingService();
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    const emerald = Color(0xFF10B981);

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
            icon: const Icon(Icons.qr_code_scanner_rounded, color: emerald),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ConnectPatientScreen()),
              );
            },
            tooltip: 'Connect to Patient',
          ),
          IconButton(
            icon: const Icon(Icons.swap_horiz_rounded, color: Color(0xFF3B82F6)),
            onPressed: widget.onSwitchRole,
            tooltip: 'Switch Role',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Connected Patients List / Overview Header
            const Text(
              'Connected Patients',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
            ),
            const SizedBox(height: 12),

            _uid == null
                ? _buildSamplePatientCard()
                : StreamBuilder<List<Map<String, dynamic>>>(
                    stream: _pairingService.getConnectedPatientsStream(_uid!),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: CircularProgressIndicator(color: emerald),
                        ));
                      }

                      final patients = snapshot.data ?? [];
                      if (patients.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFECFDF5),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.person_add_alt_1_rounded, color: emerald),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'No Connected Patients Yet',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      'Scan a patient\'s QR code to connect and manage their dispenser.',
                                      style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                                    ),
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const ConnectPatientScreen()),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: emerald,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                ),
                                child: const Text('Scan QR', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        );
                      }

                      return Column(
                        children: patients.map((p) {
                          final patientName = p['patientName'] ?? 'Patient';
                          final relationship = p['relationship'] ?? 'Caregiver';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
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
                                  child: Text(
                                    patientName[0].toUpperCase(),
                                    style: const TextStyle(color: emerald, fontWeight: FontWeight.bold, fontSize: 18),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(patientName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
                                      Text('$relationship · Dispenser M2 · Adherence: 96%', style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                                    ],
                                  ),
                                ),
                                const Chip(
                                  label: Text('Connected', style: TextStyle(color: emerald, fontSize: 12, fontWeight: FontWeight.bold)),
                                  backgroundColor: Color(0xFFD1FAE5),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),

            const SizedBox(height: 20),

            const Text('Caregiver Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
            const SizedBox(height: 12),

            // Connect Patient Action Tile (Emerald QR Code Scanner)
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ConnectPatientScreen()),
                );
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: emerald.withValues(alpha: 0.3)),
                  boxShadow: [
                    BoxShadow(color: emerald.withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: emerald,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 28),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Connect to Patient', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF065F46))),
                          SizedBox(height: 2),
                          Text('Scan patient\'s QR code or enter pairing code', style: TextStyle(fontSize: 13, color: Color(0xFF047857))),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded, size: 18, color: emerald),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

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

  Widget _buildSamplePatientCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10),
        ],
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: Color(0xFFD1FAE5),
            child: Text('MD', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 18)),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Maria Delgado', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
                Text('Dispenser M2 · Adherence: 94%', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
              ],
            ),
          ),
          Chip(
            label: Text('Tray Clear', style: TextStyle(color: Color(0xFF10B981), fontSize: 12, fontWeight: FontWeight.bold)),
            backgroundColor: Color(0xFFD1FAE5),
          ),
        ],
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
