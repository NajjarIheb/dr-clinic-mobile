import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';
import '../providers/billing_provider.dart';
import '../widgets/sidebar.dart';

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  @override
  void initState() {
    super.initState();
    context.read<BillingProvider>().loadBilling();
  }

  @override
  Widget build(BuildContext context) {
    final bp = context.watch<BillingProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Billing')),
      drawer: const Sidebar(),
      body: bp.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildSummaryRow(bp),
                const Divider(height: 1),
                Expanded(
                  child: bp.bills.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.receipt_long,
                                  size: 64,
                                  color: AppTheme.textSecondary.withValues(alpha: 0.3)),
                              const SizedBox(height: 16),
                              Text('No billing records',
                                  style: Theme.of(context).textTheme.bodyLarge),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: bp.bills.length,
                          padding: const EdgeInsets.all(12),
                          itemBuilder: (_, i) {
                            final b = bp.bills[i];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                title: Row(
                                  children: [
                                    Text('\$${b.amount.toStringAsFixed(2)}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium),
                                    const SizedBox(width: 8),
                                    _statusChip(b.status),
                                  ],
                                ),
                                subtitle: Text(
                                  'CPT: ${b.serviceCode}  |  ${DateFormat('MMM dd, yyyy').format(b.invoiceDate)}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                trailing: Text(
                                  'Due: ${DateFormat('MM/dd').format(b.dueDate)}',
                                  style: TextStyle(
                                    color: b.isOverdue
                                        ? AppTheme.accentRed
                                        : AppTheme.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildSummaryRow(BillingProvider bp) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).cardColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _summaryItem('Revenue', '\$${bp.totalRevenue.toStringAsFixed(0)}',
              AppTheme.accentGreen),
          _summaryItem('Pending', '\$${bp.totalPending.toStringAsFixed(0)}',
              AppTheme.accentAmber),
          _summaryItem('Overdue', '${bp.overdueCount}',
              AppTheme.accentRed),
        ],
      ),
    );
  }

  Widget _summaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.w700, color: color)),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _statusChip(String status) {
    final color = status == 'paid'
        ? AppTheme.accentGreen
        : status == 'pending'
            ? AppTheme.accentAmber
            : AppTheme.accentRed;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(status,
          style: TextStyle(fontSize: 12, color: color)),
    );
  }
}
