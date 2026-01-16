import 'dart:typed_data';

import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';

import '../models/bill.dart';

Future<Uint8List> buildEscPosReceipt(Bill bill) async {
  final profile = await CapabilityProfile.load();
  final generator = Generator(PaperSize.mm58, profile);

  final bytes = <int>[];

  bytes.addAll(
    generator.text(
      'Abiruchi Food Works',
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
      linesAfter: 1,
    ),
  );

  bytes.addAll(
    generator.text(
      'Date: ${_formatDateTime(bill.createdAt)}',
      styles: const PosStyles(align: PosAlign.center),
      linesAfter: 1,
    ),
  );

  bytes.addAll(generator.hr());

  for (final item in bill.items) {
    final nameQty =
        _sanitizeEscPosText('${item.itemNameSnapshot} x ${item.qty}');
    final total = _sanitizeEscPosText(_formatMoney(item.lineTotal));

    bytes.addAll(
      generator.row(
        [
          PosColumn(
              text: nameQty,
              width: 8,
              styles: const PosStyles(align: PosAlign.left)),
          PosColumn(
              text: total,
              width: 4,
              styles: const PosStyles(align: PosAlign.right)),
        ],
      ),
    );
  }

  bytes.addAll(generator.hr());

  bytes.addAll(
    generator.row(
      [
        PosColumn(
          text: 'TOTAL',
          width: 8,
          styles: const PosStyles(align: PosAlign.left, bold: true),
        ),
        PosColumn(
          text: _formatMoney(bill.totalAmount),
          width: 4,
          styles: const PosStyles(align: PosAlign.right, bold: true),
        ),
      ],
    ),
  );

  bytes.addAll(generator.feed(1));

  bytes.addAll(
    generator.text(
      'Thank you!',
      styles: const PosStyles(align: PosAlign.center, bold: true),
      linesAfter: 1,
    ),
  );

  bytes.addAll(generator.cut());

  return Uint8List.fromList(bytes);
}

String _formatDateTime(DateTime dt) {
  final local = dt.toLocal();
  String two(int v) => v.toString().padLeft(2, '0');
  return '${local.year}-${two(local.month)}-${two(local.day)} ${two(local.hour)}:${two(local.minute)}';
}

String _formatMoney(double value) {
  // IMPORTANT: esc_pos_utils_plus encodes using Latin-1 on many code tables.
  // The Unicode rupee symbol (₹) will throw. Use ASCII-safe prefix.
  final rounded = value.round();
  return 'Rs $rounded';
}

String _sanitizeEscPosText(String value) {
  // Keep it simple and robust: replace known Unicode currency symbols and
  // strip any remaining non-Latin-1 characters that would crash encoding.
  final replaced = value.replaceAll('₹', 'Rs ');
  return replaced.replaceAll(RegExp(r'[^\x00-\xFF]'), '');
}
