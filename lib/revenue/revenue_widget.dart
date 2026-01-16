import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RevenueWidget extends StatefulWidget {
  const RevenueWidget({super.key});

  static String routeName = 'Revenue';
  static String routePath = '/revenue';

  @override
  State<RevenueWidget> createState() => _RevenueWidgetState();
}

class _RevenueWidgetState extends State<RevenueWidget> {
  String _selectedPeriod = 'Today'; // Today, This Week, This Month

  // Sample data for all items sold
  final Map<String, Map<String, dynamic>> _periodData = {
    'Today': {
      'revenue': '₹41,200',
      'orders': 158,
      'avgOrderValue': '₹260.75',
      'itemsSold': [
        {'name': 'Chicken Biryani', 'quantity': 48, 'revenue': '₹12,000'},
        {'name': 'Masala Dosa', 'quantity': 36, 'revenue': '₹4,320'},
        {'name': 'Paneer Butter Masala', 'quantity': 28, 'revenue': '₹5,040'},
        {'name': 'Veg Thali', 'quantity': 24, 'revenue': '₹1,920'},
        {'name': 'Cold Coffee', 'quantity': 22, 'revenue': '₹1,760'},
        {'name': 'Butter Naan', 'quantity': 18, 'revenue': '₹540'},
        {'name': 'Dal Tadka', 'quantity': 15, 'revenue': '₹1,200'},
        {'name': 'Jeera Rice', 'quantity': 12, 'revenue': '₹840'},
        {'name': 'Roti', 'quantity': 10, 'revenue': '₹200'},
        {'name': 'Plain Rice', 'quantity': 8, 'revenue': '₹320'},
      ]
    },
    'This Week': {
      'revenue': '₹2,85,400',
      'orders': 1120,
      'avgOrderValue': '₹254.82',
      'itemsSold': [
        {'name': 'Chicken Biryani', 'quantity': 320, 'revenue': '₹80,000'},
        {'name': 'Paneer Butter Masala', 'quantity': 195, 'revenue': '₹35,100'},
        {'name': 'Masala Dosa', 'quantity': 180, 'revenue': '₹21,600'},
        {'name': 'Veg Thali', 'quantity': 168, 'revenue': '₹13,440'},
        {'name': 'Butter Naan', 'quantity': 142, 'revenue': '₹4,260'},
        {'name': 'Dal Tadka', 'quantity': 120, 'revenue': '₹9,600'},
        {'name': 'Cold Coffee', 'quantity': 115, 'revenue': '₹9,200'},
        {'name': 'Jeera Rice', 'quantity': 98, 'revenue': '₹6,860'},
        {'name': 'Roti', 'quantity': 85, 'revenue': '₹1,700'},
        {'name': 'Plain Rice', 'quantity': 75, 'revenue': '₹3,000'},
      ]
    },
    'This Month': {
      'revenue': '₹12,45,800',
      'orders': 4850,
      'avgOrderValue': '₹256.87',
      'itemsSold': [
        {'name': 'Chicken Biryani', 'quantity': 1280, 'revenue': '₹3,20,000'},
        {'name': 'Paneer Butter Masala', 'quantity': 890, 'revenue': '₹1,60,200'},
        {'name': 'Masala Dosa', 'quantity': 720, 'revenue': '₹86,400'},
        {'name': 'Veg Thali', 'quantity': 672, 'revenue': '₹53,760'},
        {'name': 'Butter Naan', 'quantity': 568, 'revenue': '₹17,040'},
        {'name': 'Dal Tadka', 'quantity': 480, 'revenue': '₹38,400'},
        {'name': 'Cold Coffee', 'quantity': 460, 'revenue': '₹36,800'},
        {'name': 'Jeera Rice', 'quantity': 392, 'revenue': '₹27,440'},
        {'name': 'Roti', 'quantity': 340, 'revenue': '₹6,800'},
        {'name': 'Plain Rice', 'quantity': 300, 'revenue': '₹12,000'},
      ]
    }
  };

  @override
  Widget build(BuildContext context) {
    final currentData = _periodData[_selectedPeriod]!;
    final itemsSold = currentData['itemsSold'] as List<dynamic>;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Custom Header
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
                child: Column(
                  children: [
                    Row(
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
                                'Revenue',
                                style: GoogleFonts.inter(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF333333),
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Sales performance overview',
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
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Color(0xFFF8F9FA),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.calendar_today_outlined,
                            color: Color(0xFF666666),
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Period Selector
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(16, 16, 16, 16),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _buildPeriodTab('Today', 0),
                  _buildPeriodTab('This Week', 1),
                  _buildPeriodTab('This Month', 2),
                ],
              ),
            ),
          ),

