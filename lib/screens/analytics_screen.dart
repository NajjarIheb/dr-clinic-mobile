import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../config/theme.dart';
import '../widgets/sidebar.dart';
import '../services/database_service.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  int _patientCount = 0;
  int _todayAppts = 0;
  double _revenue = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final patients = await DatabaseService.getPatientCount();
    final appts = await DatabaseService.getTodayAppointmentCount();
    final revenue = await DatabaseService.getTotalRevenue();
    if (!mounted) return;
    setState(() {
      _patientCount = patients;
      _todayAppts = appts;
      _revenue = revenue;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      drawer: const Sidebar(),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMetricCards(),
                  const SizedBox(height: 24),
                  Text('Revenue Overview',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 220,
                    child: _buildRevenueChart(),
                  ),
                  const SizedBox(height: 24),
                  Text('Patient Distribution',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: _buildPieChart(),
                  ),
                  const SizedBox(height: 24),
                  Text('Quick Stats',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  _buildStatsList(),
                ],
              ),
            ),
    );
  }

  Widget _buildMetricCards() {
    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _metricCard('Total Patients', _patientCount.toString(), Icons.people, AppTheme.primaryBlue),
          _metricCard("Today's Appts", _todayAppts.toString(), Icons.calendar_today, AppTheme.primaryTeal),
          _metricCard('Revenue', '\$${_revenue.toStringAsFixed(0)}', Icons.trending_up, AppTheme.accentGreen),
          _metricCard('Avg/Patient', _patientCount > 0 ? '\$${(_revenue / _patientCount).toStringAsFixed(0)}' : '\$0', Icons.analytics, AppTheme.accentAmber),
        ],
      ),
    );
  }

  Widget _metricCard(String label, String value, IconData icon, Color color) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Icon(icon, size: 18, color: color),
                  const SizedBox(width: 6),
                  Text(label, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
              const SizedBox(height: 6),
              Text(value,
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: color)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRevenueChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: 20000,
            barGroups: List.generate(7, (i) {
              final vals = [12000, 15000, 11000, 18000, 14000, 16500, 13000];
              return BarChartGroupData(x: i, barRods: [
                BarChartRodData(
                  toY: vals[i].toDouble(),
                  color: AppTheme.primaryBlue,
                  width: 20,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ]);
            }),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (val, _) {
                    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                    return Text(days[val.toInt()],
                        style: const TextStyle(fontSize: 10));
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (val, _) =>
                      Text('\$${val.toInt() ~/ 1000}k',
                          style: const TextStyle(fontSize: 10)),
                ),
              ),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 5000,
              getDrawingHorizontalLine: (val) => FlLine(
                color: AppTheme.dividerLight.withValues(alpha: 0.3),
                strokeWidth: 1,
              ),
            ),
            borderData: FlBorderData(show: false),
          ),
        ),
      ),
    );
  }

  Widget _buildPieChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(value: 40, color: AppTheme.primaryBlue, title: 'Cardio', radius: 50),
                    PieChartSectionData(value: 25, color: AppTheme.primaryTeal, title: 'Neuro', radius: 50),
                    PieChartSectionData(value: 20, color: AppTheme.accentGreen, title: 'Ortho', radius: 50),
                    PieChartSectionData(value: 15, color: AppTheme.accentAmber, title: 'Other', radius: 50),
                  ],
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _legendDot('Cardiology', AppTheme.primaryBlue),
                _legendDot('Neurology', AppTheme.primaryTeal),
                _legendDot('Orthopedics', AppTheme.accentGreen),
                _legendDot('Other', AppTheme.accentAmber),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _legendDot(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _buildStatsList() {
    return Card(
      child: Column(
        children: [
          _statTile('Avg Appointment Duration', '22 min'),
          _statTile('No-Show Rate', '8%'),
          _statTile('Insurance Claims Rate', '76%'),
          _statTile('Prescriptions Issued (Month)', '143'),
          _statTile('New Patients (Month)', '28'),
        ],
      ),
    );
  }

  Widget _statTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.w600, color: AppTheme.primaryBlue)),
        ],
      ),
    );
  }
}
