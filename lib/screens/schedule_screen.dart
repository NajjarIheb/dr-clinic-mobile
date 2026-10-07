import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../config/routes.dart';
import '../config/theme.dart';
import '../providers/appointment_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/sidebar.dart';
import '../widgets/appointment_card.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  CalendarFormat _format = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    final provider = context.read<AppointmentProvider>();
    provider.loadAppointmentsForDate(_focusedDay);
  }

  @override
  Widget build(BuildContext context) {
    final appts = context.watch<AppointmentProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Schedule')),
      drawer: const Sidebar(),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(12),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            child: TableCalendar(
              firstDay: DateTime.now().subtract(const Duration(days: 365)),
              lastDay: DateTime.now().add(const Duration(days: 365)),
              focusedDay: _focusedDay,
              calendarFormat: _format,
              selectedDayPredicate: (day) =>
                  isSameDay(appts.selectedDate, day),
              onFormatChanged: (format) => setState(() => _format = format),
              onDaySelected: (selected, _) {
                appts.setSelectedDate(selected);
                appts.loadAppointmentsForDate(selected);
              },
              onPageChanged: (focused) => _focusedDay = focused,
              calendarStyle: CalendarStyle(
                selectedDecoration: const BoxDecoration(
                  color: AppTheme.primaryBlue,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: true,
                titleCentered: true,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('EEEE, MMM d').format(appts.selectedDate),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '${appts.todayAppointments.length} appointments',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          if (appts.isLoading)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (appts.todayAppointments.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.event_busy,
                        size: 64, color: AppTheme.textSecondary.withValues(alpha: 0.3)),
                    const SizedBox(height: 16),
                    Text('No appointments for this day',
                        style: Theme.of(context).textTheme.bodyLarge),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: appts.todayAppointments.length,
                itemBuilder: (_, i) => AppointmentCard(
                  appointment: appts.todayAppointments[i],
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.patientDetail,
                    arguments: {'patientId': appts.todayAppointments[i].patientId},
                  ),
                  onStatusChange: (s) => appts.updateStatus(
                      appts.todayAppointments[i].id, s),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddAppointmentDialog,
        backgroundColor: AppTheme.primaryBlue,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddAppointmentDialog() {
    final doctor = context.read<AuthProvider>().currentDoctor;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _AddAppointmentSheet(
        doctorId: doctor?.id ?? '',
        onAdd: (start, end, pid, pname, reason) {
          context.read<AppointmentProvider>().addAppointment(
                doctorId: doctor?.id ?? '',
                patientId: pid,
                patientName: pname,
                startTime: start,
                endTime: end,
                reason: reason,
              );
          Navigator.pop(ctx);
        },
      ),
    );
  }
}

class _AddAppointmentSheet extends StatefulWidget {
  final String doctorId;
  final Function(DateTime, DateTime, String, String, String) onAdd;

  const _AddAppointmentSheet(
      {required this.doctorId, required this.onAdd});

  @override
  State<_AddAppointmentSheet> createState() => _AddAppointmentSheetState();
}

class _AddAppointmentSheetState extends State<_AddAppointmentSheet> {
  final _patientIdCtrl = TextEditingController();
  final _patientNameCtrl = TextEditingController();
  final _reasonCtrl = TextEditingController();
  TimeOfDay _start = TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _end = TimeOfDay(hour: 9, minute: 30);

  @override
  void dispose() {
    _patientIdCtrl.dispose();
    _patientNameCtrl.dispose();
    _reasonCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('New Appointment',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          TextField(
              controller: _patientIdCtrl,
              decoration: const InputDecoration(labelText: 'Patient ID')),
          const SizedBox(height: 12),
          TextField(
              controller: _patientNameCtrl,
              decoration: const InputDecoration(labelText: 'Patient Name')),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _TimePicker(label: 'Start', time: _start, onPicked: (t) => setState(() => _start = t)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TimePicker(label: 'End', time: _end, onPicked: (t) => setState(() => _end = t)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
              controller: _reasonCtrl,
              decoration: const InputDecoration(labelText: 'Reason')),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              final now = DateTime.now();
              final start = DateTime(
                  now.year, now.month, now.day, _start.hour, _start.minute);
              final end = DateTime(
                  now.year, now.month, now.day, _end.hour, _end.minute);
              widget.onAdd(start, end, _patientIdCtrl.text.trim(),
                  _patientNameCtrl.text.trim(), _reasonCtrl.text.trim());
            },
            child: const Text('Add Appointment'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _TimePicker extends StatelessWidget {
  final String label;
  final TimeOfDay time;
  final ValueChanged<TimeOfDay> onPicked;

  const _TimePicker(
      {required this.label, required this.time, required this.onPicked});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showTimePicker(context: context, initialTime: time);
        if (picked != null) onPicked(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: Text(time.format(context)),
      ),
    );
  }
}
