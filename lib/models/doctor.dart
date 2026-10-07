class Doctor {
  final String id;
  final String firstName;
  final String lastName;
  final String specialty;
  final String licenseNumber;
  final String role;
  final String email;
  final String phone;
  final DateTime createdAt;

  Doctor({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.specialty,
    required this.licenseNumber,
    this.role = 'doctor',
    required this.email,
    required this.phone,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  String get fullName => '$firstName $lastName';
  String get initials => '${firstName[0]}${lastName[0]}';

  Map<String, dynamic> toMap() => {
    'id': id,
    'first_name': firstName,
    'last_name': lastName,
    'specialty': specialty,
    'license_number': licenseNumber,
    'role': role,
    'email': email,
    'phone': phone,
    'created_at': createdAt.toIso8601String(),
  };

  factory Doctor.fromMap(Map<String, dynamic> map) => Doctor(
    id: map['id'],
    firstName: map['first_name'],
    lastName: map['last_name'],
    specialty: map['specialty'],
    licenseNumber: map['license_number'],
    role: map['role'] ?? 'doctor',
    email: map['email'],
    phone: map['phone'],
    createdAt: DateTime.parse(map['created_at']),
  );
}
