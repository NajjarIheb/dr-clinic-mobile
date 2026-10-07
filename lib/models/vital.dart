class Vital {
  final String id;
  final String patientId;
  final String? appointmentId;
  final int bloodPressureSys;
  final int bloodPressureDia;
  final int heartRate;
  final double temperature;
  final int respiratoryRate;
  final double weight;
  final double height;
  final double bmi;
  final DateTime recordedAt;

  Vital({
    required this.id,
    required this.patientId,
    this.appointmentId,
    this.bloodPressureSys = 0,
    this.bloodPressureDia = 0,
    this.heartRate = 0,
    this.temperature = 37.0,
    this.respiratoryRate = 0,
    this.weight = 0,
    this.height = 0,
    double? bmi,
    DateTime? recordedAt,
  })  : bmi = bmi ?? (weight > 0 && height > 0
            ? weight / ((height / 100) * (height / 100))
            : 0),
        recordedAt = recordedAt ?? DateTime.now();

  String get bp => '$bloodPressureSys/$bloodPressureDia';

  Map<String, dynamic> toMap() => {
    'id': id,
    'patient_id': patientId,
    'appointment_id': appointmentId,
    'blood_pressure_sys': bloodPressureSys,
    'blood_pressure_dia': bloodPressureDia,
    'heart_rate': heartRate,
    'temperature': temperature,
    'respiratory_rate': respiratoryRate,
    'weight': weight,
    'height': height,
    'bmi': bmi,
    'recorded_at': recordedAt.toIso8601String(),
  };

  factory Vital.fromMap(Map<String, dynamic> map) => Vital(
    id: map['id'],
    patientId: map['patient_id'],
    appointmentId: map['appointment_id'],
    bloodPressureSys: map['blood_pressure_sys'] ?? 0,
    bloodPressureDia: map['blood_pressure_dia'] ?? 0,
    heartRate: map['heart_rate'] ?? 0,
    temperature: (map['temperature'] as num?)?.toDouble() ?? 37.0,
    respiratoryRate: map['respiratory_rate'] ?? 0,
    weight: (map['weight'] as num?)?.toDouble() ?? 0,
    height: (map['height'] as num?)?.toDouble() ?? 0,
    bmi: (map['bmi'] as num?)?.toDouble(),
    recordedAt: DateTime.parse(map['recorded_at']),
  );
}
