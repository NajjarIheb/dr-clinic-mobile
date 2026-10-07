import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/routes.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';
import '../providers/appointment_provider.dart';
import '../widgets/sidebar.dart';
import '../widgets/stat_card.dart';
import '../widgets/appointment_card.dart';
import '../services/database_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _patientCount = 0;
  int _pendingNotes = 0;
  double _totalRevenue = 0;
  double _pendingRevenue = 0;
  bool _loadingStats = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
    context.read<AppointmentProvider>().loadTodayAppointments();
  }

  Future<void> _loadStats() async {
    final count = await DatabaseService.getPatientCount();
    final notes = await DatabaseService.getPendingNotesCount();
    final revenue = await DatabaseService.getTotalRevenue();
    final pending = await DatabaseService.getPendingRevenue();
    if (!mounted) return;
    setState(() {
      _patientCount = count;
      _pendingNotes = notes;
      _totalRevenue = revenue;
      _pendingRevenue = pending;
      _loadingStats = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final doctor = context.watch<AuthProvider>().currentDoctor;
    final appts = context.watch<AppointmentProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, Dr. ${doctor?.lastName ?? ''}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.settings),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthProvider>().logout();
              Navigator.pushReplacementNamed(context, AppRoutes.login);
            },
          ),
        ],
      ),
      drawer: const Sidebar(),
      body: _loadingStats
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await _loadStats();
                await appts.loadTodayAppointments();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatsRow(),
                    const SizedBox(height: 24),
                    Text("Today's Schedule",
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    if (appts.isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (appts.todayAppointments.isEmpty)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Center(
                            child: Text('No appointments today',
                                style: Theme.of(context).textTheme.bodyLarge),
                          ),
                        ),
                      )
                    else
                      ...appts.todayAppointments.map(
                        (a) => AppointmentCard(
                          appointment: a,
                          onTap: () =>
                              Navigator.pushNamed(context, AppRoutes.patientDetail,
                                  arguments: {'patientId': a.patientId}),
                          onStatusChange: (status) =>
                              appts.updateStatus(a.id, status),
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatsRow() {
    return SizedBox(
      height: 110,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          StatCard(
            title: 'Patients',
            value: '$_patientCount',
            icon: Icons.people_outline,
            color: AppTheme.primaryBlue,
          ),
          StatCard(
            title: 'Pending Notes',
            value: '$_pendingNotes',
            icon: Icons.note_alt_outlined,
            color: AppTheme.accentAmber,
          ),
          StatCard(
            title: 'Revenue',
            value: '\$${_totalRevenue.toStringAsFixed(0)}',
            icon: Icons.attach_money,
            color: AppTheme.accentGreen,
          ),
          StatCard(
            title: 'Outstanding',
            value: '\$${_pendingRevenue.toStringAsFixed(0)}',
            icon: Icons.account_balance_wallet_outlined,
            color: AppTheme.accentRed,
          ),
        ],
      ),
    );
  }
}
