import 'dart:convert';
import 'package:hive/hive.dart';
import '../models/patient.dart';
import '../models/appointment.dart';
import '../models/clinical_note.dart';
import '../models/prescription.dart';
import '../models/billing.dart';
import '../models/vital.dart';
import '../models/doctor.dart';

class DatabaseService {
  static const _boxName = 'dr_clinic';
  static Box<String>? _box;

  static Future<Box<String>> get box async {
    if (_box != null && _box!.isOpen) return _box!;
    _box = await Hive.openBox<String>(_boxName);
    return _box!;
  }

  // ========== Generic helpers ==========

  static Future<List<Map<String, dynamic>>> _getList(String key) async {
    final b = await box;
    final raw = b.get(key);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List;
    return list.cast<Map<String, dynamic>>();
  }

  static Future<void> _setList(
      String key, List<Map<String, dynamic>> items) async {
    final b = await box;
    await b.put(key, jsonEncode(items));
  }

  // ========== Doctors ==========

  static Future<List<Doctor>> getAllDoctors() async {
    final data = await _getList('doctors');
    return data.map((m) => Doctor.fromMap(m)).toList();
  }

  static Future<Doctor?> getDoctor(String id) async {
    final data = await _getList('doctors');
    final map = data.where((m) => m['id'] == id).firstOrNull;
    return map != null ? Doctor.fromMap(map) : null;
  }

  static Future<void> saveDoctor(Doctor doctor) async {
    final data = await _getList('doctors');
    data.removeWhere((m) => m['id'] == doctor.id);
    data.add(doctor.toMap());
    await _setList('doctors', data);
  }

  // ========== Patients ==========

  static Future<List<Patient>> getAllPatients() async {
    final data = await _getList('patients');
    data.sort((a, b) =>
        (a['first_name'] as String).compareTo(b['first_name'] as String));
    return data.map((m) => Patient.fromMap(m)).toList();
  }

  static Future<List<Patient>> searchPatients(String query) async {
    final all = await getAllPatients();
    final q = query.toLowerCase();
    return all.where((p) =>
        p.firstName.toLowerCase().contains(q) ||
        p.lastName.toLowerCase().contains(q) ||
        p.phone.contains(q)).toList();
  }

  static Future<Patient?> getPatient(String id) async {
    final data = await _getList('patients');
    final map = data.where((m) => m['id'] == id).firstOrNull;
    return map != null ? Patient.fromMap(map) : null;
  }

  static Future<void> insertPatient(Patient patient) async {
    final data = await _getList('patients');
    data.removeWhere((m) => m['id'] == patient.id);
    data.add(patient.toMap());
    await _setList('patients', data);
  }

  // ========== Appointments ==========

  static Future<List<Appointment>> _getAllAppointments() async {
    final data = await _getList('appointments');
    return data.map((m) => Appointment.fromMap(m)).toList();
  }

