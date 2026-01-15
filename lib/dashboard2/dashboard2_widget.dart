import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dashboard2_model.dart';
export 'dashboard2_model.dart';
import '/create_bill/create_bill_widget.dart';
import '/menumanager/menumanager_widget.dart';
import '../order/order_widget.dart';
import '/revenue/revenue_widget.dart';

/// Staff Portal Dashboard
class Dashboard2Widget extends StatefulWidget {
  const Dashboard2Widget({super.key});

  static String routeName = 'Dashboard2';
  static String routePath = '/dashboard2';

  @override
  State<Dashboard2Widget> createState() => _Dashboard2WidgetState();
}

class _Dashboard2WidgetState extends State<Dashboard2Widget> {
  late Dashboard2Model _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => Dashboard2Model());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
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
        body: SafeArea(
          top: true,
          child: Column(
            children: [
              // ================= HEADER =================
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                padding: EdgeInsetsDirectional.fromSTEB(24, 16, 24, 24),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Abiruchi Food Works',
                          style: GoogleFonts.inter(
                            color: Color(0xFF333333),
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ================= DASHBOARD GRID =================
              Expanded(
                child: Container(
                  color: Color(0xFFF8F9FA),
                  padding: EdgeInsetsDirectional.fromSTEB(24, 32, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quick Actions',
                        style: GoogleFonts.inter(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF333333),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Select an option to continue',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF666666),
                        ),
                      ),
                      SizedBox(height: 32),

                      Expanded(
                        child: GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                          physics: BouncingScrollPhysics(),
                          children: [
                            _buildActionCard(
                              title: 'Create Bill',
                              icon: Icons.receipt_long_rounded,
                              subtitle: 'Generate new invoice',
                              color: Color(0xFF00BCD4),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const CreateBillWidget(),
                                  ),
                                );
                              },
                            ),

                           _buildActionCard(
                              title: 'Scan Order',
                              icon: Icons.qr_code_scanner_rounded,
                              subtitle: 'Scan QR code',
                              color: Color(0xFFFF9800),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const OrderWidget(),
                                  ),
                                );
                              },
                            ),

                           _buildActionCard(
                              title: 'Menu Manager',
                              icon: Icons.restaurant_menu_rounded,
                              subtitle: 'Manage menu items',
                              color: Color(0xFF9C27B0),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const MenumanagerWidget(),
                                  ),
                                );
                              },
                            ),

                            _buildActionCard(
                              title: 'Revenue',
                              icon: Icons.currency_rupee_rounded,
                              subtitle: 'View analytics',
                              color: Color(0xFF4CAF50),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const RevenueWidget(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= ACTION CARD =================
  Widget _buildActionCard({
  required String title,
  required IconData icon,
  required String subtitle,
  required Color color,
  VoidCallback? onTap,
}) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 15,
                offset: Offset(0, 5),
              ),
            ],
          ),
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
              SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Color(0xFF666666),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
