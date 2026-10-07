class Billing {
  final String id;
  final String patientId;
  final String appointmentId;
  final String doctorId;
  final String serviceCode;
  final double amount;
  final double paid;
  final String status;
  final bool insuranceClaimed;
  final DateTime invoiceDate;
  final DateTime dueDate;
  final String paymentMethod;

  Billing({
    required this.id,
    required this.patientId,
    required this.appointmentId,
    required this.doctorId,
    this.serviceCode = '',
    required this.amount,
    this.paid = 0,
    this.status = 'pending',
    this.insuranceClaimed = false,
    DateTime? invoiceDate,
    DateTime? dueDate,
    this.paymentMethod = '',
  })  : invoiceDate = invoiceDate ?? DateTime.now(),
        dueDate = dueDate ?? DateTime.now().add(const Duration(days: 30));

  double get balance => amount - paid;
  bool get isOverdue => dueDate.isBefore(DateTime.now()) && balance > 0;

  Map<String, dynamic> toMap() => {
    'id': id,
    'patient_id': patientId,
    'appointment_id': appointmentId,
    'doctor_id': doctorId,
    'service_code': serviceCode,
    'amount': amount,
    'paid': paid,
    'status': status,
    'insurance_claimed': insuranceClaimed ? 1 : 0,
    'invoice_date': invoiceDate.toIso8601String(),
    'due_date': dueDate.toIso8601String(),
    'payment_method': paymentMethod,
  };

  factory Billing.fromMap(Map<String, dynamic> map) => Billing(
    id: map['id'],
    patientId: map['patient_id'],
    appointmentId: map['appointment_id'],
    doctorId: map['doctor_id'],
    serviceCode: map['service_code'] ?? '',
    amount: (map['amount'] as num).toDouble(),
    paid: (map['paid'] as num?)?.toDouble() ?? 0,
    status: map['status'] ?? 'pending',
    insuranceClaimed: map['insurance_claimed'] == 1,
    invoiceDate: DateTime.parse(map['invoice_date']),
    dueDate: DateTime.parse(map['due_date']),
    paymentMethod: map['payment_method'] ?? '',
  );
}
