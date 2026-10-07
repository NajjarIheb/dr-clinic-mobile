import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';
import '../providers/note_provider.dart';

class ClinicalNoteScreen extends StatefulWidget {
  final String patientId;
  final String? appointmentId;
  const ClinicalNoteScreen(
      {super.key, required this.patientId, this.appointmentId});

  @override
  State<ClinicalNoteScreen> createState() => _ClinicalNoteScreenState();
}

class _ClinicalNoteScreenState extends State<ClinicalNoteScreen> {
  final _subjectiveCtrl = TextEditingController();
  final _objectiveCtrl = TextEditingController();
  final _assessmentCtrl = TextEditingController();
  final _planCtrl = TextEditingController();
  final _dxCodeCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _subjectiveCtrl.dispose();
    _objectiveCtrl.dispose();
    _assessmentCtrl.dispose();
    _planCtrl.dispose();
    _dxCodeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SOAP Note'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Save',
                style: TextStyle(color: AppTheme.primaryBlue)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _sectionTitle('S - Subjective'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _subjectiveCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Chief complaint, history of present illness...',
                alignLabelWithHint: true,
              ),
              validator: (v) =>
                  v != null && v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 20),
            _sectionTitle('O - Objective'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _objectiveCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Vitals, exam findings, lab results...',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 20),
            _sectionTitle('A - Assessment'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _assessmentCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Diagnosis, differential...',
                alignLabelWithHint: true,
              ),
              validator: (v) =>
                  v != null && v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 20),
            _sectionTitle('P - Plan'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _planCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Treatment plan, follow-up, referrals...',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 20),
            _sectionTitle('Diagnosis Code (ICD-10)'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _dxCodeCtrl,
              decoration: const InputDecoration(
                hintText: 'e.g. J20.9, I10, E11.9',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title, style: Theme.of(context).textTheme.titleMedium);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final doctor = context.read<AuthProvider>().currentDoctor;
    await context.read<NoteProvider>().saveNote(
          patientId: widget.patientId,
          doctorId: doctor?.id ?? '',
          appointmentId: widget.appointmentId,
          subjective: _subjectiveCtrl.text.trim(),
          objective: _objectiveCtrl.text.trim(),
          assessment: _assessmentCtrl.text.trim(),
          plan: _planCtrl.text.trim(),
          diagnosisCode: _dxCodeCtrl.text.trim(),
        );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Note saved'),
          backgroundColor: AppTheme.accentGreen),
    );
    Navigator.pop(context);
  }
}
