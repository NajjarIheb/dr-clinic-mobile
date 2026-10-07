class Appointment {
  final String id;
  final String doctorId;
  final String patientId;
  final String patientName;
  final DateTime startTime;
  final DateTime endTime;
  final String status;
  final String reason;
  final String type;

  Appointment({
    required this.id,
    required this.doctorId,
    required this.patientId,
    required this.patientName,
    required this.startTime,
    required this.endTime,
    this.status = 'scheduled',
    this.reason = '',
    this.type = 'in_person',
  });

  String get timeSlot =>
      '${_formatTime(startTime)} - ${_formatTime(endTime)}';

  static String _formatTime(DateTime dt) {
    final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $ampm';
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'doctor_id': doctorId,
    'patient_id': patientId,
    'patient_name': patientName,
    'start_time': startTime.toIso8601String(),
    'end_time': endTime.toIso8601String(),
    'status': status,
    'reason': reason,
    'type': type,
  };

  factory Appointment.fromMap(Map<String, dynamic> map) => Appointment(
    id: map['id'],
    doctorId: map['doctor_id'],
    patientId: map['patient_id'],
    patientName: map['patient_name'],
    startTime: DateTime.parse(map['start_time']),
    endTime: DateTime.parse(map['end_time']),
    status: map['status'] ?? 'scheduled',
    reason: map['reason'] ?? '',
    type: map['type'] ?? 'in_person',
  );

  Appointment copyWith({
    String? id,
    String? doctorId,
    String? patientId,
    String? patientName,
    DateTime? startTime,
    DateTime? endTime,
    String? status,
    String? reason,
    String? type,
  }) {
    return Appointment(
      id: id ?? this.id,
      doctorId: doctorId ?? this.doctorId,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      reason: reason ?? this.reason,
      type: type ?? this.type,
    );
  }
}
