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
        height: PosTextSize.size1,
        width: PosTextSize.size1,
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
              styles: const PosStyles(
                align: PosAlign.left,
                bold: false,
                fontType: PosFontType.fontB,
                height: PosTextSize.size1,
                width: PosTextSize.size1,
              )),
          PosColumn(
              text: total,
              width: 4,
              styles: const PosStyles(
                align: PosAlign.right,
                bold: false,
                fontType: PosFontType.fontB,
                height: PosTextSize.size1,
                width: PosTextSize.size1,
              )),
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

  // Bottom margin so the paper comes out enough to tear.
  // Using ESC/POS "Print and feed n dots" (ESC J n) gives finer control than
  // feeding a whole text line.
  // ~80 dots ≈ ~10mm on most 203dpi printers.
  bytes.addAll(<int>[0x1B, 0x4A, 80]);

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
