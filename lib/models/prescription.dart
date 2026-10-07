class Prescription {
  final String id;
  final String patientId;
  final String doctorId;
  final String medicationName;
  final String dosage;
  final String frequency;
  final String route;
  final int quantity;
  final int refills;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final String notes;
  final DateTime createdAt;

  Prescription({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.medicationName,
    required this.dosage,
    required this.frequency,
    this.route = 'PO',
    required this.quantity,
    this.refills = 0,
    required this.startDate,
    DateTime? endDate,
    this.status = 'active',
    this.notes = '',
    DateTime? createdAt,
  })  : endDate = endDate ?? startDate.add(const Duration(days: 30)),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'id': id,
    'patient_id': patientId,
    'doctor_id': doctorId,
    'medication_name': medicationName,
    'dosage': dosage,
    'frequency': frequency,
    'route': route,
    'quantity': quantity,
    'refills': refills,
    'start_date': startDate.toIso8601String(),
    'end_date': endDate.toIso8601String(),
    'status': status,
    'notes': notes,
    'created_at': createdAt.toIso8601String(),
  };

  factory Prescription.fromMap(Map<String, dynamic> map) => Prescription(
    id: map['id'],
    patientId: map['patient_id'],
    doctorId: map['doctor_id'],
    medicationName: map['medication_name'],
    dosage: map['dosage'],
    frequency: map['frequency'],
    route: map['route'] ?? 'PO',
    quantity: map['quantity'],
    refills: map['refills'] ?? 0,
    startDate: DateTime.parse(map['start_date']),
    endDate: DateTime.parse(map['end_date']),
    status: map['status'] ?? 'active',
    notes: map['notes'] ?? '',
    createdAt: DateTime.parse(map['created_at']),
  );
}