  static Future<List<Appointment>> getAppointmentsForDate(DateTime date) async {
    final all = await _getAllAppointments();
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return all
        .where((a) =>
            a.startTime.isAfter(start.subtract(const Duration(seconds: 1))) &&
            a.startTime.isBefore(end))
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  static Future<List<Appointment>> getAppointmentsForDoctor(
      String doctorId, DateTime date) async {
    final all = await _getAllAppointments();
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return all
        .where((a) =>
            a.doctorId == doctorId &&
            a.startTime.isAfter(start.subtract(const Duration(seconds: 1))) &&
            a.startTime.isBefore(end))
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  static Future<void> insertAppointment(Appointment appointment) async {
    final data = await _getList('appointments');
    data.removeWhere((m) => m['id'] == appointment.id);
    data.add(appointment.toMap());
    await _setList('appointments', data);
  }

  static Future<void> updateAppointmentStatus(
      String id, String status) async {
    final data = await _getList('appointments');
    final idx = data.indexWhere((m) => m['id'] == id);
    if (idx >= 0) {
      data[idx]['status'] = status;
      await _setList('appointments', data);
    }
  }

  // ========== Clinical Notes ==========

  static Future<List<ClinicalNote>> getNotesForPatient(String patientId) async {
    final data = await _getList('clinical_notes');
    return data
        .where((m) => m['patient_id'] == patientId)
        .map((m) => ClinicalNote.fromMap(m))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  static Future<void> insertNote(ClinicalNote note) async {
    final data = await _getList('clinical_notes');
    data.removeWhere((m) => m['id'] == note.id);
    data.add(note.toMap());
    await _setList('clinical_notes', data);
  }

  static Future<void> updateNote(ClinicalNote note) async {
    final data = await _getList('clinical_notes');
    final idx = data.indexWhere((m) => m['id'] == note.id);
    if (idx >= 0) {
      data[idx] = note.toMap();
      await _setList('clinical_notes', data);
    }
  }

  // ========== Prescriptions ==========

  static Future<List<Prescription>> getPrescriptionsForPatient(
      String patientId) async {
    final data = await _getList('prescriptions');
    return data
        .where((m) => m['patient_id'] == patientId)
        .map((m) => Prescription.fromMap(m))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  static Future<void> insertPrescription(Prescription prescription) async {
    final data = await _getList('prescriptions');
    data.removeWhere((m) => m['id'] == prescription.id);
    data.add(prescription.toMap());
    await _setList('prescriptions', data);
  }

  // ========== Billing ==========

  static Future<List<Billing>> getAllBilling() async {
    final data = await _getList('billing');
    return data
        .map((m) => Billing.fromMap(m))
        .toList()
      ..sort((a, b) => b.invoiceDate.compareTo(a.invoiceDate));
  }

  static Future<List<Billing>> getBillingForPatient(String patientId) async {
    final data = await _getList('billing');
    return data
        .where((m) => m['patient_id'] == patientId)
        .map((m) => Billing.fromMap(m))
        .toList()
      ..sort((a, b) => b.invoiceDate.compareTo(a.invoiceDate));
  }

  static Future<void> insertBilling(Billing billing) async {
    final data = await _getList('billing');
    data.removeWhere((m) => m['id'] == billing.id);
    data.add(billing.toMap());
    await _setList('billing', data);
  }

  static Future<void> updateBillingStatus(String id, String status) async {
    final data = await _getList('billing');
    final idx = data.indexWhere((m) => m['id'] == id);
    if (idx >= 0) {
      data[idx]['status'] = status;
      await _setList('billing', data);
    }
  }

  // ========== Vitals ==========

  static Future<List<Vital>> getVitalsForPatient(String patientId) async {
    final data = await _getList('vitals');
    return data
        .where((m) => m['patient_id'] == patientId)
        .map((m) => Vital.fromMap(m))
        .toList()
      ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
  }

  static Future<void> insertVital(Vital vital) async {
    final data = await _getList('vitals');
    data.removeWhere((m) => m['id'] == vital.id);
    data.add(vital.toMap());
    await _setList('vitals', data);
  }

  // ========== Analytics ==========

  static Future<int> getPatientCount() async {
    final data = await _getList('patients');
    return data.length;
  }

  static Future<int> getTodayAppointmentCount() async {
    final all = await _getAllAppointments();
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    return all.where((a) =>
        a.startTime.isAfter(start.subtract(const Duration(seconds: 1))) &&
        a.startTime.isBefore(end)).length;
  }

  static Future<double> getTotalRevenue() async {
    final data = await _getList('billing');
    double total = 0;
    for (final m in data) {
      total += (m['paid'] as num?)?.toDouble() ?? 0;
    }
    return total;
  }

  static Future<double> getPendingRevenue() async {
    final data = await _getList('billing');
    double total = 0;
    for (final m in data) {
      if (m['status'] == 'paid') continue;
      final amount = (m['amount'] as num?)?.toDouble() ?? 0;
      final paid = (m['paid'] as num?)?.toDouble() ?? 0;
      total += amount - paid;
    }
    return total;
  }

  static Future<int> getPendingNotesCount() async {
    final data = await _getList('clinical_notes');
    return data.where((m) {
      final assessment = m['assessment'] as String?;
      return assessment == null || assessment.isEmpty;
    }).length;
  }

  // ========== Backup & Seed Clinical Data ==========

  static Future<String> exportDatabaseAsJson() async {
    final map = <String, dynamic>{
      'version': '1.0',
      'exported_at': DateTime.now().toIso8601String(),
      'patients': await _getList('patients'),
      'appointments': await _getList('appointments'),
      'clinical_notes': await _getList('clinical_notes'),
      'prescriptions': await _getList('prescriptions'),
      'billing': await _getList('billing'),
      'vitals': await _getList('vitals'),
      'doctors': await _getList('doctors'),
    };
    return const JsonEncoder.withIndent('  ').convert(map);
  }

  static Future<void> importDatabaseFromJson(String jsonStr) async {
    final map = jsonDecode(jsonStr) as Map<String, dynamic>;
    if (map['patients'] is List) {
      await _setList('patients', (map['patients'] as List).cast<Map<String, dynamic>>());
    }
    if (map['appointments'] is List) {
      await _setList('appointments', (map['appointments'] as List).cast<Map<String, dynamic>>());
    }
    if (map['clinical_notes'] is List) {
      await _setList('clinical_notes', (map['clinical_notes'] as List).cast<Map<String, dynamic>>());
    }
    if (map['prescriptions'] is List) {
      await _setList('prescriptions', (map['prescriptions'] as List).cast<Map<String, dynamic>>());
    }
    if (map['billing'] is List) {
      await _setList('billing', (map['billing'] as List).cast<Map<String, dynamic>>());
    }
    if (map['vitals'] is List) {
      await _setList('vitals', (map['vitals'] as List).cast<Map<String, dynamic>>());
    }
    if (map['doctors'] is List) {
      await _setList('doctors', (map['doctors'] as List).cast<Map<String, dynamic>>());
    }
  }

  static Future<void> seedInitialData({bool force = false}) async {
    final currentPatients = await getAllPatients();
    if (currentPatients.isNotEmpty && !force) return;

    final doc = Doctor(
      id: 'doc-001',
      firstName: 'Sarah',
      lastName: 'Chen',
      specialty: 'Internal Medicine & Cardiology',
      licenseNumber: 'MD-89241',
      email: 'doctor@clinic.com',
      phone: '+1 (555) 782-4411',
    );
    await saveDoctor(doc);

    final p1 = Patient(
      id: 'p-101',
      firstName: 'Emily',
      lastName: 'Watson',
      phone: '+1 (555) 234-5678',
      email: 'emily.w@example.com',
      gender: 'Female',
      dob: DateTime(1988, 4, 12),
      bloodType: 'A+',
      allergies: 'Penicillin, Shellfish',
      insuranceProvider: 'BlueCross Health',
      emergencyContactName: 'Mark Watson',
      emergencyContactPhone: '+1 (555) 234-5679',
    );

    final p2 = Patient(
      id: 'p-102',
      firstName: 'James',
      lastName: 'Miller',
      phone: '+1 (555) 345-6789',
      email: 'james.m@example.com',
      gender: 'Male',
      dob: DateTime(1975, 9, 23),
      bloodType: 'O+',
      allergies: 'None',
      insuranceProvider: 'Aetna Platinum',
      emergencyContactName: 'Karen Miller',
      emergencyContactPhone: '+1 (555) 345-6780',
    );

    final p3 = Patient(
      id: 'p-103',
      firstName: 'Sophia',
      lastName: 'Rodriguez',
      phone: '+1 (555) 456-7890',
      email: 'sophia.r@example.com',
      gender: 'Female',
      dob: DateTime(1995, 11, 5),
      bloodType: 'B+',
      allergies: 'Sulfa drugs',
      insuranceProvider: 'United Healthcare',
      emergencyContactName: 'Mateo Rodriguez',
      emergencyContactPhone: '+1 (555) 456-7891',
    );

    await insertPatient(p1);
    await insertPatient(p2);
    await insertPatient(p3);

    // Initial Vitals
    await insertVital(Vital(
      id: 'v-001',
      patientId: p1.id,
      bloodPressureSys: 122,
      bloodPressureDia: 78,
      heartRate: 72,
      temperature: 36.8,
      respiratoryRate: 16,
      weight: 64.5,
      height: 168.0,
      recordedAt: DateTime.now().subtract(const Duration(days: 2)),
    ));

    await insertVital(Vital(
      id: 'v-002',
      patientId: p2.id,
      bloodPressureSys: 135,
      bloodPressureDia: 85,
      heartRate: 80,
      temperature: 37.1,
      respiratoryRate: 18,
      weight: 84.0,
      height: 180.0,
      recordedAt: DateTime.now().subtract(const Duration(days: 1)),
    ));

    // Initial Prescriptions
    await insertPrescription(Prescription(
      id: 'rx-001',
      patientId: p1.id,
      doctorId: doc.id,
      medicationName: 'Amoxicillin Trihydrate',
      dosage: '500mg',
      frequency: 'TID (3 times daily)',
      quantity: 30,
      refills: 1,
      startDate: DateTime.now(),
      notes: 'Take with food. Complete the full 10-day course.',
    ));

    await insertPrescription(Prescription(
      id: 'rx-002',
      patientId: p2.id,
      doctorId: doc.id,
      medicationName: 'Lisinopril',
      dosage: '10mg',
      frequency: 'QD (Once daily in the morning)',
      quantity: 90,
      refills: 3,
      startDate: DateTime.now(),
      notes: 'Monitor blood pressure weekly. Report any persistent dry cough.',
    ));

    // Initial Clinical Notes
    await insertNote(ClinicalNote(
      id: 'note-001',
      patientId: p1.id,
      doctorId: doc.id,
      subjective: 'Patient reports mild sinus pressure and sore throat for 4 days.',
      objective: 'Erythematous posterior pharynx without exudate. Tympanic membranes clear bilaterally.',
      assessment: 'Acute upper respiratory infection, non-streptococcal.',
      plan: 'Hydration, rest, symptom management. Return if symptoms worsen after 5 days.',
      diagnosisCode: 'J06.9',
    ));

    await insertNote(ClinicalNote(
      id: 'note-002',
      patientId: p2.id,
      doctorId: doc.id,
      subjective: 'Routine hypertension follow-up. Reports occasional headaches in the evenings.',
      objective: 'BP 135/85 mmHg, pulse regular at 80 bpm. Heart sounds S1/S2 normal without murmurs.',
      assessment: 'Stage 1 Essential Hypertension, moderately controlled.',
      plan: 'Continue Lisinopril 10mg daily. Recommend reduced sodium diet and 30 min daily walking.',
      diagnosisCode: 'I10',
    ));

    // Initial Appointments
    final now = DateTime.now();
    await insertAppointment(Appointment(
      id: 'apt-001',
      patientId: p1.id,
      patientName: p1.fullName,
      doctorId: doc.id,
      startTime: DateTime(now.year, now.month, now.day, 9, 30),
      endTime: DateTime(now.year, now.month, now.day, 10, 0),
      type: 'Follow-up',
      status: 'scheduled',
      reason: 'Sinus follow-up check',
    ));

    await insertAppointment(Appointment(
      id: 'apt-002',
      patientId: p2.id,
      patientName: p2.fullName,
      doctorId: doc.id,
      startTime: DateTime(now.year, now.month, now.day, 11, 0),
      endTime: DateTime(now.year, now.month, now.day, 11, 45),
      type: 'Consultation',
      status: 'scheduled',
      reason: 'Cardiovascular checkup',
    ));

    // Initial Billing
    await insertBilling(Billing(
      id: 'bill-001',
      patientId: p1.id,
      appointmentId: 'apt-001',
      doctorId: doc.id,
      amount: 150.0,
      paid: 150.0,
      status: 'paid',
      serviceCode: '99213',
      invoiceDate: DateTime.now().subtract(const Duration(days: 2)),
      dueDate: DateTime.now().add(const Duration(days: 28)),
    ));

    await insertBilling(Billing(
      id: 'bill-002',
      patientId: p2.id,
      appointmentId: 'apt-002',
      doctorId: doc.id,
      amount: 220.0,
      paid: 50.0,
      status: 'pending',
      serviceCode: '99214',
      invoiceDate: DateTime.now().subtract(const Duration(days: 1)),
      dueDate: DateTime.now().add(const Duration(days: 14)),
    ));
  }
}
