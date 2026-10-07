import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/routes.dart';
import '../config/theme.dart';
import '../config/constants.dart';
import '../models/doctor.dart';
import '../providers/auth_provider.dart';
import '../services/database_service.dart';
import '../widgets/sidebar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;
  bool _notifications = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _darkMode = prefs.getBool('dark_mode') ?? false;
      _notifications = prefs.getBool('notifications') ?? true;
    });
  }

  Future<void> _toggleDark(bool val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', val);
    setState(() => _darkMode = val);
  }

  void _showEditProfileDialog(Doctor doctor) {
    final fnCtrl = TextEditingController(text: doctor.firstName);
    final lnCtrl = TextEditingController(text: doctor.lastName);
    final specCtrl = TextEditingController(text: doctor.specialty);
    final licCtrl = TextEditingController(text: doctor.licenseNumber);
    final phoneCtrl = TextEditingController(text: doctor.phone);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Physician Profile'),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: fnCtrl,
                          decoration: const InputDecoration(labelText: 'First Name'),
                          validator: (v) => v != null && v.isNotEmpty ? null : 'Required',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: lnCtrl,
                          decoration: const InputDecoration(labelText: 'Last Name'),
                          validator: (v) => v != null && v.isNotEmpty ? null : 'Required',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: specCtrl,
                    decoration: const InputDecoration(labelText: 'Specialty'),
                    validator: (v) => v != null && v.isNotEmpty ? null : 'Required',
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: licCtrl,
                    decoration: const InputDecoration(labelText: 'License Number'),
                    validator: (v) => v != null && v.isNotEmpty ? null : 'Required',
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: phoneCtrl,
                    decoration: const InputDecoration(labelText: 'Clinic Phone'),
                    validator: (v) => v != null && v.isNotEmpty ? null : 'Required',
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final updated = Doctor(
                id: doctor.id,
                firstName: fnCtrl.text.trim(),
                lastName: lnCtrl.text.trim(),
                specialty: specCtrl.text.trim(),
                licenseNumber: licCtrl.text.trim(),
                email: doctor.email,
                phone: phoneCtrl.text.trim(),
                role: doctor.role,
                createdAt: doctor.createdAt,
              );
              final auth = context.read<AuthProvider>();
              final nav = Navigator.of(ctx);
              final messenger = ScaffoldMessenger.of(context);
              await auth.updateDoctor(updated);
              nav.pop();
              if (!mounted) return;
              messenger.showSnackBar(
                const SnackBar(
                  content: Text('Physician profile updated successfully'),
                  backgroundColor: AppTheme.accentGreen,
                ),
              );
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportBackup() async {
    final jsonStr = await DatabaseService.exportDatabaseAsJson();
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clinic Database Backup (JSON)'),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: SelectableText(
              jsonStr,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Clinical data backup exported successfully'),
                  backgroundColor: AppTheme.accentGreen,
                ),
              );
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Future<void> _seedDemoData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset / Seed Demo Data?'),
        content: const Text(
          'This will populate sample patients (Emily Watson, James Miller, Sophia Rodriguez), along with vitals, appointments, and prescriptions for testing.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue),
            child: const Text('Populate Data'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await DatabaseService.seedInitialData(force: true);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Clinical practice demo data populated successfully!'),
          backgroundColor: AppTheme.accentGreen,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final doctor = context.watch<AuthProvider>().currentDoctor;
    return Scaffold(
      appBar: AppBar(title: const Text('Settings & Practice Profile')),
      drawer: const Sidebar(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppTheme.primaryBlue,
                    child: Text(doctor?.initials ?? 'DR',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 18)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Dr. ${doctor?.lastName ?? ''} ${doctor?.firstName ?? ''}',
                            style: Theme.of(context).textTheme.titleMedium),
                        Text(doctor?.specialty ?? 'General Medicine',
                            style: Theme.of(context).textTheme.bodySmall),
                        Text('Lic: ${doctor?.licenseNumber ?? 'N/A'}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary)),
                      ],
                    ),
                  ),
                  if (doctor != null)
                    IconButton(
                      icon: const Icon(Icons.edit, color: AppTheme.primaryBlue),
                      tooltip: 'Edit Profile',
                      onPressed: () => _showEditProfileDialog(doctor),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Practice Data & Backup', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.backup_outlined, color: AppTheme.primaryBlue),
                  title: const Text('Export Clinic EMR Backup'),
                  subtitle: const Text('Export all patient records, vitals & prescriptions as JSON'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _exportBackup,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.auto_fix_high, color: AppTheme.accentGreen),
                  title: const Text('Seed / Reset Clinical Demo Data'),
                  subtitle: const Text('Pre-load realistic patients, consultations and vitals'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _seedDemoData,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('Preferences', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Dark Mode'),
                  subtitle: const Text('Use dark theme'),
                  value: _darkMode,
                  onChanged: _toggleDark,
                  activeThumbColor: AppTheme.primaryBlue,
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Notifications'),
                  subtitle: const Text('Appointment reminders & clinical alerts'),
                  value: _notifications,
                  onChanged: (v) async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('notifications', v);
                    setState(() => _notifications = v);
                  },
                  activeThumbColor: AppTheme.primaryBlue,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Account', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.email_outlined),
                  title: const Text('Email'),
                  subtitle: Text(doctor?.email ?? ''),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.phone),
                  title: const Text('Phone'),
                  subtitle: Text(doctor?.phone ?? ''),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.badge_outlined),
                  title: const Text('License'),
                  subtitle: Text(doctor?.licenseNumber ?? ''),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                context.read<AuthProvider>().logout();
                Navigator.pushReplacementNamed(context, AppRoutes.login);
              },
              icon: const Icon(Icons.logout, color: AppTheme.accentRed),
              label: const Text('Sign Out',
                  style: TextStyle(color: AppTheme.accentRed)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.accentRed),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Dr.Clinic EMR v${AppConstants.version}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
