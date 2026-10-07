import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/patient.dart';
import '../services/database_service.dart';

class PatientProvider extends ChangeNotifier {
  List<Patient> _patients = [];
  Patient? _selectedPatient;
  bool _isLoading = false;
  String _searchQuery = '';

  List<Patient> get patients => _patients;
  Patient? get selectedPatient => _selectedPatient;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  List<Patient> get filteredPatients {
    if (_searchQuery.isEmpty) return _patients;
    return _patients.where((p) {
      final q = _searchQuery.toLowerCase();
      return p.firstName.toLowerCase().contains(q) ||
          p.lastName.toLowerCase().contains(q) ||
          p.phone.contains(q);
    }).toList();
  }

  Future<void> loadPatients() async {
    _isLoading = true;
    notifyListeners();
    _patients = await DatabaseService.getAllPatients();
    _isLoading = false;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> selectPatient(String id) async {
    _selectedPatient = await DatabaseService.getPatient(id);
    notifyListeners();
  }

  Future<void> addPatient({
    required String firstName,
    required String lastName,
    required DateTime dob,
    required String gender,
    required String phone,
  }) async {
    final patient = Patient(
      id: const Uuid().v4(),
      firstName: firstName,
      lastName: lastName,
      dob: dob,
      gender: gender,
      phone: phone,
    );
    await DatabaseService.insertPatient(patient);
    _patients.add(patient);
    notifyListeners();
  }
}
