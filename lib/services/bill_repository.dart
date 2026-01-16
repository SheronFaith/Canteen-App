import 'package:hive/hive.dart';

import '../models/bill.dart';

class BillRepository {
  static const String billsBoxName = 'bills';

  const BillRepository();

  Box<Bill> get _box => Hive.box<Bill>(billsBoxName);

  Future<void> addBill(Bill bill) async {
    await _box.put(bill.id, bill);
  }

  List<Bill> getAllBills() {
    final bills = _box.values.toList();
    bills.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return bills;
  }
}
