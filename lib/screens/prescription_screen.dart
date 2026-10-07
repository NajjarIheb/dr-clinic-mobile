import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';
import '../services/database_service.dart';
import '../services/pdf_service.dart';
import '../models/prescription.dart';
import '../models/patient.dart';

class PrescriptionScreen extends StatefulWidget {
  final String patientId;
  const PrescriptionScreen({super.key, required this.patientId});

  @override
  State<PrescriptionScreen> createState() => _PrescriptionScreenState();
}

class _PrescriptionScreenState extends State<PrescriptionScreen> {
  final _medCtrl = TextEditingController();
  final _dosageCtrl = TextEditingController();
  final _freqCtrl = TextEditingController(text: 'BID (Twice daily)');
  final _qtyCtrl = TextEditingController(text: '30');
  final _refillsCtrl = TextEditingController(text: '1');
  final _notesCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  DateTime _startDate = DateTime.now();
  final DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  List<Prescription> _existing = [];
  Patient? _patient;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final p = await DatabaseService.getPatient(widget.patientId);
    final rx = await DatabaseService.getPrescriptionsForPatient(widget.patientId);
    if (!mounted) return;
    setState(() {
      _patient = p;
      _existing = rx;
    });
  }

  @override
  void dispose() {
    _medCtrl.dispose();
    _dosageCtrl.dispose();
    _freqCtrl.dispose();
    _qtyCtrl.dispose();
    _refillsCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<Prescription?> _buildPrescriptionFromForm() async {
    if (!_formKey.currentState!.validate()) return null;
    final doctor = context.read<AuthProvider>().currentDoctor;
    return Prescription(
      id: const Uuid().v4(),
      patientId: widget.patientId,
      doctorId: doctor?.id ?? 'doc-001',
      medicationName: _medCtrl.text.trim(),
      dosage: _dosageCtrl.text.trim(),
      frequency: _freqCtrl.text.trim(),
      quantity: int.tryParse(_qtyCtrl.text.trim()) ?? 30,
      refills: int.tryParse(_refillsCtrl.text.trim()) ?? 0,
      startDate: _startDate,
      endDate: _endDate,
      notes: _notesCtrl.text.trim(),
    );
  }

  Future<void> _save() async {
    final rx = await _buildPrescriptionFromForm();
    if (rx == null) return;
    await DatabaseService.insertPrescription(rx);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Prescription created successfully'),
        backgroundColor: AppTheme.accentGreen,
      ),
    );
    Navigator.pop(context);
  }

  Future<void> _saveAndPrint() async {
    final doctor = context.read<AuthProvider>().currentDoctor;
    final rx = await _buildPrescriptionFromForm();
    if (rx == null) return;
    await DatabaseService.insertPrescription(rx);

    if (_patient != null && doctor != null) {
      await PdfService.printPrescription(
        doctor: doctor,
        patient: _patient!,
        prescriptions: [rx],
      );
    }
    if (!mounted) return;
    Navigator.pop(context);
  }

  Future<void> _printExisting(Prescription rx) async {
    final doctor = context.read<AuthProvider>().currentDoctor;
    if (_patient != null && doctor != null) {
      await PdfService.printPrescription(
        doctor: doctor,
        patient: _patient!,
        prescriptions: [rx],
      );
    }
  }

  Future<void> _printAllActive() async {
    final doctor = context.read<AuthProvider>().currentDoctor;
    final activeRx = _existing.where((r) => r.status == 'active').toList();
    if (_patient != null && doctor != null && activeRx.isNotEmpty) {
      await PdfService.printPrescription(
        doctor: doctor,
        patient: _patient!,
        prescriptions: activeRx,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_patient != null ? 'Prescription: ${_patient!.lastName}' : 'New Prescription'),
        actions: [
          if (_existing.any((r) => r.status == 'active'))
            IconButton(
              icon: const Icon(Icons.print_outlined),
              tooltip: 'Print Active Prescriptions',
              onPressed: _printAllActive,
            ),
          TextButton(
            onPressed: _save,
            child: const Text('Save', style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_existing.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Current Prescriptions (${_existing.length})',
                      style: Theme.of(context).textTheme.titleMedium),
                  TextButton.icon(
                    onPressed: _printAllActive,
                    icon: const Icon(Icons.print, size: 16),
                    label: const Text('Print All Active', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ..._existing
                  .where((r) => r.status == 'active')
                  .map((r) => Card(
                        margin: const EdgeInsets.only(bottom: 6),
                        child: ListTile(
                          dense: true,
                          title: Text(r.medicationName,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                          subtitle: Text('${r.dosage} • ${r.frequency} • Qty: ${r.quantity}',
                              style: Theme.of(context).textTheme.bodySmall),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.picture_as_pdf_outlined, color: AppTheme.primaryBlue, size: 20),
                                tooltip: 'Print Rx PDF',
                                onPressed: () => _printExisting(r),
                              ),
                              const Icon(Icons.check_circle,
                                  color: AppTheme.accentGreen, size: 18),
                            ],
                          ),
                        ),
                      )),
              const Divider(height: 28),
            ],
            Text('New Medication Order',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            TextFormField(
              controller: _medCtrl,
              decoration: const InputDecoration(
                labelText: 'Medication Name',
                hintText: 'e.g. Amoxicillin, Atorvastatin, Metformin',
                prefixIcon: Icon(Icons.medication),
              ),
              validator: (v) =>
                  v != null && v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _dosageCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Dosage', hintText: 'e.g. 500mg, 10mg'),
                    validator: (v) =>
                        v != null && v.trim().isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _freqCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Frequency', hintText: 'e.g. BID, TID, QD'),
                    validator: (v) =>
                        v != null && v.trim().isEmpty ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _qtyCtrl,
                    decoration: const InputDecoration(labelText: 'Quantity (Pills/ml)'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _refillsCtrl,
                    decoration: const InputDecoration(labelText: 'Refills Permitted'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _startDate,
                  firstDate: DateTime.now().subtract(const Duration(days: 30)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) setState(() => _startDate = picked);
              },
              child: InputDecorator(
                decoration:
                    const InputDecoration(labelText: 'Start Date', prefixIcon: Icon(Icons.calendar_today)),
                child: Text(DateFormat('MMMM dd, yyyy').format(_startDate)),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesCtrl,
              maxLines: 2,
              decoration:
                  const InputDecoration(labelText: 'Instructions / Clinical Notes', hintText: 'Take after meals with water...'),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.save),
                    label: const Text('Save Order'),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _saveAndPrint,
                    icon: const Icon(Icons.print),
                    label: const Text('Save & Print Rx'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
