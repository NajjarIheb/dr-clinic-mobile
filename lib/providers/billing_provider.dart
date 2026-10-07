import 'package:flutter/material.dart';
import '../models/billing.dart';
import '../services/database_service.dart';

class BillingProvider extends ChangeNotifier {
  List<Billing> _bills = [];
  bool _isLoading = false;

  List<Billing> get bills => _bills;
  bool get isLoading => _isLoading;

  double get totalRevenue =>
      _bills.fold(0.0, (sum, b) => sum + b.paid);
  double get totalPending =>
      _bills.fold(0.0, (sum, b) => sum + b.balance);
  int get overdueCount =>
      _bills.where((b) => b.isOverdue).length;

  Future<void> loadBilling() async {
    _isLoading = true;
    notifyListeners();
    _bills = await DatabaseService.getAllBilling();
    _isLoading = false;
    notifyListeners();
  }
}
