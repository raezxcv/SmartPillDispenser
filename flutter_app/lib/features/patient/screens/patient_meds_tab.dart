import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'patient_alerts_tab.dart';

class PatientMedsTab extends StatefulWidget {
  const PatientMedsTab({super.key});

  @override
  State<PatientMedsTab> createState() => _PatientMedsTabState();
}

class _PatientMedsTabState extends State<PatientMedsTab> {
  int _selectedDateIndex = 0;
  late List<DateTime> _weekDays;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

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

  DateTime get _selectedDate => _weekDays[_selectedDateIndex];

  Stream<QuerySnapshot<Map<String, dynamic>>>? get _schedulesStream {
    final uid = _uid;
    if (uid == null) return null;
    final startOfDay = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return FirebaseFirestore.instance
        .collection('schedules')
        .where('patientUid', isEqualTo: uid)
        .where('isActive', isEqualTo: true)
        .where('scheduledTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('scheduledTime', isLessThan: Timestamp.fromDate(endOfDay))
        .orderBy('scheduledTime')
        .snapshots();
  }

  void _showMedicationSheet({DocumentSnapshot<Map<String, dynamic>>? editDoc}) {
    final isEditing = editDoc != null;
    final editData = editDoc?.data();

    final nameCtrl = TextEditingController(text: editData?['medicationName'] ?? '');
    final dosageCtrl = TextEditingController(text: editData?['dosage'] ?? '');
    String selectedComp = editData?['compartment'] ?? 'Compartment 1';
    TimeOfDay selectedTime = TimeOfDay(
      hour: editData?['scheduledTime'] != null
          ? (editData!['scheduledTime'] as Timestamp).toDate().hour
          : 8,
      minute: editData?['scheduledTime'] != null
          ? (editData!['scheduledTime'] as Timestamp).toDate().minute
          : 0,
    );
    String selectedFreq = editData?['frequency'] ?? 'Daily';

    final cardBgColor = Theme.of(context).colorScheme.surface;
    final primaryTextColor = Theme.of(context).colorScheme.onSurface;

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
                    IconButton(
                      icon: Icon(Icons.close_rounded, color: primaryTextColor.withValues(alpha: 0.6)),
                      onPressed: () => Navigator.pop(ctx),
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
                    prefixIcon: const Icon(Icons.medication_outlined, color: Color(0xFF00A36C)),
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
                    prefixIcon: const Icon(Icons.fitness_center_rounded, color: Color(0xFF00A36C)),
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
                        items: List.generate(10, (i) => 'Compartment ${i + 1}')
                            .map((c) => DropdownMenuItem(
                                  value: c,
                                  child: Text('Comp ${c.split(' ').last}', style: TextStyle(color: primaryTextColor)),
                                ))
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
                          DropdownMenuItem(value: 'Once', child: Text('Once')),
                          DropdownMenuItem(value: 'Weekly', child: Text('Weekly')),
                        ],
                        onChanged: (val) => setSheetState(() => selectedFreq = val!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                InkWell(
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: ctx,
                      initialTime: selectedTime,
                    );
                    if (picked != null) setSheetState(() => selectedTime = picked);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.access_time_rounded, color: Color(0xFF00A36C)),
                            const SizedBox(width: 12),
                            Text(
                              'Scheduled: ${selectedTime.format(ctx)}',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: primaryTextColor),
                            ),
                          ],
                        ),
                        Icon(Icons.arrow_drop_down_rounded, color: primaryTextColor.withValues(alpha: 0.6)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00A36C),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                      elevation: 0,
                    ),
                    onPressed: () async {
                      final name = nameCtrl.text.trim();
                      final dosage = dosageCtrl.text.trim();
                      final uid = _uid;
                      if (name.isEmpty || uid == null) return;

                      final compNum = selectedComp.split(' ').last;
                      final scheduledDateTime = DateTime(
                        _selectedDate.year,
                        _selectedDate.month,
                        _selectedDate.day,
                        selectedTime.hour,
                        selectedTime.minute,
                      );

                      final docData = {
                        'patientUid': uid,
                        'medicationName': name,
                        'dosage': dosage.isEmpty ? '1 tablet' : dosage,
                        'compartment': selectedComp,
                        'compCode': 'C$compNum',
                        'scheduledTime': Timestamp.fromDate(scheduledDateTime),
                        'frequency': selectedFreq,
                        'status': 'Upcoming',
                        'isActive': true,
                        'updatedAt': FieldValue.serverTimestamp(),
                      };

                      if (isEditing) {
                        await editDoc.reference.update(docData);
                      } else {
                        docData['createdAt'] = FieldValue.serverTimestamp();
                        await FirebaseFirestore.instance.collection('schedules').add(docData);
                      }

                      if (mounted) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(isEditing ? '$name updated!' : '$name added to $selectedComp!'),
                            backgroundColor: const Color(0xFF00A36C),
                          ),
                        );
                      }
                    },
                    child: Text(
                      isEditing ? 'Update Medication' : 'Save Medication',
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

  Future<void> _deleteSchedule(DocumentSnapshot<Map<String, dynamic>> doc) async {
    await doc.reference.update({'isActive': false});
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Medication removed from schedule.'), backgroundColor: Color(0xFF6B7280)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryTextColor = theme.colorScheme.onSurface;
    final secondaryTextColor = primaryTextColor.withValues(alpha: 0.65);

    return Stack(
      children: [
        SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 90),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Schedule',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: primaryTextColor, letterSpacing: -0.5),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('EEEE, d MMMM yyyy').format(_selectedDate),
                        style: TextStyle(fontSize: 15, color: secondaryTextColor),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PatientAlertsTab()),
                      );
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: theme.cardTheme.color ?? theme.colorScheme.surface,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: theme.brightness == Brightness.dark ? 0.2 : 0.04),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Icon(LucideIcons.bell, color: primaryTextColor, size: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildDateStrip(),
              const SizedBox(height: 24),
              _buildScheduleList(),
            ],
          ),
        ),

        // Floating Action Button
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Center(
            child: GestureDetector(
              onTap: () => _showMedicationSheet(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF00A36C),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00A36C).withValues(alpha: 0.38),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_rounded, color: Colors.white, size: 22),
                    SizedBox(width: 8),
                    Text(
                      'Add medication',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateStrip() {
    const dayLabels = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardBgColor = theme.cardTheme.color ?? theme.colorScheme.surface;
    final primaryTextColor = theme.colorScheme.onSurface;
    final secondaryTextColor = primaryTextColor.withValues(alpha: 0.65);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_weekDays.length, (idx) {
          final date = _weekDays[idx];
          final isSelected = idx == _selectedDateIndex;
          final isToday = () {
            final now = DateTime.now();
            return date.year == now.year && date.month == now.month && date.day == now.day;
          }();

          return GestureDetector(
            onTap: () => setState(() => _selectedDateIndex = idx),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF00A36C) : Colors.transparent,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                children: [
                  Text(
                    dayLabels[idx],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white70 : secondaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${date.day}',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: isToday ? FontWeight.w900 : FontWeight.bold,
                      color: isSelected ? Colors.white : (isToday ? const Color(0xFF00A36C) : primaryTextColor),
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

  Widget _buildScheduleList() {
    final theme = Theme.of(context);
    final cardBgColor = theme.cardTheme.color ?? theme.colorScheme.surface;
    final primaryTextColor = theme.colorScheme.onSurface;
    final secondaryTextColor = primaryTextColor.withValues(alpha: 0.65);

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _schedulesStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(color: Color(0xFF00A36C)),
            ),
          );
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return Container(
            margin: const EdgeInsets.only(top: 24),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: cardBgColor,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                Icon(Icons.calendar_today_outlined, size: 48, color: secondaryTextColor.withValues(alpha: 0.4)),
                const SizedBox(height: 16),
                Text(
                  'No medications scheduled',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryTextColor),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap "Add medication" below to schedule a dose for this day.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: secondaryTextColor),
                ),
              ],
            ),
          );
        }

        return Column(
          children: docs.map((doc) => _buildScheduleCard(doc)).toList(),
        );
      },
    );
  }

  Widget _buildScheduleCard(DocumentSnapshot<Map<String, dynamic>> doc) {
    final med = doc.data() ?? {};
    final name = med['medicationName'] ?? 'Medication';
    final dosage = med['dosage'] ?? '1 tablet';
    final comp = med['compartment'] ?? 'Compartment 1';
    final compCode = med['compCode'] ?? 'C1';
    final status = med['status'] as String? ?? 'Upcoming';
    final ts = med['scheduledTime'] as Timestamp?;
    final timeStr = ts != null ? DateFormat('hh:mm a').format(ts.toDate()) : '--:--';

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardBgColor = theme.cardTheme.color ?? theme.colorScheme.surface;
    final primaryTextColor = theme.colorScheme.onSurface;
    final secondaryTextColor = primaryTextColor.withValues(alpha: 0.65);

    Color statusBg;
    Color statusText;
    IconData statusIcon;

    switch (status.toLowerCase()) {
      case 'taken':
        statusBg = isDark ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5);
        statusText = const Color(0xFF10B981);
        statusIcon = Icons.check_circle_outline_rounded;
        break;
      case 'missed':
        statusBg = isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFEE2E2);
        statusText = const Color(0xFFEF4444);
        statusIcon = Icons.cancel_outlined;
        break;
      case 'late':
        statusBg = isDark ? const Color(0xFF78350F) : const Color(0xFFFEF3C7);
        statusText = const Color(0xFFF59E0B);
        statusIcon = Icons.access_time_rounded;
        break;
      default:
        statusBg = isDark ? const Color(0xFF064E3B) : const Color(0xFFE6F7F0);
        statusText = const Color(0xFF00A36C);
        statusIcon = Icons.access_time_rounded;
    }

    return Dismissible(
      key: Key(doc.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 14),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFEE2E2),
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 28),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Remove medication?'),
            content: Text('Remove $name from this schedule?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Remove', style: TextStyle(color: Color(0xFFEF4444))),
              ),
            ],
          ),
        ) ?? false;
      },
      onDismissed: (_) => _deleteSchedule(doc),
      child: GestureDetector(
        onTap: () => _showMedicationSheet(editDoc: doc),
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: cardBgColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03), blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF064E3B) : const Color(0xFFE6F7F0),
                  shape: BoxShape.circle,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(timeStr.split(' ')[0],
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF00A36C))),
                    Text(timeStr.length > 5 ? timeStr.split(' ').last : '',
                        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Color(0xFF00A36C))),
                    const SizedBox(height: 1),
                    Text(compCode, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF00A36C))),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryTextColor)),
                    const SizedBox(height: 3),
                    Text('$dosage · $comp',
                        style: TextStyle(fontSize: 13, color: secondaryTextColor)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(14)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, color: statusText, size: 14),
                          const SizedBox(width: 4),
                          Text(status,
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: statusText)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: secondaryTextColor, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}
