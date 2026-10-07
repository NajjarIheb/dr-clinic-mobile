class Patient {
  final String id;
  final String firstName;
  final String lastName;
  final DateTime dob;
  final String gender;
  final String phone;
  final String email;
  final String address;
  final String insuranceProvider;
  final String insuranceId;
  final String bloodType;
  final String allergies;
  final String emergencyContactName;
  final String emergencyContactPhone;
  final DateTime createdAt;

  Patient({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.dob,
    required this.gender,
    required this.phone,
    this.email = '',
    this.address = '',
    this.insuranceProvider = '',
    this.insuranceId = '',
    this.bloodType = '',
    this.allergies = '',
    this.emergencyContactName = '',
    this.emergencyContactPhone = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  String get fullName => '$firstName $lastName';
  int get age => DateTime.now().year - dob.year;
  String get initials => '${firstName[0]}${lastName[0]}';

  Map<String, dynamic> toMap() => {
    'id': id,
    'first_name': firstName,
    'last_name': lastName,
    'dob': dob.toIso8601String(),
    'gender': gender,
    'phone': phone,
    'email': email,
    'address': address,
    'insurance_provider': insuranceProvider,
    'insurance_id': insuranceId,
    'blood_type': bloodType,
    'allergies': allergies,
    'emergency_contact_name': emergencyContactName,
    'emergency_contact_phone': emergencyContactPhone,
    'created_at': createdAt.toIso8601String(),
  };

  factory Patient.fromMap(Map<String, dynamic> map) => Patient(
    id: map['id'],
    firstName: map['first_name'],
    lastName: map['last_name'],
    dob: DateTime.parse(map['dob']),
    gender: map['gender'],
    phone: map['phone'],
    email: map['email'] ?? '',
    address: map['address'] ?? '',
    insuranceProvider: map['insurance_provider'] ?? '',
    insuranceId: map['insurance_id'] ?? '',
    bloodType: map['blood_type'] ?? '',
    allergies: map['allergies'] ?? '',
    emergencyContactName: map['emergency_contact_name'] ?? '',
    emergencyContactPhone: map['emergency_contact_phone'] ?? '',
    createdAt: DateTime.parse(map['created_at']),
  );
}
