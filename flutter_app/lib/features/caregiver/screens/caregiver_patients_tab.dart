import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/caregiver_patient_card.dart';
import 'caregiver_connect_patient_screen.dart';
import 'caregiver_patient_details_screen.dart';
import 'caregiver_patient_schedule_screen.dart';
import 'caregiver_live_camera_screen.dart';
import '../../pairing/services/pairing_service.dart';
import 'package:smartdose/shared/widgets/smartdose_loading.dart';

class CaregiverPatientsTab extends StatefulWidget {
  const CaregiverPatientsTab({super.key});

  @override
  State<CaregiverPatientsTab> createState() => _CaregiverPatientsTabState();
}

class _CaregiverPatientsTabState extends State<CaregiverPatientsTab> {
  final PairingService _pairingService = PairingService();
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;

  String _searchQuery = '';
  String _selectedFilter = 'All'; // All, Online, Offline, Attention

  final List<Map<String, dynamic>> _samplePatients = [
    {
      'id': 'patient-1',
      'patientName': 'Maria Delgado',
      'relationship': 'Mother',
      'age': 68,
      'isOnline': true,
      'adherence': 96,
      'nextDose': 'In 45m · Metformin (500mg)',
      'needsAttention': false,
      'photoUrl': null,
    },
    {
      'id': 'patient-2',
      'patientName': 'Robert Chen',
      'relationship': 'Father',
      'age': 74,
      'isOnline': true,
      'adherence': 88,
      'nextDose': 'In 2h 10m · Lisinopril (10mg)',
      'needsAttention': false,
      'photoUrl': null,
    },
    {
      'id': 'patient-3',
      'patientName': 'Eleanor Vance',
      'relationship': 'Grandmother',
      'age': 82,
      'isOnline': false,
      'adherence': 72,
      'nextDose': 'Overdue by 15m · Atorvastatin',
      'needsAttention': true,
      'photoUrl': null,
    },
  ];

  List<Map<String, dynamic>> _filterPatients(List<Map<String, dynamic>> patients) {
    return patients.where((p) {
      final name = (p['patientName'] ?? p['name'] ?? '').toString().toLowerCase();
      final matchesSearch = _searchQuery.isEmpty || name.contains(_searchQuery.toLowerCase());

      final isOnline = p['isOnline'] as bool? ?? true;
      final needsAttention = p['needsAttention'] as bool? ?? false;

      bool matchesFilter = true;
      if (_selectedFilter == 'Online') matchesFilter = isOnline && !needsAttention;
      if (_selectedFilter == 'Offline') matchesFilter = !isOnline;
      if (_selectedFilter == 'Attention') matchesFilter = needsAttention;

      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryTextColor = theme.colorScheme.onSurface;
    final secondaryTextColor = primaryTextColor.withValues(alpha: 0.65);
    final cardBgColor = theme.cardTheme.color ?? theme.colorScheme.surface;

    return Stack(
      children: [
        SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 90),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Screen Title
              Text(
                'My Patients',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: primaryTextColor,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Monitor patient status, adherence, and schedules',
                style: TextStyle(fontSize: 14, color: secondaryTextColor),
              ),
              const SizedBox(height: 18),

              // Search TextField
              Container(
                decoration: BoxDecoration(
                  color: cardBgColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  style: TextStyle(color: primaryTextColor),
                  decoration: InputDecoration(
                    hintText: 'Search patients by name…',
                    hintStyle: TextStyle(color: secondaryTextColor),
                    prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF00A36C)),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () => setState(() => _searchQuery = ''),
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Status Filter Chips Row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: ['All', 'Online', 'Offline', 'Attention'].map((filter) {
                    final isSelected = _selectedFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(filter),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) setState(() => _selectedFilter = filter);
                        },
                        selectedColor: const Color(0xFF00A36C),
                        backgroundColor: cardBgColor,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : primaryTextColor,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                          fontSize: 13,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: isSelected
                                ? const Color(0xFF00A36C)
                                : (isDark ? const Color(0xFF27272A) : const Color(0xFFE5E7EB)),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 20),

              // Patient Cards Stream or Sample list
              _uid == null
                  ? _buildPatientList(_filterPatients(_samplePatients))
                  : StreamBuilder<List<Map<String, dynamic>>>(
                      stream: _pairingService.getConnectedPatientsStream(_uid!),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(30),
                              child: SmartDoseLoading(size: 60),
                            ),
                          );
                        }
                        final fetched = snapshot.data ?? [];
                        final list = fetched.isEmpty ? _samplePatients : fetched;
                        final filtered = _filterPatients(list);
                        return _buildPatientList(filtered);
                      },
                    ),
            ],
          ),
        ),

        // Floating "Connect Patient" Action Button
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CaregiverConnectPatientScreen()),
              );
            },
            backgroundColor: const Color(0xFF00A36C),
            icon: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white),
            label: const Text(
              'Connect Patient',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPatientList(List<Map<String, dynamic>> patients) {
    final theme = Theme.of(context);
    final primaryTextColor = theme.colorScheme.onSurface;
    final secondaryTextColor = primaryTextColor.withValues(alpha: 0.65);

    if (patients.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: theme.cardTheme.color ?? theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            Icon(Icons.person_search_rounded, size: 54, color: secondaryTextColor.withValues(alpha: 0.4)),
            const SizedBox(height: 14),
            Text(
              'No patients found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryTextColor),
            ),
            const SizedBox(height: 6),
            Text(
              'Try adjusting your search query or filter selection.',
              style: TextStyle(fontSize: 13, color: secondaryTextColor),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: patients.map((p) {
        final id = (p['patientId'] ?? p['id'] ?? 'patient-1').toString();
        final name = (p['patientName'] ?? p['name'] ?? 'Patient').toString();

        return CaregiverPatientCard(
          patient: p,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CaregiverPatientDetailsScreen(
                  patientId: id,
                  patientName: name,
                ),
              ),
            );
          },
          onScheduleTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CaregiverPatientScheduleScreen(
                  patientId: id,
                  patientName: name,
                ),
              ),
            );
          },
          onCameraTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CaregiverLiveCameraScreen(
                  patientId: id,
                  patientName: name,
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}
