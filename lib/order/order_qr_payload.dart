import 'dart:convert';

class OrderQrLine {
  final String itemId;
  final int qty;

  const OrderQrLine({required this.itemId, required this.qty});
}

class OrderQrPayload {
  final String? orderId;
  final List<OrderQrLine> items;

  const OrderQrPayload({required this.orderId, required this.items});

  /// Parses QR payload.
  ///
  /// Expected (recommended) JSON:
  /// {
  ///   "orderId": "ORD-123",
  ///   "items": [ {"id": "chicken_biryani", "qty": 2} ]
  /// }
  ///
  /// Back-compat keys accepted:
  /// - items can be "lines"
  /// - id can be "itemId"
  /// - qty can be "quantity"
  static OrderQrPayload? tryParse(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;

    dynamic decoded;
    try {
      decoded = jsonDecode(trimmed);
    } catch (_) {
      return null;
    }

    if (decoded is! Map) return null;
    final map = decoded.cast<String, dynamic>();

    final orderId =
        (map['orderId'] ?? map['order_id'] ?? map['id'])?.toString();

    final dynamic itemsRaw = map['items'] ?? map['lines'];
    if (itemsRaw is! List) return null;

    final lines = <OrderQrLine>[];
    for (final entry in itemsRaw) {
      if (entry is! Map) continue;
      final e = entry.cast<String, dynamic>();
      final id = (e['id'] ?? e['itemId'] ?? e['item_id'])?.toString().trim();
      final qtyRaw = e['qty'] ?? e['quantity'];
      final qty =
          qtyRaw is int ? qtyRaw : int.tryParse(qtyRaw?.toString() ?? '');

      if (id == null || id.isEmpty) continue;
      if (qty == null || qty <= 0) continue;

      lines.add(OrderQrLine(itemId: id, qty: qty));
    }

    if (lines.isEmpty) return null;

    return OrderQrPayload(orderId: orderId, items: List.unmodifiable(lines));
  }
}
