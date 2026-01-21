import '/flutter_flow/flutter_flow_icon_button.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:uuid/uuid.dart';

import '../components/menu_manager.dart';
import '../components/menu_model.dart';
import '../models/bill.dart';
import '../models/bill_item.dart';
import '../printing/thermal_printer_service.dart';
import '../services/bill_repository.dart';
import '../create_bill/create_bill_widget.dart';
import 'order_qr_payload.dart';

class OrderWidget extends StatefulWidget {
  const OrderWidget({super.key});

  static String routeName = 'Order';
  static String routePath = '/order';

  @override
  State<OrderWidget> createState() => _OrderWidgetState();
}

typedef _ResolvedLine = ({
  String itemId,
  String name,
  int qty,
  double unitPrice,
  double lineTotal,
});

class _OrderWidgetState extends State<OrderWidget> {
  final MenuManager _menuManager = MenuManager();

  late final MobileScannerController _scannerController;

  bool _isScanning = true;
  bool _isFlashOn = false;
  bool _isProcessing = false;
  bool _handledCurrentScan = false;

  @override
  void initState() {
    super.initState();

    _scannerController = MobileScannerController(
      formats: const [BarcodeFormat.qrCode],
      detectionSpeed: DetectionSpeed.noDuplicates,
    );

    _menuManager.addListener(_onMenuChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scannerController.start();
    });
  }

  @override
  void dispose() {
    _menuManager.removeListener(_onMenuChanged);
    _scannerController.dispose();
    super.dispose();
  }

  void _onMenuChanged() {
    // Menu availability changes are applied at validation time.
  }

  void _toggleFlash() {
    _scannerController.toggleTorch();
    if (!mounted) return;
    setState(() {
      _isFlashOn = !_isFlashOn;
    });
  }

  void _scanAgain() {
    setState(() {
      _handledCurrentScan = false;
      _isProcessing = false;
      _isScanning = true;
    });
    _scannerController.start();
  }

  void _showInvalidQr(String message) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          margin: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Color(0xFFFFF3E0),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.error_outline,
                    color: Color(0xFFE59737),
                    size: 40,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Invalid QR Code',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF333333),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF666666),
                  ),
                ),
                SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFE59737),
                        Color(0xFFFFB74D),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _scanAgain();
                    },
                    child: Text(
                      'SCAN AGAIN',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'CLOSE',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF666666),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAvailabilityError({
    required String title,
    required List<String> lines,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          margin: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.warning_amber_rounded,
                        color: Color(0xFFE59737),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                ...lines.map(
                  (l) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      '• $l',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFE59737),
                        Color(0xFFFFB74D),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _scanAgain();
                    },
                    child: Text(
                      'SCAN AGAIN',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'DISMISS',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<MenuItem?> _pickAdditionalMenuItem() async {
    final items = _menuManager.allMenuItems
        .where((it) => it.isActive && it.isAvailable)
        .toList();
    items.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    return showModalBottomSheet<MenuItem>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Add Item',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF333333),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Color(0xFF666666)),
                    )
                  ],
                ),
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.55,
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final it = items[index];
                      return ListTile(
                        title: Text(
                          it.name,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF333333),
                          ),
                        ),
                        subtitle: Text(
                          '₹${it.price.toStringAsFixed(2)}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF666666),
                          ),
                        ),
                        onTap: () => Navigator.pop(context, it),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showOrderSummary({
    required String? orderId,
    required List<_ResolvedLine> items,
    required double total,
    List<String> warnings = const [],
  }) async {
    // These must live outside the StatefulBuilder so that qty edits and
    // added items persist across setModalState() rebuilds.
    final editableItems = items.toList();
    var editableTotal = total;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            void recalc() {
              double nextTotal = 0.0;
              final nextItems = <_ResolvedLine>[];
              for (final it in editableItems) {
                final lineTotal = it.unitPrice * it.qty;
                nextTotal += lineTotal;
                nextItems.add((
                  itemId: it.itemId,
                  name: it.name,
                  qty: it.qty,
                  unitPrice: it.unitPrice,
                  lineTotal: lineTotal,
                ));
              }
              editableItems
                ..clear()
                ..addAll(nextItems);
              editableTotal = nextTotal;
            }

            void incQty(int index) {
              final it = editableItems[index];
              final nextQty = it.qty + 1;
              editableItems[index] = (
                itemId: it.itemId,
                name: it.name,
                qty: nextQty,
                unitPrice: it.unitPrice,
                lineTotal: it.unitPrice * nextQty,
              );
              recalc();
              setModalState(() {});
            }

            void decQty(int index) {
              final it = editableItems[index];
              final nextQty = it.qty - 1;
              if (nextQty <= 0) {
                editableItems.removeAt(index);
              } else {
                editableItems[index] = (
                  itemId: it.itemId,
                  name: it.name,
                  qty: nextQty,
                  unitPrice: it.unitPrice,
                  lineTotal: it.unitPrice * nextQty,
                );
              }
              recalc();
              setModalState(() {});
            }

            Future<void> addMoreItems() async {
              final picked = await _pickAdditionalMenuItem();
              if (picked == null) return;

              final idx = editableItems.indexWhere((e) => e.itemId == picked.id);
              if (idx == -1) {
                editableItems.add((
                  itemId: picked.id,
                  name: picked.name,
                  qty: 1,
                  unitPrice: picked.price,
                  lineTotal: picked.price,
                ));
              } else {
                final existing = editableItems[idx];
                final nextQty = existing.qty + 1;
                editableItems[idx] = (
                  itemId: existing.itemId,
                  name: existing.name,
                  qty: nextQty,
                  unitPrice: existing.unitPrice,
                  lineTotal: existing.unitPrice * nextQty,
                );
              }

              recalc();
              setModalState(() {});
            }

            Map<String, int> buildCartMap() {
              final cart = <String, int>{};
              for (final it in editableItems) {
                if (it.qty <= 0) continue;
                cart[it.itemId] = (cart[it.itemId] ?? 0) + it.qty;
              }
              return cart;
            }

            return Container(
              margin: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Order Summary',
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF333333),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                (orderId == null || orderId.trim().isEmpty)
                                    ? 'QR order'
                                    : 'Order #$orderId',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF666666),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.close, color: Color(0xFF666666)),
                        )
                      ],
                    ),
                    if (warnings.isNotEmpty) ...[
                      SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Some items were skipped',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF333333),
                              ),
                            ),
                            SizedBox(height: 6),
                            ...warnings.map(
                              (w) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text(
                                  '• $w',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFF666666),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    SizedBox(height: 12),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.45,
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: editableItems.length,
                        separatorBuilder: (_, __) => Divider(height: 16),
                        itemBuilder: (context, index) {
                          final it = editableItems[index];
                          return Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      it.name,
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF333333),
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      '₹${it.unitPrice.toStringAsFixed(2)} × ${it.qty}',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xFF666666),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () => decQty(index),
                                    icon: const Icon(
                                      Icons.remove_circle_outline,
                                      color: Color(0xFF666666),
                                    ),
                                  ),
                                  Text(
                                    '${it.qty}',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF333333),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => incQty(index),
                                    icon: const Icon(
                                      Icons.add_circle_outline,
                                      color: Color(0xFF666666),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '₹${it.lineTotal.toStringAsFixed(2)}',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF333333),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF666666),
                          ),
                        ),
                        Text(
                          '₹${editableTotal.toStringAsFixed(2)}',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFE59737),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      height: 44,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE59737)),
                      ),
                      child: TextButton(
                        onPressed: _isProcessing
                            ? null
                            : () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CreateBillWidget(
                                      initialCartItems: buildCartMap(),
                                    ),
                                  ),
                                );
                              },
                        child: Text(
                          'OPEN CREATE BILL',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFE59737),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFE59737),
                            Color(0xFFFFB74D),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextButton(
                        onPressed: _isProcessing
                            ? null
                            : () async {
                                Navigator.pop(context);
                                if (editableItems.isEmpty) {
                                  return;
                                }
                                await _printAndSaveBill(
                                  items: editableItems,
                                  total: editableTotal,
                                );
                              },
                        child: Text(
                          'PRINT BILL',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _scanAgain();
                      },
                      child: Text(
                        'SCAN NEXT ORDER',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _printAndSaveBill({
    required List<_ResolvedLine> items,
    required double total,
  }) async {
    if (!mounted) return;

    setState(() {
      _isProcessing = true;
    });

    void showSnack(String message) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }

    final now = DateTime.now();
    final billNo = const BillRepository().getNextBillNo(now);

    final billItems = items
        .map(
          (it) => BillItem(
            itemId: it.itemId,
            itemNameSnapshot: it.name,
            unitPriceSnapshot: it.unitPrice,
            qty: it.qty,
            lineTotal: it.lineTotal,
          ),
        )
        .toList();

    final bill = Bill(
      id: const Uuid().v4(),
      createdAt: now,
      totalAmount: total,
      items: billItems,
      billNo: billNo,
    );

    bool printedOk = false;
    try {
      printedOk = await ThermalPrinterService.instance.printBill(bill);
    } catch (_) {
      printedOk = false;
    }

    if (printedOk) {
      await const BillRepository().addBill(bill);
      showSnack('Bill printed & saved');
      _scanAgain();
    } else {
      showSnack(
        'Printing failed: ${ThermalPrinterService.instance.lastErrorMessage ?? 'Printer not connected'}',
      );
    }

    if (!mounted) return;
    setState(() {
      _isProcessing = false;
    });
  }

  Future<void> _handleBarcode(String rawValue) async {
    if (_handledCurrentScan || _isProcessing) return;

    setState(() {
      _handledCurrentScan = true;
      _isScanning = false;
    });

    await _scannerController.stop();

    final payload = OrderQrPayload.tryParse(rawValue);
    if (payload == null) {
      _showInvalidQr(
        'This QR does not contain a valid order payload. Please generate a new QR from the orders website.',
      );
      return;
    }

    final resolved = <_ResolvedLine>[];
    final missing = <String>[];
    final unavailable = <String>[];
    double total = 0.0;

    for (final line in payload.items) {
      final int idx = _menuManager.allMenuItems.indexWhere(
        (MenuItem i) => i.id == line.itemId,
      );
      if (idx == -1) {
        missing.add('${line.itemId} (x${line.qty})');
        continue;
      }

      final item = _menuManager.allMenuItems[idx];
      final bool ok = item.isActive && item.isAvailable;
      if (!ok) {
        unavailable.add('${item.name} (x${line.qty})');
        continue;
      }

      final unitPrice = item.price;
      final lineTotal = unitPrice * line.qty;
      total += lineTotal;
      resolved.add((
        itemId: item.id,
        name: item.name,
        qty: line.qty,
        unitPrice: unitPrice,
        lineTotal: lineTotal,
      ));
    }

    if (resolved.isEmpty) {
      final lines = <String>[];
      if (unavailable.isNotEmpty) {
        lines.add('Unavailable / Disabled: ${unavailable.join(', ')}');
      }
      if (missing.isNotEmpty) {
        lines.add('Unknown items: ${missing.join(', ')}');
      }
      _showAvailabilityError(
        title: 'No available items in this order',
        lines: lines.isEmpty
            ? ['All scanned items are unavailable or unknown.']
            : lines,
      );
      return;
    }

    final warnings = <String>[];
    if (unavailable.isNotEmpty) {
      warnings.add('Unavailable / Disabled: ${unavailable.join(', ')}');
    }
    if (missing.isNotEmpty) {
      warnings.add('Unknown items ignored: ${missing.join(', ')}');
    }

    await _showOrderSummary(
      orderId: payload.orderId,
      items: resolved,
      total: total,
      warnings: warnings,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              color: Colors.black,
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(16, 12, 16, 12),
                child: Row(
                  children: [
                    FlutterFlowIconButton(
                      borderRadius: 12,
                      buttonSize: 40,
                      icon: Icon(
                        Icons.arrow_back_ios_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Scan Order QR',
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Position QR code within frame',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: _toggleFlash,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _isFlashOn ? Icons.flash_on : Icons.flash_off,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CreateBillWidget(),
                          ),
                        );
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.receipt_long_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Scanner Area
            Expanded(
              child: Center(
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: MobileScanner(
                          controller: _scannerController,
                          onDetect: (capture) {
                            if (!_isScanning || _isProcessing) return;
                            final barcodes = capture.barcodes;
                            if (barcodes.isEmpty) return;
                            final raw = barcodes.first.rawValue;
                            if (raw == null || raw.trim().isEmpty) return;
                            _handleBarcode(raw);
                          },
                        ),
                      ),

                      // Corner Borders
                      Positioned(
                        top: 0,
                        left: 0,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                  color: Color(0xFFE59737), width: 4),
                              left: BorderSide(
                                  color: Color(0xFFE59737), width: 4),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                  color: Color(0xFFE59737), width: 4),
                              right: BorderSide(
                                  color: Color(0xFFE59737), width: 4),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                  color: Color(0xFFE59737), width: 4),
                              left: BorderSide(
                                  color: Color(0xFFE59737), width: 4),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                  color: Color(0xFFE59737), width: 4),
                              right: BorderSide(
                                  color: Color(0xFFE59737), width: 4),
                            ),
                          ),
                        ),
                      ),

                      if (_isScanning)
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            color: Colors.black.withOpacity(0.35),
                            child: Center(
                              child: Text(
                                'Scanning…',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // Instructions
            Container(
              color: Colors.black,
              padding: EdgeInsetsDirectional.fromSTEB(24, 20, 24, 40),
              child: Column(
                children: [
                  Text(
                    _isScanning ? 'Scanning…' : 'Ready to Scan',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    _isScanning
                        ? 'Hold steady for automatic detection'
                        : 'Tap START SCANNING to resume camera',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                  SizedBox(height: 20),
                  if (!_isScanning)
                    Container(
                      width: double.infinity,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Color(0xFFE59737),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFFE59737).withOpacity(0.3),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextButton(
                        onPressed: _scanAgain,
                        child: Text(
                          'START SCANNING',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
