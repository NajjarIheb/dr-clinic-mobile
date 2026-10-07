import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dr_clinic/widgets/stat_card.dart';
import 'package:dr_clinic/models/patient.dart';
import 'package:dr_clinic/models/vital.dart';
import 'package:dr_clinic/models/prescription.dart';
import 'package:dr_clinic/models/doctor.dart';

void main() {
  group('StatCard Widget Tests', () {
    testWidgets('StatCard displays title, value and icon properly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatCard(
              title: 'Total Patients',
              value: '128',
              icon: Icons.people,
              color: Colors.blue,
            ),
          ),
        ),
      );

      expect(find.text('Total Patients'), findsOneWidget);
      expect(find.text('128'), findsOneWidget);
      expect(find.byIcon(Icons.people), findsOneWidget);
    });
  });

  group('Patient Model Tests', () {
    test('Patient serialization and deserialization works correctly', () {
      final patient = Patient(
        id: 'p-001',
        firstName: 'John',
        lastName: 'Doe',
        phone: '+216 98 123 456',
        email: 'john@example.com',
        gender: 'Male',
        dob: DateTime(1990, 5, 20),
        bloodType: 'O+',
        allergies: 'Penicillin',
        emergencyContactName: 'Jane Doe',
      );

      final map = patient.toMap();
      final restored = Patient.fromMap(map);

      expect(restored.id, 'p-001');
      expect(restored.firstName, 'John');
      expect(restored.lastName, 'Doe');
      expect(restored.fullName, 'John Doe');
      expect(restored.phone, '+216 98 123 456');
      expect(restored.allergies, 'Penicillin');
      expect(restored.bloodType, 'O+');
    });
  });

  group('Vital Model Tests', () {
    test('Vital calculates BMI and formats blood pressure correctly', () {
      final vital = Vital(
        id: 'v-001',
        patientId: 'p-001',
        bloodPressureSys: 120,
        bloodPressureDia: 80,
        heartRate: 72,
        temperature: 36.8,
        weight: 70.0,
        height: 175.0, // 1.75m -> BMI = 70 / (1.75^2) ≈ 22.857
      );

      expect(vital.bp, '120/80');
      expect(vital.bmi, closeTo(22.85, 0.05));

      final map = vital.toMap();
      final restored = Vital.fromMap(map);
      expect(restored.bloodPressureSys, 120);
      expect(restored.bloodPressureDia, 80);
      expect(restored.heartRate, 72);
      expect(restored.weight, 70.0);
    });
  });

  group('Prescription Model Tests', () {
    test('Prescription serialization and status validation', () {
      final now = DateTime.now();
      final rx = Prescription(
        id: 'rx-001',
        patientId: 'p-001',
        doctorId: 'doc-001',
        medicationName: 'Amoxicillin',
        dosage: '500mg',
        frequency: 'TID',
        quantity: 30,
        refills: 1,
        startDate: now,
        notes: 'Take with food',
      );

      expect(rx.medicationName, 'Amoxicillin');
      expect(rx.status, 'active');
      expect(rx.quantity, 30);
      expect(rx.refills, 1);

      final map = rx.toMap();
      final restored = Prescription.fromMap(map);
      expect(restored.medicationName, 'Amoxicillin');
      expect(restored.dosage, '500mg');
    });
  });

  group('Doctor Model Tests', () {
    test('Doctor model formats fullName and initials properly', () {
      final doc = Doctor(
        id: 'doc-001',
        firstName: 'Sarah',
        lastName: 'Chen',
        specialty: 'Cardiology',
        licenseNumber: 'MD-89241',
        email: 'sarah.chen@clinic.com',
        phone: '+1 555-1234',
      );

      expect(doc.fullName, 'Sarah Chen');
      expect(doc.initials, 'SC');

      final map = doc.toMap();
      final restored = Doctor.fromMap(map);
      expect(restored.licenseNumber, 'MD-89241');
      expect(restored.specialty, 'Cardiology');
    });
  });
}
