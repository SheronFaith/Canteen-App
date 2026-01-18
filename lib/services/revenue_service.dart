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

  /// Builds period totals (day/week/month) for a specific [anchorDate].
  ///
  /// Unlike [buildPeriodData], this treats the periods as full day/week/month
  /// windows based on [anchorDate] (useful for historical reporting).
  Map<String, Map<String, dynamic>> buildPeriodDataForAnchor(
      DateTime anchorDate) {
    final startOfDay =
        DateTime(anchorDate.year, anchorDate.month, anchorDate.day);
    final endOfDay = startOfDay
        .add(const Duration(days: 1))
        .subtract(const Duration(microseconds: 1));

    final weekStart =
        startOfDay.subtract(Duration(days: startOfDay.weekday - 1));
    final weekEnd = weekStart
        .add(const Duration(days: 7))
        .subtract(const Duration(microseconds: 1));

    final monthStart = DateTime(anchorDate.year, anchorDate.month, 1);
    final nextMonthStart = (anchorDate.month == 12)
        ? DateTime(anchorDate.year + 1, 1, 1)
        : DateTime(anchorDate.year, anchorDate.month + 1, 1);
    final monthEnd = nextMonthStart.subtract(const Duration(microseconds: 1));

    final bills = _repository.getAllBills();

    return {
      'Today': _computeForRange(
        bills: bills,
        rangeStart: startOfDay,
        rangeEnd: endOfDay,
      ),
      'This Week': _computeForRange(
        bills: bills,
        rangeStart: weekStart,
        rangeEnd: weekEnd,
      ),
      'This Month': _computeForRange(
        bills: bills,
        rangeStart: monthStart,
        rangeEnd: monthEnd,
      ),
    };
  }

  /// Returns totals grouped by month (descending), optionally limited to the
  /// latest [limit] months.
  List<Map<String, dynamic>> buildMonthlyTotals({int? limit}) {
    final bills = _repository.getAllBills();

    final Map<String, _MonthAgg> byMonth = {};
    for (final bill in bills) {
      final d = bill.createdAt;
      final key = '${d.year}-${d.month.toString().padLeft(2, '0')}';
      final agg = byMonth.putIfAbsent(
          key, () => _MonthAgg(year: d.year, month: d.month));
      agg.orders += 1;
      agg.revenue += bill.totalAmount;
    }

    final rows = byMonth.values.toList()
      ..sort((a, b) {
        final aKey = a.year * 100 + a.month;
        final bKey = b.year * 100 + b.month;
        return bKey.compareTo(aKey);
      });

    final formatter = DateFormat('MMM yyyy');
    final mapped = rows
        .map(
          (m) => {
            'month': formatter.format(DateTime(m.year, m.month, 1)),
            'revenue': _formatCurrency(m.revenue, decimals: 0),
            'orders': m.orders,
          },
        )
        .toList();

    if (limit != null && limit > 0 && mapped.length > limit) {
      return mapped.take(limit).toList();
    }
    return mapped;
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

class _MonthAgg {
  _MonthAgg({required this.year, required this.month});

  final int year;
  final int month;
  int orders = 0;
  double revenue = 0.0;
}
