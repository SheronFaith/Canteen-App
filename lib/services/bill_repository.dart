import 'package:hive/hive.dart';

import '../models/bill.dart';

class BillRepository {
  static const String billsBoxName = 'bills';

  const BillRepository();

  Box<Bill> get _box => Hive.box<Bill>(billsBoxName);

  Future<void> addBill(Bill bill) async {
    await _box.put(bill.id, bill);
  }

  /// Returns the next bill number for the provided time.
  ///
  /// - Sequence starts from 1 and increments for bills within the same local day.
  /// - Resets at local midnight.
  /// - Prefix uses a day "secret code":
  ///   Monday=t, Tuesday=h, Wednesday=a, Thursday=r, Friday=u, Saturday=n, Sunday=j.
  String getNextBillNo(DateTime now) {
    final localNow = now.toLocal();
    final start = DateTime(localNow.year, localNow.month, localNow.day);
    final end = start.add(const Duration(days: 1));

    final countForDay = _box.values.where((bill) {
      final created = bill.createdAt.toLocal();
      return !created.isBefore(start) && created.isBefore(end);
    }).length;

    final seq = countForDay + 1;
    return '${_dayCode(localNow)}$seq';
  }

  String _dayCode(DateTime localNow) {
    switch (localNow.weekday) {
      case DateTime.monday:
        return 't';
      case DateTime.tuesday:
        return 'h';
      case DateTime.wednesday:
        return 'a';
      case DateTime.thursday:
        return 'r';
      case DateTime.friday:
        return 'u';
      case DateTime.saturday:
        return 'n';
      case DateTime.sunday:
        return 'j';
      default:
        return 't';
    }
  }

  List<Bill> getAllBills() {
    final bills = _box.values.toList();
    bills.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return bills;
  }
}
