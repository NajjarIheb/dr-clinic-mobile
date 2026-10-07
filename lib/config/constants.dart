class AppConstants {
  static const String appName = 'Dr.Clinic';
  static const String version = '1.0.0';

  // SharedPreferences keys
  static const String prefLoggedIn = 'is_logged_in';
  static const String prefDoctorId = 'doctor_id';
  static const String prefTheme = 'theme_mode';

  // DB name
  static const String dbName = 'dr_clinic.db';
  static const int dbVersion = 1;

  // Time formats
  static const String dateFormat = 'MMM dd, yyyy';
  static const String timeFormat = 'hh:mm a';
  static const String dateTimeFormat = 'MMM dd, yyyy hh:mm a';

  // Pagination
  static const int pageSize = 20;
}
