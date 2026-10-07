import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../config/constants.dart';
import '../models/doctor.dart';
import '../services/database_service.dart';

class AuthProvider extends ChangeNotifier {
  Doctor? _currentDoctor;
  bool _isLoading = false;

  Doctor? get currentDoctor => _currentDoctor;
  bool get isLoggedIn => _currentDoctor != null;
  bool get isLoading => _isLoading;

  Future<void> checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final loggedIn = prefs.getBool(AppConstants.prefLoggedIn) ?? false;
    final doctorId = prefs.getString(AppConstants.prefDoctorId);

    if (loggedIn && doctorId != null) {
      final doc = await DatabaseService.getDoctor(doctorId);
      if (doc != null) {
        _currentDoctor = doc;
      } else {
        // Fallback or seed default
        await DatabaseService.seedInitialData();
        _currentDoctor = await DatabaseService.getDoctor('doc-001') ??
            Doctor(
              id: doctorId,
              firstName: 'Sarah',
              lastName: 'Chen',
              specialty: 'Internal Medicine & Cardiology',
              licenseNumber: 'MD-89241',
              email: 'doctor@clinic.com',
              phone: '+1 (555) 782-4411',
            );
      }
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    // Ensure database has seed data if empty
    await DatabaseService.seedInitialData();
    final doctors = await DatabaseService.getAllDoctors();

    // Check existing registered doctor
    Doctor? foundDoctor;
    for (final doc in doctors) {
      if (doc.email.toLowerCase() == email.trim().toLowerCase()) {
        foundDoctor = doc;
        break;
      }
    }

    // Default demo doctor
    if (foundDoctor == null && email.trim() == 'doctor@clinic.com' && password == 'password') {
      foundDoctor = await DatabaseService.getDoctor('doc-001') ??
          Doctor(
            id: 'doc-001',
            firstName: 'Sarah',
            lastName: 'Chen',
            specialty: 'Internal Medicine & Cardiology',
            licenseNumber: 'MD-89241',
            email: 'doctor@clinic.com',
            phone: '+1 (555) 782-4411',
          );
      await DatabaseService.saveDoctor(foundDoctor);
    }

    if (foundDoctor != null && password.length >= 6) {
      _currentDoctor = foundDoctor;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.prefLoggedIn, true);
      await prefs.setString(AppConstants.prefDoctorId, _currentDoctor!.id);
      _isLoading = false;
      notifyListeners();
      return true;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> register({
    required String firstName,
    required String lastName,
    required String specialty,
    required String licenseNumber,
    required String email,
    required String phone,
  }) async {
    _isLoading = true;
    notifyListeners();

    final newDoc = Doctor(
      id: const Uuid().v4(),
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      specialty: specialty.trim(),
      licenseNumber: licenseNumber.trim(),
      email: email.trim(),
      phone: phone.trim(),
    );

    await DatabaseService.saveDoctor(newDoc);
    _currentDoctor = newDoc;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.prefLoggedIn, true);
    await prefs.setString(AppConstants.prefDoctorId, newDoc.id);

    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<void> updateDoctor(Doctor updated) async {
    _currentDoctor = updated;
    await DatabaseService.saveDoctor(updated);
    notifyListeners();
  }

  Future<void> logout() async {
    _currentDoctor = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.prefLoggedIn, false);
    await prefs.remove(AppConstants.prefDoctorId);
    notifyListeners();
  }
}
