import 'dart:math' as math;

import 'package:intl/intl.dart';

import '../models/bill.dart';
import '../models/bill_item.dart';
import 'bill_repository.dart';

class RevenueService {
  RevenueService({BillRepository? repository})
      : _repository = repository ?? const BillRepository();

  final BillRepository _repository;

  Map<String, Map<String, dynamic>> buildPeriodData({DateTime? now}) {
    final current = now ?? DateTime.now();

    final todayStart = DateTime(current.year, current.month, current.day);
    final weekStart = todayStart.subtract(Duration(days: current.weekday - 1));
    final monthStart = DateTime(current.year, current.month, 1);

    final bills = _repository.getAllBills();

    return {
      'Today': _computeForRange(
        bills: bills,
        rangeStart: todayStart,
        rangeEnd: current,
      ),
      'This Week': _computeForRange(
        bills: bills,
        rangeStart: weekStart,
        rangeEnd: current,
      ),
      'This Month': _computeForRange(
        bills: bills,
        rangeStart: monthStart,
        rangeEnd: current,
      ),
    };
  }

  Map<String, dynamic> emptyPeriodData() => {
        'revenue': _formatCurrency(0, decimals: 0),
        'orders': 0,
        'avgOrderValue': _formatCurrency(0, decimals: 2),
        'totalItemsSold': 0,
        'itemsSold': <Map<String, dynamic>>[],
      };

  Map<String, dynamic> _computeForRange({
    required List<Bill> bills,
    required DateTime rangeStart,
    required DateTime rangeEnd,
  }) {
    final inRange = bills.where((b) {
      final t = b.createdAt;
      return !t.isBefore(rangeStart) && !t.isAfter(rangeEnd);
    }).toList();

    final orders = inRange.length;

    double totalRevenue = 0.0;
    int totalItemsSold = 0;

    final Map<String, _TopItemAgg> byName = {};

    for (final bill in inRange) {
      totalRevenue += bill.totalAmount;
      for (final BillItem item in bill.items) {
        totalItemsSold += item.qty;
        final key = item.itemNameSnapshot;
        final agg = byName.putIfAbsent(key, () => _TopItemAgg());
        agg.qty += item.qty;
        agg.amount += item.lineTotal;
      }
    }

    final avgOrderValue = orders == 0 ? 0.0 : totalRevenue / orders;

    final topItems = byName.entries
        .map(
          (e) => {
            'name': e.key,
            'quantity': e.value.qty,
            'revenue': _formatCurrency(e.value.amount, decimals: 0),
          },
        )
        .toList()
      ..sort((a, b) {
        final qtyA = a['quantity'] as int;
        final qtyB = b['quantity'] as int;
        if (qtyA != qtyB) return qtyB.compareTo(qtyA);
        final amtA = _parseCurrency(a['revenue'] as String);
        final amtB = _parseCurrency(b['revenue'] as String);
        return amtB.compareTo(amtA);
      });

    final top10 = topItems.take(math.min(10, topItems.length)).toList();

    return {
      'revenue': _formatCurrency(totalRevenue, decimals: 0),
      'orders': orders,
      'avgOrderValue': _formatCurrency(avgOrderValue, decimals: 2),
      'totalItemsSold': totalItemsSold,
      'itemsSold': top10,
    };
  }

  String _formatCurrency(num value, {required int decimals}) {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: decimals,
    );
    return formatter.format(value);
  }

  double _parseCurrency(String formatted) {
    // Best-effort fallback used only for tie-break sorting.
    final digits = formatted.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(digits) ?? 0.0;
  }
}

class _TopItemAgg {
  int qty = 0;
  double amount = 0.0;
}
