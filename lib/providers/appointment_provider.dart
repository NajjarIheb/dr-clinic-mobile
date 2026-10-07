import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/appointment.dart';
import '../services/database_service.dart';

class AppointmentProvider extends ChangeNotifier {
  List<Appointment> _todayAppointments = [];
  final List<Appointment> _allAppointments = [];
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  List<Appointment> get todayAppointments => _todayAppointments;
  List<Appointment> get allAppointments => _allAppointments;
  DateTime get selectedDate => _selectedDate;
  bool get isLoading => _isLoading;

  Future<void> loadTodayAppointments() async {
    _isLoading = true;
    notifyListeners();
    _todayAppointments =
        await DatabaseService.getAppointmentsForDate(_selectedDate);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadAppointmentsForDate(DateTime date) async {
    _selectedDate = date;
    _isLoading = true;
    notifyListeners();
    _todayAppointments = await DatabaseService.getAppointmentsForDate(date);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addAppointment({
    required String doctorId,
    required String patientId,
    required String patientName,
    required DateTime startTime,
    required DateTime endTime,
    String reason = '',
    String type = 'in_person',
  }) async {
    final appointment = Appointment(
      id: const Uuid().v4(),
      doctorId: doctorId,
      patientId: patientId,
      patientName: patientName,
      startTime: startTime,
      endTime: endTime,
      reason: reason,
      type: type,
    );
    await DatabaseService.insertAppointment(appointment);
    _todayAppointments.add(appointment);
    notifyListeners();
  }

  Future<void> updateStatus(String id, String status) async {
    await DatabaseService.updateAppointmentStatus(id, status);
    final idx = _todayAppointments.indexWhere((a) => a.id == id);
    if (idx >= 0) {
      _todayAppointments[idx] =
          _todayAppointments[idx].copyWith(status: status);
      notifyListeners();
    }
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }
}
