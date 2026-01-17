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

  const Bill({
    required this.id,
    required this.createdAt,
    required this.totalAmount,
    required this.items,
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
    );
  }

  @override
  void write(BinaryWriter writer, Bill obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.createdAt)
      ..writeByte(2)
      ..write(obj.totalAmount)
      ..writeByte(3)
      ..write(obj.items);
  }
}