          // Main Stats Row
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: 'Total Revenue',
                    value: currentData['revenue'] as String,
                    icon: Icons.currency_rupee_rounded,
                    color: Color(0xFF4CAF50),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    title: 'Total Orders',
                    value: '${currentData['orders']}',
                    icon: Icons.receipt_long_rounded,
                    color: Color(0xFF2196F3),
                  ),
                ),
              ],
            ),
          ),

          // Average Order Value
          // Padding(
          //   padding: EdgeInsetsDirectional.fromSTEB(16, 0, 16, 16),
          //   child: Container(
          //     width: double.infinity,
          //     padding: EdgeInsets.all(16),
          //     decoration: BoxDecoration(
          //       color: Colors.white,
          //       borderRadius: BorderRadius.circular(16),
          //       boxShadow: [
          //         BoxShadow(
          //           color: Colors.black.withOpacity(0.05),
          //           blurRadius: 8,
          //           offset: Offset(0, 2),
          //         ),
          //       ],
          //       border: Border.all(
          //         color: Color(0xFFF0F0F0),
          //         width: 1,
          //       ),
          //     ),
          //     child: Row(
          //       children: [
          //         Container(
          //           width: 40,
          //           height: 40,
          //           decoration: BoxDecoration(
          //             color: Color(0xFFFFF3E0),
          //             borderRadius: BorderRadius.circular(12),
          //           ),
          //           child: Icon(
          //             Icons.shopping_basket_rounded,
          //             color: Color(0xFFFF9800),
          //             size: 20,
          //           ),
          //         ),
          //         SizedBox(width: 12),
          //         Expanded(
          //           child: Column(
          //             crossAxisAlignment: CrossAxisAlignment.start,
          //             children: [
          //               Text(
          //                 'Average Order Value',
          //                 style: GoogleFonts.inter(
          //                   fontSize: 14,
          //                   fontWeight: FontWeight.w500,
          //                   color: Color(0xFF333333),
          //                 ),
          //               ),
          //               SizedBox(height: 4),
          //               Text(
          //                 currentData['avgOrderValue'] as String,
          //                 style: GoogleFonts.inter(
          //                   fontSize: 20,
          //                   fontWeight: FontWeight.w700,
          //                   color: Color(0xFFE59737),
          //                 ),
          //               ),
          //             ],
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),

          // Items Sold Header
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(16, 0, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Items Sold',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF333333),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${itemsSold.length} Items',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF666666),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Items Sold List
          Expanded(
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(16, 0, 16, 16),
              child: ListView(
                physics: BouncingScrollPhysics(),
                children: [
                  for (int i = 0; i < itemsSold.length; i++)
                    _buildItemCard(
                      name: itemsSold[i]['name'] as String,
                      quantity: itemsSold[i]['quantity'] as int,
                      revenue: itemsSold[i]['revenue'] as String,
                    ),
                ],
              ),
            ),
          ),

          // Simple Summary Footer
          // Container(
          //   decoration: BoxDecoration(
          //     color: Colors.white,
          //     boxShadow: [
          //       BoxShadow(
          //         color: Colors.black.withOpacity(0.1),
          //         blurRadius: 20,
          //         offset: Offset(0, -4),
          //       ),
          //     ],
          //   ),
          //   child: SafeArea(
          //     top: false,
          //     child: Padding(
          //       padding: EdgeInsetsDirectional.fromSTEB(16, 16, 16, 16),
          //       child: Column(
          //         crossAxisAlignment: CrossAxisAlignment.start,
          //         children: [
          //           Text(
          //             'Summary',
          //             style: GoogleFonts.inter(
          //               fontSize: 14,
          //               fontWeight: FontWeight.w500,
          //               color: Color(0xFF666666),
          //             ),
          //           ),
          //           SizedBox(height: 8),
          //           Text(
          //             '${currentData['orders']} Orders • ${itemsSold.length} Different Items',
          //             style: GoogleFonts.inter(
          //               fontSize: 12,
          //               fontWeight: FontWeight.w400,
          //               color: Color(0xFF999999),
          //             ),
          //           ),
          //         ],
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildPeriodTab(String label, int index) {
    bool isSelected = _selectedPeriod == label;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedPeriod = label;
          });
        },
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? Color(0xFFE59737) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : Color(0xFF666666),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Color(0xFFF0F0F0),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF333333),
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF666666),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard({
    required String name,
    required int quantity,
    required String revenue,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Color(0xFFF0F0F0),
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            // Item Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.fastfood_rounded,
                color: Color(0xFFE59737),
                size: 24,
              ),
            ),
            SizedBox(width: 16),

            // Item Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333),
                    ),
                  ),
                  SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Quantity: $quantity',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF666666),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Revenue
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  revenue,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFE59737),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Revenue',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF999999),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}