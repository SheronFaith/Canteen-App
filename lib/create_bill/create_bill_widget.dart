import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'create_bill_model.dart';
export 'create_bill_model.dart';
import '/components/menu_model.dart';
import '/components/menu_manager.dart';

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
  bool _showFullSummary = false; // NEW: Controls full summary panel visibility

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
    } else if (_selectedCategory != 'All') {
      items = _filterByCategory(_selectedCategory);
    }
    
    // Apply search filter
    if (searchQuery.isNotEmpty) {
      items = items.where((item) =>
          item.name.toLowerCase().contains(searchQuery) ||
          item.description.toLowerCase().contains(searchQuery) ||
          item.category.toLowerCase().contains(searchQuery)
      ).toList();
    }
    
    setState(() {
      _filteredItems = items;
    });
  }

  //sort items
  List<MenuItem> _filterByCategory(String category) {
  return _menuManager.activeMenuItems.where((item) {
    final name = item.name.toLowerCase();
    final desc = item.description.toLowerCase();

    switch (category) {
      case 'Dosa':
        return name.contains('dosa');

      case 'Rice Items':
        return name.contains('rice') ||
               name.contains('meals') ||
               name.contains('biryani');

      case 'Fried Rice & Noodles':
        return name.contains('fried') ||
               name.contains('noodle');

      case 'Parotta & Kothu':
        return name.contains('parotta') ||
               name.contains('paratha') ||
               name.contains('kothu');

      case 'Chicken':
        return name.contains('chicken');

      case 'Egg':
        return name.contains('egg') ||
              name.contains('omelette') ||
              name.contains('omblet') ||
              name.contains('kalaki');

      default:
        return false;
    }
  }).toList();
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

  void _removeItemCompletely(String itemId) {
    setState(() {
      _cartItems.remove(itemId);
      _updateTotalAmount();
    });
  }

  void _clearCart() {
    setState(() {
      _cartItems.clear();
      _totalAmount = 0.0;
      _showFullSummary = false;
    });
  }

  void _toggleSummaryPanel() {
    setState(() {
      _showFullSummary = !_showFullSummary;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            // MAIN CONTENT (unchanged)
            Column(
              children: [
                // Custom App Bar
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

                // Search Bar
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
               // Categories Filter (2-row layout)
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(16, 0, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildCategoryChip('All', isSelected: _selectedCategory == 'All'),
                          _buildCategoryChip('Breakfast', isSelected: _selectedCategory == 'Breakfast'),
                          _buildCategoryChip('Lunch', isSelected: _selectedCategory == 'Lunch'),
                          _buildCategoryChip('Dosa', isSelected: _selectedCategory == 'Dosa'),
                          _buildCategoryChip('Rice Items', isSelected: _selectedCategory == 'Rice Items'),
                        ],
                      ),

                      SizedBox(height: 8),

                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildCategoryChip(
                            'Fried Rice & Noodles',
                            isSelected: _selectedCategory == 'Fried Rice & Noodles',
                          ),
                          _buildCategoryChip(
                            'Parotta & Kothu',
                            isSelected: _selectedCategory == 'Parotta & Kothu',
                          ),
                          _buildCategoryChip('Chicken', isSelected: _selectedCategory == 'Chicken'),
                          _buildCategoryChip('Egg', isSelected: _selectedCategory == 'Egg'),
                        ],
                      ),
                    ],
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
                    padding: EdgeInsetsDirectional.fromSTEB(16,0,16,_cartItems.isNotEmpty ? 80 : 0,),
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
              ],
            ),

            // SMALL FLOATING SUMMARY CARD
            if (_cartItems.isNotEmpty && !_showFullSummary)
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: GestureDetector(
                  onTap: _toggleSummaryPanel,
                  child: _buildSmallSummaryCard(),
                ),
              ),

            // FULL SUMMARY PANEL (Overlay)
            if (_showFullSummary)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.4),
                  child: Column(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: _toggleSummaryPanel,
                          child: Container(
                            color: Colors.transparent,
                          ),
                        ),
                      ),
                      _buildFullSummaryPanel(),
                    ],
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
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: item.isVeg ? Color(0xFF4CAF50) : Color(0xFFF44336),
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
                                    padding: EdgeInsets.symmetric(horizontal: 12),
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

  // NEW: Small Floating Summary Card
  Widget _buildSmallSummaryCard() {
    final totalItems = _cartItems.values.fold(0, (sum, quantity) => sum + quantity);
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            // Items Count
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Color(0xFFE59737).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  '$totalItems',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFE59737),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),
            
            // Summary Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Summary',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    '$totalItems items • ₹${_totalAmount.toStringAsFixed(2)}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF666666),
                    ),
                  ),
                ],
              ),
            ),
            
            // View Details Button
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Text(
                    'View',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF666666),
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Color(0xFF666666),
                    size: 12,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  //Full Summary Panel
  Widget _buildFullSummaryPanel() {
    final cartItemsList = _cartItems.entries.toList();
    final totalItems = cartItemsList.fold(0, (sum, entry) => sum + entry.value);
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Drag Handle & Close Button
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                // Drag Handle
                Expanded(
                  child: Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Color(0xFFE0E0E0),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
                
                // Close Button
                GestureDetector(
                  onTap: _toggleSummaryPanel,
                  child: Container(
                    width: 36,
                    height: 36,
                    margin: EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      color: Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.close,
                        color: Color(0xFF666666),
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order Summary',
                  style: GoogleFonts.inter(
                    fontSize: 25,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF333333),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$totalItems items',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Items List
          Expanded(
            child: Padding(
            padding: EdgeInsets.fromLTRB(24, 12, 24, 0),
              child: cartItemsList.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_cart_outlined,
                            color: Color(0xFFCCCCCC),
                            size: 64,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No items in cart',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF999999),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      physics: BouncingScrollPhysics(),
                      itemCount: cartItemsList.length,
                      separatorBuilder: (context, index) => Divider(
                        height: 24,
                        color: Color(0xFFF0F0F0),
                      ),
                      itemBuilder: (context, index) {
                        final entry = cartItemsList[index];
                        final item = _menuManager.allMenuItems.firstWhere(
                          (item) => item.id == entry.key,
                          orElse: () => MenuItem.fromData(
                            name: 'Unknown Item',
                            price: 0,
                            quantity: '0',
                            category: 'unknown',
                          ),
                        );
                        
                        return Row(
                          children: [
                            // Item Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF333333),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    '₹${item.price.toStringAsFixed(2)} each',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF666666),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 16),
                            
                            // Quantity Controls
                            Container(
                              height: 36,
                              decoration: BoxDecoration(
                                color: Color(0xFFF8F9FA),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Row(
                                children: [
                                  // Minus Button
                                  GestureDetector(
                                    onTap: () => _removeFromCart(item.id),
                                    child: Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: Color(0xFFE0E0E0),
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      child: Center(
                                        child: Icon(
                                          Icons.remove,
                                          color: Color(0xFF666666),
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                  
                                  // Quantity
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 12),
                                    child: Text(
                                      '${entry.value}',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF333333),
                                      ),
                                    ),
                                  ),
                                  
                                  // Plus Button
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
                            ),
                            SizedBox(width: 16),
                            
                            // Remove Button
                            GestureDetector(
                              onTap: () => _removeItemCompletely(item.id),
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: Color(0xFFFEE),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: Color(0xFFF44336).withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.close,
                                    color: Color(0xFFF44336),
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                            
                            // Item Total
                            SizedBox(width: 16),
                            SizedBox(
                            width: 80,
                            child: Text(
                              '₹${(item.price * entry.value).toStringAsFixed(2)}',
                              textAlign: TextAlign.right,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF333333),
                              ),
                            ),
                          ),
                          ],
                        );
                      },
                    ),
            ),
          ),
          
          // Total & Actions
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Color(0xFFF0F0F0), width: 1),
              ),
            ),
            padding: EdgeInsets.all(24),
            child: Column(
              children: [
                // Total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF333333),
                      ),
                    ),
                    Text(
                      '₹${_totalAmount.toStringAsFixed(2)}',
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFE59737),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),
                
                // Action Buttons
                Row(
                  children: [
                    // Clear Cart Button
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          _clearCart();
                        },
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Color(0xFFE0E0E0),
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Clear Cart',
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF666666),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    
                    // Generate Bill Button
                    Expanded(
                      flex: 2,
                      child: GestureDetector(
                        onTap: () {
                          // Add your generate bill logic here
                          _toggleSummaryPanel();
                          // Show bill generation dialog or navigate
                        },
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFFE59737),
                                Color(0xFFF9A825),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFFE59737).withOpacity(0.3),
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
        ],
      ),
    );
  }
}