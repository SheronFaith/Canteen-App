// Updated CreateBillWidget.dart (partial - showing key changes)
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import 'create_bill_model.dart';
export 'create_bill_model.dart';
import '/components/menu_model.dart';
import '/components/menu_manager.dart';

import '/models/bill.dart';
import '/models/bill_item.dart';
import '/services/bill_repository.dart';
import '/printing/thermal_printer_service.dart';

class CreateBillWidget extends StatefulWidget {
  const CreateBillWidget({super.key});

  static String routeName = 'CreateBill';
  static String routePath = '/createBill';

  @override
  State<CreateBillWidget> createState() => _CreateBillWidgetState();
}

class _CreateBillWidgetState extends State<CreateBillWidget> {
  late CreateBillModel _model;
  final MenuManager _menuManager = MenuManager();
  List<MenuItem> _filteredItems = [];
  String _selectedCategory = 'All';
  final Map<String, int> _cartItems = {}; // itemId -> quantity
  double _totalAmount = 0.0;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CreateBillModel());
    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();

    // Initialize with all active items
    _filteredItems = _menuManager.activeMenuItems;

    // Listen for menu updates
    _menuManager.addListener(_onMenuUpdated);

    // Listen to search changes
    _model.textController?.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _menuManager.removeListener(_onMenuUpdated);
    _model.textController?.removeListener(_onSearchChanged);
    _model.dispose();
    super.dispose();
  }

  void _onMenuUpdated() {
    setState(() {
      _applyFilters();
      _updateTotalAmount();
    });
  }

  void _onSearchChanged() {
    _applyFilters();
  }

  void _applyFilters() {
    final searchQuery = _model.textController.text.toLowerCase();

    List<MenuItem> items = _menuManager.activeMenuItems;

    // Apply category filter
    if (_selectedCategory == 'Breakfast') {
      items = _menuManager.breakfastItems;
    } else if (_selectedCategory == 'Lunch') {
      items = _menuManager.lunchItems;
    }

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      items = items
          .where((item) =>
              item.name.toLowerCase().contains(searchQuery) ||
              item.description.toLowerCase().contains(searchQuery) ||
              item.category.toLowerCase().contains(searchQuery))
          .toList();
    }

    setState(() {
      _filteredItems = items;
    });
  }

  void _updateTotalAmount() {
    double total = 0.0;
    _cartItems.forEach((itemId, quantity) {
      final item = _menuManager.allMenuItems.firstWhere(
        (item) => item.id == itemId,
        orElse: () => MenuItem.fromData(
          name: 'Unknown',
          price: 0,
          quantity: '0',
          category: 'unknown',
        ),
      );
      total += item.price * quantity;
    });
    setState(() {
      _totalAmount = total;
    });
  }

  void _addToCart(String itemId) {
    setState(() {
      _cartItems[itemId] = (_cartItems[itemId] ?? 0) + 1;
      _updateTotalAmount();
    });
  }

  void _removeFromCart(String itemId) {
    setState(() {
      final currentQuantity = _cartItems[itemId] ?? 0;
      if (currentQuantity > 1) {
        _cartItems[itemId] = currentQuantity - 1;
      } else {
        _cartItems.remove(itemId);
      }
      _updateTotalAmount();
    });
  }

  void _clearCart() {
    setState(() {
      _cartItems.clear();
      _totalAmount = 0.0;
    });
  }

  Future<void> _onGenerateBillPressed() async {
    void showSnack(String message) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }

    if (_cartItems.isEmpty) {
      showSnack('Cart is empty');
      return;
    }

    // Debug logs to ensure tap is firing.
    // ignore: avoid_print
    print(
        '[CreateBill] Generate Bill tapped. Cart items: ${_cartItems.length}');

    final now = DateTime.now();
    final billItems = <BillItem>[];
    double totalAmount = 0.0;

    for (final entry in _cartItems.entries) {
      final itemId = entry.key;
      final qty = entry.value;
      if (qty <= 0) {
        continue;
      }

      final menuItem = _menuManager.allMenuItems.firstWhere(
        (item) => item.id == itemId,
        orElse: () => MenuItem.fromData(
          name: 'Unknown',
          price: 0,
          quantity: '0',
          category: 'unknown',
        ),
      );

      final unitPrice = menuItem.price;
      final lineTotal = unitPrice * qty;
      totalAmount += lineTotal;
      billItems.add(
        BillItem(
          itemId: itemId,
          itemNameSnapshot: menuItem.name,
          unitPriceSnapshot: unitPrice,
          qty: qty,
          lineTotal: lineTotal,
        ),
      );
    }

    final bill = Bill(
      id: const Uuid().v4(),
      createdAt: now,
      totalAmount: totalAmount,
      items: billItems,
    );

    try {
      await const BillRepository().addBill(bill);
      // ignore: avoid_print
      print('[CreateBill] Bill saved. id=${bill.id} total=${bill.totalAmount}');
    } catch (e, st) {
      // ignore: avoid_print
      print('[CreateBill] Failed to save bill: $e');
      // ignore: avoid_print
      print(st);
      showSnack('Failed to save bill: $e');
      return;
    }

    bool printedOk = false;
    try {
      printedOk = await ThermalPrinterService.instance.printBill(bill);
    } catch (e, st) {
      // ignore: avoid_print
      print('[CreateBill] Print threw: $e');
      // ignore: avoid_print
      print(st);
      printedOk = false;
    }

    if (printedOk) {
      showSnack('Bill saved & printed');
    } else {
      final err = ThermalPrinterService.instance.lastErrorMessage ??
          'Printer not connected';
      showSnack('Bill saved, printing failed: $err');
    }

    _clearCart();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.white,
        body: Column(
          children: [
            // Custom App Bar (unchanged)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(16, 12, 16, 12),
                  child: Row(
                    children: [
                      FlutterFlowIconButton(
                        borderRadius: 12,
                        buttonSize: 40,
                        icon: Icon(
                          Icons.arrow_back_ios_rounded,
                          color: Color(0xFF333333),
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
                              'Create Bill',
                              style: GoogleFonts.inter(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF333333),
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Add items to generate invoice',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF666666),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 36,
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Color(0xFFE59737).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '₹${_totalAmount.toStringAsFixed(2)}',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFE59737),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Search Bar (unchanged)
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(16, 16, 16, 12),
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: _model.textController,
                  focusNode: _model.textFieldFocusNode,
                  autofocus: false,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF333333),
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search menu items (e.g., Dosa, Biryani)',
                    hintStyle: GoogleFonts.inter(
                      color: Color(0xFF999999),
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(left: 16, right: 8),
                      child: Icon(
                        Icons.search_rounded,
                        color: Color(0xFF999999),
                        size: 20,
                      ),
                    ),
                    prefixIconConstraints: BoxConstraints(minWidth: 40),
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),

            // Categories Filter
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(16, 0, 16, 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildCategoryChip('All',
                        isSelected: _selectedCategory == 'All'),
                    SizedBox(width: 8),
                    _buildCategoryChip('Breakfast',
                        isSelected: _selectedCategory == 'Breakfast'),
                    SizedBox(width: 8),
                    _buildCategoryChip('Lunch',
                        isSelected: _selectedCategory == 'Lunch'),
                  ],
                ),
              ),
            ),

            // Items Count Header
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(16, 0, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Menu Items',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF333333),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_filteredItems.length} items',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Menu Items List
            Expanded(
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
                child: _filteredItems.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              color: Color(0xFFCCCCCC),
                              size: 64,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No items found',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF999999),
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Try searching with different keywords',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF999999),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        physics: BouncingScrollPhysics(),
                        itemCount: _filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = _filteredItems[index];
                          final quantity = _cartItems[item.id] ?? 0;
                          return Padding(
                            padding: EdgeInsets.only(bottom: 12),
                            child: _buildMenuItem(item, quantity),
                          );
                        },
                      ),
              ),
            ),

            // Bottom Order Summary
            if (_cartItems.isNotEmpty)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: Offset(0, -4),
                    ),
                  ],
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(24, 20, 24, 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Current Order',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF666666),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '${_cartItems.length} Items',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF999999),
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Total',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF666666),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '₹${_totalAmount.toStringAsFixed(2)}',
                                  style: GoogleFonts.inter(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFE59737),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: _clearCart,
                                child: Container(
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Color(0xFFE0E0E0),
                                      width: 1,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Clear Cart',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF666666),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: GestureDetector(
                                onTap: _onGenerateBillPressed,
                                child: Container(
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
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            Color(0xFFE59737).withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.receipt_long_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Generate Bill',
                                        style: GoogleFonts.inter(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label, {required bool isSelected}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = label;
          _applyFilters();
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFFE59737) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Color(0xFFE59737) : Color(0xFFE0E0E0),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Color(0xFFE59737).withOpacity(0.2),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Color(0xFF666666),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(MenuItem item, int quantity) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () {
          if (item.isAvailable && item.isActive) {
            _addToCart(item.id);
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
            border: !item.isActive || !item.isAvailable
                ? Border.all(color: Color(0xFFEEEEEE), width: 1)
                : null,
          ),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                // Item Image with Veg/Non-veg indicator
                Stack(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Color(0xFFF5F5F5),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          item.imageUrl ??
                              'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Color(0xFFF5F5F5),
                              child: Icon(
                                Icons.fastfood_rounded,
                                color: Color(0xFFCCCCCC),
                                size: 32,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: item.isVeg
                              ? Color(0xFF4CAF50)
                              : Color(0xFFF44336),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          item.isVeg ? 'VEG' : 'NON-VEG',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                    if (!item.isActive || !item.isAvailable)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              !item.isAvailable ? 'SOLD OUT' : 'UNAVAILABLE',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(width: 16),

                // Item Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.name,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: (!item.isActive || !item.isAvailable)
                                    ? Color(0xFF999999)
                                    : Color(0xFF333333),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 8),
                          if (!item.isActive || !item.isAvailable)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Color(0xFFF44336),
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${item.description} • ${item.quantity}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: (!item.isActive || !item.isAvailable)
                              ? Color(0xFFCCCCCC)
                              : Color(0xFF666666),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '₹${item.price.toStringAsFixed(2)}',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: (!item.isActive || !item.isAvailable)
                                  ? Color(0xFFCCCCCC)
                                  : Color(0xFFE59737),
                            ),
                          ),
                          if (quantity > 0)
                            // Quantity Selector for added items
                            Container(
                              height: 36,
                              decoration: BoxDecoration(
                                color: Color(0xFFE59737).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: () => _removeFromCart(item.id),
                                    child: Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: Color(0xFFE59737),
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      child: Center(
                                        child: Icon(
                                          Icons.remove,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 12),
                                    child: Text(
                                      '$quantity',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF333333),
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => _addToCart(item.id),
                                    child: Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: Color(0xFFE59737),
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      child: Center(
                                        child: Icon(
                                          Icons.add,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else if (item.isActive && item.isAvailable)
                            // Add Button for unadded items
                            GestureDetector(
                              onTap: () => _addToCart(item.id),
                              child: Container(
                                height: 36,
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  color: Color(0xFFE59737),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Center(
                                  child: Text(
                                    'ADD',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          else
                            // Disabled button for unavailable items
                            Container(
                              height: 36,
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: Color(0xFFEEEEEE),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Center(
                                child: Text(
                                  'UNAVAILABLE',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF999999),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
