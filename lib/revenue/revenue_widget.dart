import '/flutter_flow/flutter_flow_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import '../models/bill.dart';
import '../services/bill_repository.dart';
import '../services/revenue_service.dart';

class RevenueWidget extends StatefulWidget {
  const RevenueWidget({super.key});

  static String routeName = 'Revenue';
  static String routePath = '/revenue';

  @override
  State<RevenueWidget> createState() => _RevenueWidgetState();
}

class _RevenueWidgetState extends State<RevenueWidget> {
  String _selectedPeriod = 'Today'; // Today, This Week, This Month
  DateTime? _anchorDate;

  final RevenueService _revenueService = RevenueService();

  @override
  Widget build(BuildContext context) {
    final billsBox = Hive.box<Bill>(BillRepository.billsBoxName);

    return ValueListenableBuilder<Box<Bill>>(
      valueListenable: billsBox.listenable(),
      builder: (context, box, child) {
        final periodData = _anchorDate == null
            ? _revenueService.buildPeriodData()
            : _revenueService.buildPeriodDataForAnchor(_anchorDate!);

        final currentData = _selectedPeriod == 'Months'
            ? _revenueService.emptyPeriodData()
            : (periodData[_selectedPeriod] ??
                _revenueService.emptyPeriodData());

        final monthlyTotals = _selectedPeriod == 'Months'
            ? _revenueService.buildMonthlyTotals()
            : const <Map<String, dynamic>>[];

        final itemsSold =
            (currentData['itemsSold'] as List<dynamic>?) ?? <dynamic>[];
        final totalItemsSold = (currentData['totalItemsSold'] as int?) ?? 0;

        final anchorLabel = _anchorDate == null
            ? null
            : DateFormat('dd MMM yyyy').format(_anchorDate!);

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
                                    anchorLabel == null
                                        ? 'Sales performance overview'
                                        : 'Based on $anchorLabel',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF666666),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                final now = DateTime.now();
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: _anchorDate ?? now,
                                  firstDate: DateTime(2020, 1, 1),
                                  lastDate: DateTime(now.year + 1, 12, 31),
                                );
                                if (picked == null) return;
                                setState(() {
                                  _anchorDate = picked;
                                  if (_selectedPeriod == 'Months') {
                                    _selectedPeriod = 'This Month';
                                  }
                                });
                              },
                              onLongPress: () {
                                setState(() {
                                  _anchorDate = null;
                                });
                              },
                              child: Container(
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
                      _buildPeriodTab('Months', 3),
                    ],
                  ),
                ),
              ),

              // Main Stats Row
              if (_selectedPeriod != 'Months')
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

              // Items Sold Header
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(16, 0, 16, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedPeriod == 'Months'
                          ? 'Monthly Revenue'
                          : 'Items Sold',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF333333),
                      ),
                    ),
                    if (_selectedPeriod != 'Months')
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$totalItemsSold Items',
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
                  child: _selectedPeriod == 'Months'
                      ? (monthlyTotals.isEmpty
                          ? Center(
                              child: Text(
                                'No monthly data yet',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF999999),
                                ),
                              ),
                            )
                          : ListView(
                              physics: BouncingScrollPhysics(),
                              children: [
                                for (int i = 0; i < monthlyTotals.length; i++)
                                  _buildMonthlyCard(
                                    month: monthlyTotals[i]['month'] as String,
                                    revenue:
                                        monthlyTotals[i]['revenue'] as String,
                                    orders: monthlyTotals[i]['orders'] as int,
                                  ),
                              ],
                            ))
                      : (itemsSold.isEmpty
                          ? Center(
                              child: Text(
                                'No sales in this period',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF999999),
                                ),
                              ),
                            )
                          : ListView(
                              physics: BouncingScrollPhysics(),
                              children: [
                                for (int i = 0; i < itemsSold.length; i++)
                                  _buildItemCard(
                                    name: itemsSold[i]['name'] as String,
                                    quantity: itemsSold[i]['quantity'] as int,
                                    revenue: itemsSold[i]['revenue'] as String,
                                  ),
                              ],
                            )),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _periodTabLabel(String periodKey) {
    final anchor = _anchorDate;
    if (anchor == null) return periodKey;

    switch (periodKey) {
      case 'Today':
        return DateFormat('dd MMM').format(anchor);
      case 'This Week':
        final dayStart = DateTime(anchor.year, anchor.month, anchor.day);
        final weekStart =
            dayStart.subtract(Duration(days: dayStart.weekday - 1));
        final weekEnd = weekStart.add(const Duration(days: 6));
        final startLabel = DateFormat('dd MMM').format(weekStart);
        final endLabel = DateFormat('dd MMM').format(weekEnd);
        return '$startLabel-$endLabel';
      case 'This Month':
        return DateFormat('MMM yyyy').format(anchor);
      default:
        return periodKey;
    }
  }

  Widget _buildPeriodTab(String label, int index) {
    bool isSelected = _selectedPeriod == label;
    final displayLabel = _periodTabLabel(label);
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  displayLabel,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : Color(0xFF666666),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMonthlyCard({
    required String month,
    required String revenue,
    required int orders,
  }) {
    return Container(
      margin: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 12),
      padding: EdgeInsetsDirectional.fromSTEB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  month,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF333333),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '$orders Orders',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF666666),
                  ),
                ),
              ],
            ),
          ),
          Text(
            revenue,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF333333),
            ),
          ),
        ],
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
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
