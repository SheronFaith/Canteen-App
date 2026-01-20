import 'package:hive/hive.dart';

import 'bill_item.dart';

@HiveType(typeId: 2)
class Bill {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime createdAt;

  @HiveField(2)
  final double totalAmount;

  @HiveField(3)
  final List<BillItem> items;

  /// Human-friendly bill number printed on receipt, e.g. "t1".
  ///
  /// This is generated per-day and resets at local midnight.
  @HiveField(4)
  final String? billNo;

  const Bill({
    required this.id,
    required this.createdAt,
    required this.totalAmount,
    required this.items,
    this.billNo,
  });
}

/// Manual adapter (so we don't require build_runner in this repo).
class BillAdapter extends TypeAdapter<Bill> {
  @override
  final int typeId = 2;

  @override
  Bill read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return Bill(
      id: fields[0] as String,
      createdAt: fields[1] as DateTime,
      totalAmount: fields[2] as double,
      items: (fields[3] as List).cast<BillItem>(),
      billNo: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Bill obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.createdAt)
      ..writeByte(2)
      ..write(obj.totalAmount)
      ..writeByte(3)
      ..write(obj.items)
      ..writeByte(4)
      ..write(obj.billNo);
  }
}
