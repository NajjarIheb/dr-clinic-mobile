import 'package:flutter/material.dart';
import '../screens/dashboard_screen.dart';
import '../screens/login_screen.dart';
import '../screens/schedule_screen.dart';
import '../screens/patient_list_screen.dart';
import '../screens/patient_detail_screen.dart';
import '../screens/clinical_note_screen.dart';
import '../screens/prescription_screen.dart';
import '../screens/billing_screen.dart';
import '../screens/analytics_screen.dart';
import '../screens/settings_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String schedule = '/schedule';
  static const String patients = '/patients';
  static const String patientDetail = '/patient-detail';
  static const String clinicalNote = '/clinical-note';
  static const String prescription = '/prescription';
  static const String billing = '/billing';
  static const String analytics = '/analytics';
  static const String settings = '/settings';

  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case AppRoutes.dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      case AppRoutes.schedule:
        return MaterialPageRoute(builder: (_) => const ScheduleScreen());
      case AppRoutes.patients:
        return MaterialPageRoute(builder: (_) => const PatientListScreen());
      case AppRoutes.patientDetail:
        final args = routeSettings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => PatientDetailScreen(patientId: args['patientId'] as String),
        );
      case AppRoutes.clinicalNote:
        final args = routeSettings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ClinicalNoteScreen(
            patientId: args['patientId'] as String,
            appointmentId: args['appointmentId'] as String?,
          ),
        );
      case AppRoutes.prescription:
        final args = routeSettings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => PrescriptionScreen(patientId: args['patientId'] as String),
        );
      case AppRoutes.billing:
        return MaterialPageRoute(builder: (_) => const BillingScreen());
      case AppRoutes.analytics:
        return MaterialPageRoute(builder: (_) => const AnalyticsScreen());
      case AppRoutes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Route not found')),
          ),
        );
    }
  }
}
