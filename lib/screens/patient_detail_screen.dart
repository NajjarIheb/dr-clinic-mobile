import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../config/routes.dart';
import '../config/theme.dart';
import '../models/patient.dart';
import '../models/clinical_note.dart';
import '../models/prescription.dart';
import '../models/billing.dart';
import '../models/vital.dart';
import '../providers/auth_provider.dart';
import '../services/database_service.dart';
import '../services/pdf_service.dart';

class PatientDetailScreen extends StatefulWidget {
  final String patientId;
  const PatientDetailScreen({super.key, required this.patientId});

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  Patient? _patient;
  List<ClinicalNote> _notes = [];
  List<Prescription> _prescriptions = [];
  List<Billing> _bills = [];
  List<Vital> _vitals = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final patient = await DatabaseService.getPatient(widget.patientId);
    final notes = await DatabaseService.getNotesForPatient(widget.patientId);
    final rx = await DatabaseService.getPrescriptionsForPatient(widget.patientId);
    final bills = await DatabaseService.getBillingForPatient(widget.patientId);
    final vitals = await DatabaseService.getVitalsForPatient(widget.patientId);
    if (!mounted) return;
    setState(() {
      _patient = patient;
      _notes = notes;
      _prescriptions = rx;
      _bills = bills;
      _vitals = vitals;
      _loading = false;
    });
  }

  Future<void> _exportChartPdf() async {
    final doctor = context.read<AuthProvider>().currentDoctor;
    if (_patient != null && doctor != null) {
      await PdfService.printPatientChart(
        doctor: doctor,
        patient: _patient!,
        vitals: _vitals,
        notes: _notes,
        prescriptions: _prescriptions,
      );
    }
  }

  Future<void> _printPrescriptions() async {
    final doctor = context.read<AuthProvider>().currentDoctor;
    if (_patient != null && doctor != null && _prescriptions.isNotEmpty) {
      await PdfService.printPrescription(
        doctor: doctor,
        patient: _patient!,
        prescriptions: _prescriptions.where((r) => r.status == 'active').isNotEmpty
            ? _prescriptions.where((r) => r.status == 'active').toList()
            : _prescriptions,
      );
    }
  }

  void _showRecordVitalsDialog() {
    final bpSysCtrl = TextEditingController(text: '120');
    final bpDiaCtrl = TextEditingController(text: '80');
    final hrCtrl = TextEditingController(text: '72');
    final tempCtrl = TextEditingController(text: '37.0');
    final respCtrl = TextEditingController(text: '16');
    final weightCtrl = TextEditingController(text: '70');
    final heightCtrl = TextEditingController(text: '175');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.favorite, color: AppTheme.accentRed),
            const SizedBox(width: 8),
            const Text('Record Patient Vitals'),
          ],
        ),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: bpSysCtrl,
                          decoration: const InputDecoration(labelText: 'BP Sys (mmHg)', hintText: '120'),
                          keyboardType: TextInputType.number,
                          validator: (v) => v != null && v.isNotEmpty ? null : 'Required',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: bpDiaCtrl,
                          decoration: const InputDecoration(labelText: 'BP Dia (mmHg)', hintText: '80'),
                          keyboardType: TextInputType.number,
                          validator: (v) => v != null && v.isNotEmpty ? null : 'Required',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: hrCtrl,
                          decoration: const InputDecoration(labelText: 'Heart Rate (bpm)', hintText: '72'),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: tempCtrl,
                          decoration: const InputDecoration(labelText: 'Temp (°C)', hintText: '37.0'),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: weightCtrl,
                          decoration: const InputDecoration(labelText: 'Weight (kg)', hintText: '70.0'),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: heightCtrl,
                          decoration: const InputDecoration(labelText: 'Height (cm)', hintText: '175'),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: respCtrl,
                    decoration: const InputDecoration(labelText: 'Respiratory Rate (breaths/min)'),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final sys = int.tryParse(bpSysCtrl.text.trim()) ?? 120;
              final dia = int.tryParse(bpDiaCtrl.text.trim()) ?? 80;
              final hr = int.tryParse(hrCtrl.text.trim()) ?? 72;
              final temp = double.tryParse(tempCtrl.text.trim()) ?? 37.0;
              final resp = int.tryParse(respCtrl.text.trim()) ?? 16;
              final weight = double.tryParse(weightCtrl.text.trim()) ?? 70.0;
              final height = double.tryParse(heightCtrl.text.trim()) ?? 175.0;

              final vital = Vital(
                id: const Uuid().v4(),
                patientId: widget.patientId,
                bloodPressureSys: sys,
                bloodPressureDia: dia,
                heartRate: hr,
                temperature: temp,
                respiratoryRate: resp,
                weight: weight,
                height: height,
                recordedAt: DateTime.now(),
              );

              final nav = Navigator.of(ctx);
              final messenger = ScaffoldMessenger.of(context);
              await DatabaseService.insertVital(vital);
              nav.pop();
              await _loadData();
              if (!mounted) return;
              messenger.showSnackBar(
                const SnackBar(
                  content: Text('Vitals recorded successfully'),
                  backgroundColor: AppTheme.accentGreen,
                ),
              );
            },
            child: const Text('Save Vitals'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_patient == null) {
      return const Scaffold(body: Center(child: Text('Patient not found')));
    }
    final p = _patient!;
    return Scaffold(
      appBar: AppBar(
        title: Text(p.fullName),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Export Patient Chart PDF',
            onPressed: _exportChartPdf,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(p),
            const SizedBox(height: 16),
            _buildInfoCard(p),
            const SizedBox(height: 16),
            _buildQuickActions(p),
            const SizedBox(height: 16),
            _buildVitalsSection(),
            const SizedBox(height: 16),
            _buildSectionHeaderWithAction('Clinical Notes', 'New Note', () {
              Navigator.pushNamed(context, AppRoutes.clinicalNote,
                      arguments: {'patientId': p.id})
                  .then((_) => _loadData());
            }),
            ..._notes.map((n) => _buildNoteTile(n)),
            if (_notes.isEmpty) _buildEmpty('No clinical notes recorded yet'),
            const SizedBox(height: 16),
            _buildSectionHeaderWithAction('Prescriptions', 'New Order', () {
              Navigator.pushNamed(context, AppRoutes.prescription,
                      arguments: {'patientId': p.id})
                  .then((_) => _loadData());
            }, onPrint: _prescriptions.isNotEmpty ? _printPrescriptions : null),
            ..._prescriptions.map((r) => _buildRxTile(r)),
            if (_prescriptions.isEmpty) _buildEmpty('No prescriptions on record'),
            const SizedBox(height: 16),
            _buildSectionHeaderWithAction('Billing & Invoicing', 'New Bill', () {
              Navigator.pushNamed(context, AppRoutes.billing)
                  .then((_) => _loadData());
            }),
            ..._bills.map((b) => _buildBillTile(b)),
            if (_bills.isEmpty) _buildEmpty('No billing records found'),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Patient p) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.1),
              child: Text(p.initials,
                  style: const TextStyle(
                      fontSize: 24,
                      color: AppTheme.primaryBlue,
                      fontWeight: FontWeight.w600)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.fullName,
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text(
                    '${p.gender}, ${p.age} yrs  |  DOB: ${DateFormat('MMM dd, yyyy').format(p.dob)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(Patient p) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Contact & Insurance',
                style: Theme.of(context).textTheme.titleMedium),
            const Divider(),
            _infoRow(Icons.phone, 'Phone', p.phone),
            _infoRow(Icons.email_outlined, 'Email', p.email.isEmpty ? '—' : p.email),
            _infoRow(Icons.health_and_safety, 'Blood Type', p.bloodType.isEmpty ? '—' : p.bloodType),
            _infoRow(Icons.warning_amber, 'Allergies', p.allergies.isEmpty ? 'None' : p.allergies),
            _infoRow(Icons.medical_services_outlined, 'Insurance', p.insuranceProvider.isEmpty ? '—' : p.insuranceProvider),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.textSecondary),
          const SizedBox(width: 8),
          Text('$label: ', style: Theme.of(context).textTheme.bodySmall),
          Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildQuickActions(Patient p) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _actionChip(Icons.favorite_border, 'Record Vitals', _showRecordVitalsDialog),
          _actionChip(Icons.note_add, 'New Note', () {
            Navigator.pushNamed(context, AppRoutes.clinicalNote,
                arguments: {'patientId': p.id}).then((_) => _loadData());
          }),
          _actionChip(Icons.medication, 'Prescribe', () {
            Navigator.pushNamed(context, AppRoutes.prescription,
                arguments: {'patientId': p.id}).then((_) => _loadData());
          }),
          _actionChip(Icons.picture_as_pdf, 'Export Chart PDF', _exportChartPdf),
          _actionChip(Icons.calendar_today, 'Schedule', () {
            Navigator.pushNamed(context, AppRoutes.schedule).then((_) => _loadData());
          }),
        ],
      ),
    );
  }

  Widget _actionChip(IconData icon, String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        avatar: Icon(icon, size: 18, color: AppTheme.primaryBlue),
        label: Text(label),
        onPressed: onTap,
      ),
    );
  }

  Widget _buildVitalsSection() {
    final latest = _vitals.isNotEmpty ? _vitals.first : null;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.monitor_heart, color: AppTheme.accentRed, size: 20),
                    const SizedBox(width: 8),
                    Text('Latest Vitals & Biometrics',
                        style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
                TextButton.icon(
                  onPressed: _showRecordVitalsDialog,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Vitals', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
            const Divider(),
            if (latest == null)
              _buildEmpty('No vitals recorded yet. Tap "Add Vitals" to record blood pressure, pulse, temperature.')
            else ...[
              Wrap(
                spacing: 16,
                runSpacing: 12,
                children: [
                  _vitalMetric('Blood Pressure', latest.bp, 'mmHg', Icons.speed),
                  _vitalMetric('Heart Rate', latest.heartRate.toString(), 'bpm', Icons.favorite),
                  _vitalMetric('Temperature', latest.temperature.toStringAsFixed(1), '°C', Icons.thermostat),
                  _vitalMetric('Weight', latest.weight.toStringAsFixed(1), 'kg', Icons.scale),
                  _vitalMetric('BMI', latest.bmi.toStringAsFixed(1), '', Icons.accessibility_new),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Recorded: ${DateFormat('MMM dd, yyyy  HH:mm').format(latest.recordedAt)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _vitalMetric(String label, String value, String unit, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.primaryBlue),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
              Text('$value $unit', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeaderWithAction(String title, String actionLabel, VoidCallback onAction, {VoidCallback? onPrint}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (onPrint != null)
                IconButton(
                  icon: const Icon(Icons.print_outlined, size: 20, color: AppTheme.primaryBlue),
                  tooltip: 'Print',
                  onPressed: onPrint,
                ),
              TextButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add, size: 16),
                label: Text(actionLabel, style: const TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoteTile(ClinicalNote n) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(n.diagnosisCode.isNotEmpty ? 'Dx: ${n.diagnosisCode}' : 'Clinical Note',
            style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text(
          '${DateFormat('MMM dd, yyyy').format(n.createdAt)}  |  ${n.subjective.length > 80 ? '${n.subjective.substring(0, 80)}...' : n.subjective}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: const Icon(Icons.chevron_right, size: 18),
      ),
    );
  }

  Widget _buildRxTile(Prescription r) {
    final doctor = context.read<AuthProvider>().currentDoctor;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          r.status == 'active' ? Icons.check_circle : Icons.cancel,
          color: r.status == 'active' ? AppTheme.accentGreen : AppTheme.textSecondary,
        ),
        title: Text(r.medicationName,
            style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text(
          '${r.dosage} ${r.frequency}  |  Qty: ${r.quantity}  |  ${r.status}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.picture_as_pdf_outlined, color: AppTheme.primaryBlue, size: 20),
          tooltip: 'Print Rx',
          onPressed: () async {
            if (_patient != null && doctor != null) {
              await PdfService.printPrescription(
                doctor: doctor,
                patient: _patient!,
                prescriptions: [r],
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildBillTile(Billing b) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Row(
          children: [
            Text('\$${b.amount.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: b.status == 'paid'
                    ? AppTheme.accentGreen.withValues(alpha: 0.1)
                    : AppTheme.accentAmber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(b.status,
                  style: TextStyle(
                      fontSize: 12,
                      color: b.status == 'paid'
                          ? AppTheme.accentGreen
                          : AppTheme.accentAmber)),
            ),
          ],
        ),
        subtitle: Text('CPT: ${b.serviceCode}  |  Due: ${DateFormat('MMM dd, yyyy').format(b.dueDate)}',
            style: Theme.of(context).textTheme.bodySmall),
      ),
    );
  }

  Widget _buildEmpty(String msg) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Text(msg, style: Theme.of(context).textTheme.bodySmall),
      ),
    );
  }
}
