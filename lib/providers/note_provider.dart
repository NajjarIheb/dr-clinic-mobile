import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/clinical_note.dart';
import '../services/database_service.dart';

class NoteProvider extends ChangeNotifier {
  List<ClinicalNote> _notes = [];
  bool _isLoading = false;

  List<ClinicalNote> get notes => _notes;
  bool get isLoading => _isLoading;

  Future<void> loadNotesForPatient(String patientId) async {
    _isLoading = true;
    notifyListeners();
    _notes = await DatabaseService.getNotesForPatient(patientId);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveNote({
    required String patientId,
    required String doctorId,
    String? appointmentId,
    required String subjective,
    required String objective,
    required String assessment,
    required String plan,
    String diagnosisCode = '',
  }) async {
    final note = ClinicalNote(
      id: const Uuid().v4(),
      patientId: patientId,
      doctorId: doctorId,
      appointmentId: appointmentId,
      subjective: subjective,
      objective: objective,
      assessment: assessment,
      plan: plan,
      diagnosisCode: diagnosisCode,
    );
    await DatabaseService.insertNote(note);
    _notes.insert(0, note);
    notifyListeners();
  }

  Future<void> updateNote(ClinicalNote note) async {
    await DatabaseService.updateNote(note);
    final idx = _notes.indexWhere((n) => n.id == note.id);
    if (idx >= 0) {
      _notes[idx] = note;
      notifyListeners();
    }
  }
}
