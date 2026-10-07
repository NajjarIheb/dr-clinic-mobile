import 'package:flutter/material.dart';
import '../models/appointment.dart';
import '../config/theme.dart';

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback onTap;
  final ValueChanged<String>? onStatusChange;

  const AppointmentCard({
    super.key,
    required this.appointment,
    required this.onTap,
    this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    final statusColors = {
      'scheduled': AppTheme.primaryBlue,
      'checked_in': AppTheme.accentAmber,
      'in_progress': AppTheme.primaryTeal,
      'completed': AppTheme.accentGreen,
      'no_show': AppTheme.accentRed,
      'cancelled': AppTheme.textSecondary,
    };

    final color = statusColors[appointment.status] ?? AppTheme.textSecondary;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 48,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(appointment.patientName,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 14, color: AppTheme.textSecondary),
                      const SizedBox(width: 4),
                      Text(appointment.timeSlot,
                          style: Theme.of(context).textTheme.bodySmall),
                      if (appointment.reason.isNotEmpty) ...[
                        const SizedBox(width: 12),
                        Icon(Icons.info_outline, size: 14, color: AppTheme.textSecondary),
                        const SizedBox(width: 4),
                        Text(appointment.reason,
                            style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ],
                  ),
                ],
              ),
              const Spacer(),
              if (onStatusChange != null)
                PopupMenuButton<String>(
                  icon: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(appointment.status.replaceAll('_', ' '),
                        style: TextStyle(fontSize: 11, color: color)),
                  ),
                  onSelected: onStatusChange,
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'checked_in', child: Text('Check In')),
                    const PopupMenuItem(value: 'in_progress', child: Text('In Progress')),
                    const PopupMenuItem(value: 'completed', child: Text('Complete')),
                    const PopupMenuItem(value: 'no_show', child: Text('No Show')),
                    const PopupMenuItem(value: 'cancelled', child: Text('Cancel')),
                  ],
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(appointment.status.replaceAll('_', ' '),
                      style: TextStyle(fontSize: 11, color: color)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
