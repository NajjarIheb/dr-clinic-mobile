import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/routes.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final doctor = context.watch<AuthProvider>().currentDoctor;
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: AppTheme.primaryBlue),
            accountName: Text('Dr. ${doctor?.lastName ?? ''} ${doctor?.firstName ?? ''}',
                style: const TextStyle(fontWeight: FontWeight.w600)),
            accountEmail: Text(doctor?.specialty ?? ''),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(doctor?.initials ?? 'DR',
                  style: const TextStyle(
                      color: AppTheme.primaryBlue,
                      fontWeight: FontWeight.w700,
                      fontSize: 20)),
            ),
          ),
          _navItem(context, Icons.dashboard_outlined, 'Dashboard', AppRoutes.dashboard),
          _navItem(context, Icons.calendar_month_outlined, 'Schedule', AppRoutes.schedule),
          _navItem(context, Icons.people_outline, 'Patients', AppRoutes.patients),
          _navItem(context, Icons.receipt_long_outlined, 'Billing', AppRoutes.billing),
          _navItem(context, Icons.analytics_outlined, 'Analytics', AppRoutes.analytics),
          const Spacer(),
          _navItem(context, Icons.settings_outlined, 'Settings', AppRoutes.settings),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _navItem(BuildContext context, IconData icon, String label, String route) {
    final isActive = ModalRoute.of(context)?.settings.name == route;
    return ListTile(
      leading: Icon(icon, color: isActive ? AppTheme.primaryBlue : null),
      title: Text(label,
          style: TextStyle(
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            color: isActive ? AppTheme.primaryBlue : null,
          )),
      selected: isActive,
      onTap: () {
        Navigator.pop(context);
        if (!isActive) {
          Navigator.pushReplacementNamed(context, route);
        }
      },
    );
  }
}
