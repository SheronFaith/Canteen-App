import 'package:hive/hive.dart';

@HiveType(typeId: 1)
class BillItem {
  @HiveField(0)
  final String itemId;

  @HiveField(1)
  final String itemNameSnapshot;

  @HiveField(2)
  final double unitPriceSnapshot;

  @HiveField(3)
  final int qty;

  @HiveField(4)
  final double lineTotal;

  const BillItem({
    required this.itemId,
    required this.itemNameSnapshot,
    required this.unitPriceSnapshot,
    required this.qty,
    required this.lineTotal,
  });
}

/// Manual adapter (so we don't require build_runner in this repo).
class BillItemAdapter extends TypeAdapter<BillItem> {
  @override
  final int typeId = 1;

  @override
  BillItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return BillItem(
      itemId: fields[0] as String,
      itemNameSnapshot: fields[1] as String,
      unitPriceSnapshot: fields[2] as double,
      qty: fields[3] as int,
      lineTotal: fields[4] as double,
    );
  }

  @override
  void write(BinaryWriter writer, BillItem obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.itemId)
      ..writeByte(1)
      ..write(obj.itemNameSnapshot)
      ..writeByte(2)
      ..write(obj.unitPriceSnapshot)
      ..writeByte(3)
      ..write(obj.qty)
      ..writeByte(4)
      ..write(obj.lineTotal);
  }
}
