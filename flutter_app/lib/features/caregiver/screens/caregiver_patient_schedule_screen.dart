import 'package:flutter/material.dart';
import 'caregiver_medication_details_screen.dart';
import 'package:smartdose/shared/widgets/smartdose_loading.dart';

class CaregiverPatientScheduleScreen extends StatefulWidget {
  final String patientId;
  final String patientName;

  const CaregiverPatientScheduleScreen({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  State<CaregiverPatientScheduleScreen> createState() => _CaregiverPatientScheduleScreenState();
}

class _CaregiverPatientScheduleScreenState extends State<CaregiverPatientScheduleScreen> {
  int _selectedDateIndex = 0;
  late List<DateTime> _weekDays;

  // Local state medication schedules
  final List<Map<String, dynamic>> _schedules = [
    {
      'id': 'med-1',
      'medicationName': 'Metformin',
      'dosage': '500 mg',
      'compartment': 'Compartment 1',
      'time': '08:00 AM',
      'frequency': 'Daily',
      'days': 'Mon, Tue, Wed, Thu, Fri, Sat, Sun',
      'notes': 'Take after meal with water.',
      'startDate': '2026-01-01',
      'endDate': '2026-12-31',
      'isEnabled': true,
      'status': 'Upcoming',
    },
    {
      'id': 'med-2',
      'medicationName': 'Lisinopril',
      'dosage': '10 mg',
      'compartment': 'Compartment 2',
      'time': '12:30 PM',
      'frequency': 'Daily',
      'days': 'Mon, Tue, Wed, Thu, Fri, Sat, Sun',
      'notes': 'Blood pressure medication.',
      'startDate': '2026-02-15',
      'endDate': '2026-11-30',
      'isEnabled': true,
      'status': 'Taken',
    },
    {
      'id': 'med-3',
      'medicationName': 'Atorvastatin',
      'dosage': '20 mg',
      'compartment': 'Compartment 3',
      'time': '09:00 PM',
      'frequency': 'Daily',
      'days': 'Mon, Tue, Wed, Thu, Fri, Sat, Sun',
      'notes': 'Take before bedtime.',
      'startDate': '2026-03-01',
      'endDate': '2026-12-31',
      'isEnabled': false,
      'status': 'Disabled',
    },
  ];

  @override
  void initState() {
    super.initState();
    _generateWeekDays();
  }

  void _generateWeekDays() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    _weekDays = List.generate(7, (i) => monday.add(Duration(days: i)));
    final todayIndex = _weekDays.indexWhere((d) =>
        d.year == now.year && d.month == now.month && d.day == now.day);
    if (todayIndex != -1) _selectedDateIndex = todayIndex;
  }

  void _showMedicationSheet({Map<String, dynamic>? editMed}) {
    final isEditing = editMed != null;

    final nameCtrl = TextEditingController(text: editMed?['medicationName'] ?? '');
    final dosageCtrl = TextEditingController(text: editMed?['dosage'] ?? '500 mg');
    final notesCtrl = TextEditingController(text: editMed?['notes'] ?? '');

    String selectedComp = editMed?['compartment'] ?? 'Compartment 1';
    String selectedFreq = editMed?['frequency'] ?? 'Daily';

    final cardBgColor = Theme.of(context).colorScheme.surface;
    final primaryTextColor = Theme.of(context).colorScheme.onSurface;

    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
          decoration: BoxDecoration(
            color: cardBgColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEditing ? 'Edit Medication' : 'Add Medication',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryTextColor),
                    ),
                    Row(
                      children: [
                        if (isEditing)
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444)),
                            onPressed: () {
                              setState(() {
                                _schedules.removeWhere((item) => item['id'] == editMed['id']);
                              });
                              Navigator.pop(ctx);
                            },
                          ),
                        IconButton(
                          icon: Icon(Icons.close_rounded, color: primaryTextColor.withValues(alpha: 0.6)),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameCtrl,
                  style: TextStyle(color: primaryTextColor),
                  decoration: InputDecoration(
                    labelText: 'Medication Name',
                    hintText: 'e.g. Metformin',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: dosageCtrl,
                  style: TextStyle(color: primaryTextColor),
                  decoration: InputDecoration(
                    labelText: 'Dosage',
                    hintText: 'e.g. 500 mg',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: selectedComp,
                        dropdownColor: cardBgColor,
                        style: TextStyle(color: primaryTextColor),
                        decoration: InputDecoration(
                          labelText: 'Compartment',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        items: List.generate(6, (i) => 'Compartment ${i + 1}')
                            .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                            .toList(),
                        onChanged: (val) => setSheetState(() => selectedComp = val!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: selectedFreq,
                        dropdownColor: cardBgColor,
                        style: TextStyle(color: primaryTextColor),
                        decoration: InputDecoration(
                          labelText: 'Frequency',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Daily', child: Text('Daily')),
                          DropdownMenuItem(value: 'Weekly', child: Text('Weekly')),
                          DropdownMenuItem(value: 'As Needed', child: Text('As Needed')),
                        ],
                        onChanged: (val) => setSheetState(() => selectedFreq = val!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: notesCtrl,
                  maxLines: 2,
                  style: TextStyle(color: primaryTextColor),
                  decoration: InputDecoration(
                    labelText: 'Notes / Instructions',
                    hintText: 'e.g. Take after meal with food',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00A36C),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    onPressed: isSaving
                        ? null
                        : () async {
                            final name = nameCtrl.text.trim();
                            if (name.isEmpty) return;

                            setSheetState(() => isSaving = true);
                            await Future.delayed(const Duration(milliseconds: 400));

                            if (isEditing) {
                              setState(() {
                                editMed['medicationName'] = name;
                                editMed['dosage'] = dosageCtrl.text.trim();
                                editMed['compartment'] = selectedComp;
                                editMed['frequency'] = selectedFreq;
                                editMed['notes'] = notesCtrl.text.trim();
                              });
                            } else {
                              setState(() {
                                _schedules.add({
                                  'id': 'med-${DateTime.now().millisecondsSinceEpoch}',
                                  'medicationName': name,
                                  'dosage': dosageCtrl.text.trim(),
                                  'compartment': selectedComp,
                                  'time': '08:00 AM',
                                  'frequency': selectedFreq,
                                  'days': 'Mon, Tue, Wed, Thu, Fri, Sat, Sun',
                                  'notes': notesCtrl.text.trim(),
                                  'startDate': '2026-01-01',
                                  'endDate': '2026-12-31',
                                  'isEnabled': true,
                                  'status': 'Upcoming',
                                });
                              });
                            }

                            if (mounted) Navigator.pop(ctx);
                          },
                    child: isSaving
                        ? const SmartDoseLoading(size: 32, color: Colors.white)
                        : Text(
                            isEditing ? 'Update Schedule' : 'Save Medication',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryTextColor = theme.colorScheme.onSurface;
    final secondaryTextColor = primaryTextColor.withValues(alpha: 0.65);
    final cardBgColor = theme.cardTheme.color ?? theme.colorScheme.surface;

    const emerald = Color(0xFF00A36C);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: cardBgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: primaryTextColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Medication Schedule', style: TextStyle(color: primaryTextColor, fontWeight: FontWeight.bold, fontSize: 17)),
            Text(widget.patientName, style: TextStyle(color: secondaryTextColor, fontSize: 12)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: emerald, size: 28),
            onPressed: () => _showMedicationSheet(),
            tooltip: 'Add Medication',
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Week Strip Date Selector
            _buildWeekStrip(),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Scheduled Medications',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryTextColor),
                ),
                Text(
                  '${_schedules.where((s) => s['isEnabled'] == true).length} active',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: emerald),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Schedule Cards List
            Column(
              children: _schedules.map((med) {
                final isEnabled = med['isEnabled'] as bool? ?? true;

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: cardBgColor,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(22),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CaregiverMedicationDetailsScreen(
                              patientId: widget.patientId,
                              patientName: widget.patientName,
                              medication: med,
                            ),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(22),
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: isEnabled
                                        ? (isDark ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5))
                                        : (isDark ? const Color(0xFF27272A) : const Color(0xFFF3F4F6)),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.medication_outlined,
                                    color: isEnabled ? emerald : secondaryTextColor,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        med['medicationName'],
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: isEnabled ? primaryTextColor : secondaryTextColor,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${med['dosage']} · ${med['time']}',
                                        style: TextStyle(fontSize: 13, color: secondaryTextColor),
                                      ),
                                    ],
                                  ),
                                ),
                                Switch(
                                  value: isEnabled,
                                  activeThumbColor: emerald,
                                  onChanged: (val) {
                                    setState(() {
                                      med['isEnabled'] = val;
                                    });
                                  },
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),
                            const Divider(height: 1),
                            const SizedBox(height: 10),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF27272A) : const Color(0xFFF3F4F6),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    med['compartment'],
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: primaryTextColor),
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined, size: 18),
                                      onPressed: () => _showMedicationSheet(editMed: med),
                                      tooltip: 'Edit Schedule',
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => CaregiverMedicationDetailsScreen(
                                              patientId: widget.patientId,
                                              patientName: widget.patientName,
                                              medication: med,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showMedicationSheet(),
        backgroundColor: emerald,
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildWeekStrip() {
    const dayLabels = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardBgColor = theme.cardTheme.color ?? theme.colorScheme.surface;
    final primaryTextColor = theme.colorScheme.onSurface;
    final secondaryTextColor = primaryTextColor.withValues(alpha: 0.65);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_weekDays.length, (idx) {
          final date = _weekDays[idx];
          final isSelected = idx == _selectedDateIndex;

          return GestureDetector(
            onTap: () => setState(() => _selectedDateIndex = idx),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(colors: [Color(0xFF00C882), Color(0xFF00A36C)])
                    : null,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    dayLabels[idx],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : secondaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${date.day}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: isSelected ? Colors.white : primaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
