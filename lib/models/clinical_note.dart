class ClinicalNote {
  final String id;
  final String patientId;
  final String doctorId;
  final String? appointmentId;
  final String subjective;
  final String objective;
  final String assessment;
  final String plan;
  final String diagnosisCode;
  final DateTime createdAt;
  final DateTime updatedAt;

  ClinicalNote({
    required this.id,
    required this.patientId,
    required this.doctorId,
    this.appointmentId,
    this.subjective = '',
    this.objective = '',
    this.assessment = '',
    this.plan = '',
    this.diagnosisCode = '',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'id': id,
    'patient_id': patientId,
    'doctor_id': doctorId,
    'appointment_id': appointmentId,
    'subjective': subjective,
    'objective': objective,
    'assessment': assessment,
    'plan': plan,
    'diagnosis_code': diagnosisCode,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  factory ClinicalNote.fromMap(Map<String, dynamic> map) => ClinicalNote(
    id: map['id'],
    patientId: map['patient_id'],
    doctorId: map['doctor_id'],
    appointmentId: map['appointment_id'],
    subjective: map['subjective'] ?? '',
    objective: map['objective'] ?? '',
    assessment: map['assessment'] ?? '',
    plan: map['plan'] ?? '',
    diagnosisCode: map['diagnosis_code'] ?? '',
    createdAt: DateTime.parse(map['created_at']),
    updatedAt: DateTime.parse(map['updated_at']),
  );
}
