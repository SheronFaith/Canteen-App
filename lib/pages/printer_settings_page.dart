import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:google_fonts/google_fonts.dart';

import '../printing/thermal_printer_service.dart';

class PrinterSettingsPage extends StatefulWidget {
  const PrinterSettingsPage({super.key});

  @override
  State<PrinterSettingsPage> createState() => _PrinterSettingsPageState();
}

class _PrinterSettingsPageState extends State<PrinterSettingsPage> {
  ThermalConnectionType _selectedType = ThermalConnectionType.bluetooth;

  List<BluetoothDevice> _bondedDevices = <BluetoothDevice>[];
  String? _selectedBluetoothAddress;

  List<UsbPrinterDeviceInfo> _usbDevices = <UsbPrinterDeviceInfo>[];
  String? _selectedUsbDeviceId;

  bool _loadingDevices = false;
  bool _loadingUsbDevices = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _init() async {
    await ThermalPrinterService.instance.loadSettings();

    if (!mounted) return;

    setState(() {
      final type = ThermalPrinterService.instance.connectionType;
      _selectedType = (type == ThermalConnectionType.usb)
          ? ThermalConnectionType.usb
          : ThermalConnectionType.bluetooth;

      _selectedBluetoothAddress =
          ThermalPrinterService.instance.bluetoothAddress;
      _selectedUsbDeviceId = ThermalPrinterService.instance.usbDeviceId;
    });

    await _refreshBondedDevices();
    await _refreshUsbDevices();
  }

  Future<void> _refreshBondedDevices() async {
    final allowed = await ThermalPrinterService.instance
        .ensureBluetoothPermissions(requireScan: false);
    if (!allowed) {
      if (!mounted) return;
      _showSnack(
        ThermalPrinterService.instance.lastErrorMessage ??
            'Bluetooth permission required',
      );
      setState(() {
        _bondedDevices = <BluetoothDevice>[];
        _loadingDevices = false;
      });
      return;
    }

    setState(() {
      _loadingDevices = true;
    });

    List<BluetoothDevice> devices = <BluetoothDevice>[];
    try {
      devices =
          await ThermalPrinterService.instance.getBondedBluetoothDevices();
    } catch (e) {
      // Extra safety: never crash if native throws.
      // ignore: avoid_print
      print('[PrinterSettings] getBondedDevices failed: $e');
      if (mounted) {
        _showSnack('Bluetooth permission required');
      }
      devices = <BluetoothDevice>[];
    }

    if (!mounted) return;

    setState(() {
      _bondedDevices = devices;
      _loadingDevices = false;

      final selected = _selectedBluetoothAddress;
      if (selected != null && selected.isNotEmpty) {
        final stillExists = devices.any((d) => d.address == selected);
        if (!stillExists) {
          _selectedBluetoothAddress = null;
        }
      }
    });

    if (devices.isEmpty && mounted) {
      _showSnack(
        'No paired printers found. Pair the printer in Android Bluetooth settings first.',
      );
    }
  }

  Future<void> _refreshUsbDevices() async {
    setState(() {
      _loadingUsbDevices = true;
    });

    final devices = await ThermalPrinterService.instance.getUsbDevices();

    if (!mounted) return;

    setState(() {
      _usbDevices = devices;
      _loadingUsbDevices = false;

      final selected = _selectedUsbDeviceId;
      if (selected != null) {
        final stillExists = devices.any((d) => d.id == selected);
        if (!stillExists) {
          _selectedUsbDeviceId = null;
        }
      }
    });

    if (devices.isEmpty && mounted) {
      _showSnack(
        'No USB printer detected. This printer may not be USB-Serial (bulk USB printer class).',
      );
    }
  }

  Future<void> _refreshAll() async {
    await _refreshBondedDevices();
    await _refreshUsbDevices();
  }

  void _showSnack(String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: GoogleFonts.inter(
          color: Colors.black87, 
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: Colors.white, 
      behavior: SnackBarBehavior.floating,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );
}

  Future<void> _onTypeChanged(ThermalConnectionType? value) async {
    if (value == null) return;

    setState(() {
      _selectedType = value;
    });

    await ThermalPrinterService.instance.selectPrinterType(value);

    if (!mounted) return;

    if (value == ThermalConnectionType.bluetooth) {
      await _refreshBondedDevices();
    }
    if (value == ThermalConnectionType.usb) {
      await _refreshUsbDevices();
    }
  }

  Future<void> _connectBluetooth() async {
    final address = _selectedBluetoothAddress;
    if (address == null || address.isEmpty) {
      _showSnack('Select a paired Bluetooth printer');
      return;
    }

    final allowed = await ThermalPrinterService.instance
        .ensureBluetoothPermissions(requireScan: true);
    if (!allowed) {
      if (!mounted) return;
      _showSnack(
        ThermalPrinterService.instance.lastErrorMessage ??
            'Bluetooth permission required',
      );
      return;
    }

    await ThermalPrinterService.instance.selectBluetoothPrinter(address);
    final ok = await ThermalPrinterService.instance
        .connectBluetooth(macAddress: address);

    if (!mounted) return;

    _showSnack(
      ok
          ? '✓ Bluetooth printer connected'
          : (ThermalPrinterService.instance.lastErrorMessage ??
              'Bluetooth connect failed'),
    );
  }

  Future<void> _testBluetooth() async {
    final address = _selectedBluetoothAddress;
    if (address != null && address.isNotEmpty) {
      await ThermalPrinterService.instance.selectBluetoothPrinter(address);
    }

    final ok = await ThermalPrinterService.instance.testPrint();

    if (!mounted) return;

    _showSnack(
      ok
          ? '✓ Test print started'
          : (ThermalPrinterService.instance.lastErrorMessage ??
              'Printer not connected'),
    );
  }

  Future<void> _connectUsb() async {
    final deviceId = _selectedUsbDeviceId;
    if (deviceId == null) {
      _showSnack('Select a USB printer');
      return;
    }

    final device = _usbDevices.where((d) => d.id == deviceId).firstOrNull;
    if (device == null) {
      _showSnack('Selected USB device not found');
      return;
    }

    final ok = await ThermalPrinterService.instance.connectUsb(device: device);
    if (!mounted) return;

    _showSnack(
      ok
          ? '✓ USB printer connected'
          : (ThermalPrinterService.instance.lastErrorMessage ??
              'USB connect failed'),
    );
  }

  Future<void> _testUsb() async {
    final deviceId = _selectedUsbDeviceId;
    if (deviceId == null) {
      _showSnack('Select a USB printer');
      return;
    }

    final device = _usbDevices.where((d) => d.id == deviceId).firstOrNull;
    if (device == null) {
      _showSnack('Selected USB device not found');
      return;
    }

    await ThermalPrinterService.instance.connectUsb(device: device);
    final ok = await ThermalPrinterService.instance.testPrint();

    if (!mounted) return;

    _showSnack(
      ok
          ? '✓ Test print started'
          : (ThermalPrinterService.instance.lastErrorMessage ??
              'Printer not connected'),
    );
  }

  Widget _buildCard({
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: child,
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF333333),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFFE59737)),
          ),
          const SizedBox(height: 12),
          Text(
            'Loading devices...',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF666666),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.print_outlined,
            color: const Color(0xFFCCCCCC),
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF999999),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
       body: Column(
       children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_rounded,
                      size: 20,
                      color: Color(0xFF333333),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Printer Settings',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Manage printer connection',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF666666),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        Expanded(
          child: RefreshIndicator(
          onRefresh: _refreshAll,
          color: const Color(0xFFE59737),
          child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Printer Type Section
              _buildSectionTitle('Printer Connection Type'),
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Bluetooth Option
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _onTypeChanged(ThermalConnectionType.bluetooth),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: _selectedType == ThermalConnectionType.bluetooth
                                    ? const Color(0xFFE59737).withOpacity(0.1)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _selectedType == ThermalConnectionType.bluetooth
                                      ? const Color(0xFFE59737)
                                      : const Color(0xFFE0E0E0),
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.bluetooth,
                                    color: _selectedType == ThermalConnectionType.bluetooth
                                        ? const Color(0xFFE59737)
                                        : const Color(0xFF666666),
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Bluetooth',
                                          style: GoogleFonts.inter(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: _selectedType == ThermalConnectionType.bluetooth
                                                ? const Color(0xFFE59737)
                                                : const Color(0xFF333333),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Wireless thermal printers',
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                            color: const Color(0xFF666666),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (_selectedType == ThermalConnectionType.bluetooth)
                                    Icon(
                                      Icons.check_circle,
                                      color: const Color(0xFFE59737),
                                      size: 20,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        
                        // USB Option
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _onTypeChanged(ThermalConnectionType.usb),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: _selectedType == ThermalConnectionType.usb
                                    ? const Color(0xFFE59737).withOpacity(0.1)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _selectedType == ThermalConnectionType.usb
                                      ? const Color(0xFFE59737)
                                      : const Color(0xFFE0E0E0),
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.usb,
                                    color: _selectedType == ThermalConnectionType.usb
                                        ? const Color(0xFFE59737)
                                        : const Color(0xFF666666),
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'USB',
                                          style: GoogleFonts.inter(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: _selectedType == ThermalConnectionType.usb
                                                ? const Color(0xFFE59737)
                                                : const Color(0xFF333333),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Wired thermal printers',
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                            color: const Color(0xFF666666),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (_selectedType == ThermalConnectionType.usb)
                                    Icon(
                                      Icons.check_circle,
                                      color: const Color(0xFFE59737),
                                      size: 20,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Select your printer connection type to proceed',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF999999),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Bluetooth Printer Section
              if (_selectedType == ThermalConnectionType.bluetooth) ...[
                _buildSectionTitle('Bluetooth Printer'),
                _buildCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Paired Devices',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      if (_loadingDevices)
                        _buildLoadingState()
                      else if (_bondedDevices.isEmpty)
                        _buildEmptyState(
                          'No paired Bluetooth printers found.\n\nPair your printer in Android Bluetooth settings first, then refresh.'
                        )
                      else
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FA),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListView.builder(
                            padding: const EdgeInsets.all(8),
                            itemCount: _bondedDevices.length,
                            itemBuilder: (context, index) {
                              final device = _bondedDevices[index];
                              final isSelected = _selectedBluetoothAddress == device.address;
                              
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedBluetoothAddress = device.address;
                                  });
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFFE59737).withOpacity(0.1)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFFE59737)
                                          : const Color(0xFFEEEEEE),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.print_outlined,
                                        color: isSelected
                                            ? const Color(0xFFE59737)
                                            : const Color(0xFF666666),
                                        size: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              device.name ?? 'Unknown Device',
                                              style: GoogleFonts.inter(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: isSelected
                                                    ? const Color(0xFFE59737)
                                                    : const Color(0xFF333333),
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              device.address,
                                              style: GoogleFonts.inter(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w400,
                                                color: const Color(0xFF666666),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (isSelected)
                                        Icon(
                                          Icons.check_circle_rounded,
                                          color: const Color(0xFFE59737),
                                          size: 18,
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      
                      const SizedBox(height: 20),
                      
                      // Buttons Row
                      Row(
                        children: [
                          // Refresh Button
                          Expanded(
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFE0E0E0),
                                  width: 1.5,
                                ),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: _refreshBondedDevices,
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.refresh_rounded,
                                          color: const Color(0xFF666666),
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Refresh',
                                          style: GoogleFonts.inter(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF666666),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          
                          // Connect Button
                          Expanded(
                            flex: 2,
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
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
                                    color: const Color(0xFFE59737).withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: _connectBluetooth,
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.link_rounded,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Connect Printer',
                                          style: GoogleFonts.inter(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Test Print Button
                      Container(
                        height: 48,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F9FF),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF1976D2).withOpacity(0.2),
                            width: 1.5,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: _testBluetooth,
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.print_rounded,
                                    color: const Color(0xFF1976D2),
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Test Print',
                                    style: GoogleFonts.inter(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF1976D2),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // USB Printer Section
              if (_selectedType == ThermalConnectionType.usb) ...[
                _buildSectionTitle('USB Printer'),
                _buildCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Connected Devices',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      if (_loadingUsbDevices)
                        _buildLoadingState()
                      else if (_usbDevices.isEmpty)
                        _buildEmptyState(
                          'No USB printer detected.\n\nConnect the printer via OTG/USB and power it ON.\n\nIf it still shows nothing, this printer may not be USB-Serial.'
                        )
                      else
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FA),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListView.builder(
                            padding: const EdgeInsets.all(8),
                            itemCount: _usbDevices.length,
                            itemBuilder: (context, index) {
                              final device = _usbDevices[index];
                              final isSelected = _selectedUsbDeviceId == device.id;
                              final subtitle = 'VID: ${device.vendorId} • PID: ${device.productId}';
                              
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedUsbDeviceId = device.id;
                                  });
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFFE59737).withOpacity(0.1)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFFE59737)
                                          : const Color(0xFFEEEEEE),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.usb_rounded,
                                        color: isSelected
                                            ? const Color(0xFFE59737)
                                            : const Color(0xFF666666),
                                        size: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              device.name,
                                              style: GoogleFonts.inter(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: isSelected
                                                    ? const Color(0xFFE59737)
                                                    : const Color(0xFF333333),
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              subtitle,
                                              style: GoogleFonts.inter(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w400,
                                                color: const Color(0xFF666666),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (isSelected)
                                        Icon(
                                          Icons.check_circle_rounded,
                                          color: const Color(0xFFE59737),
                                          size: 18,
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      
                      const SizedBox(height: 20),
                      
                      // Buttons Row
                      Row(
                        children: [
                          // Refresh Button
                          Expanded(
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFE0E0E0),
                                  width: 1.5,
                                ),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: _refreshUsbDevices,
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.refresh_rounded,
                                          color: const Color(0xFF666666),
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Refresh',
                                          style: GoogleFonts.inter(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF666666),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          
                          // Connect Button
                          Expanded(
                            flex: 2,
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
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
                                    color: const Color(0xFFE59737).withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: _connectUsb,
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.link_rounded,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Connect Printer',
                                          style: GoogleFonts.inter(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Test Print Button
                      Container(
                        height: 48,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F9FF),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF1976D2).withOpacity(0.2),
                            width: 1.5,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: _testUsb,
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.print_rounded,
                                    color: const Color(0xFF1976D2),
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Test Print',
                                    style: GoogleFonts.inter(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF1976D2),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Help Text
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: const Color(0xFF1976D2),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Ensure your thermal printer is powered ON and properly connected before attempting to connect.',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF666666),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
               ],
              ), 
            ), 
          ),     
        ),  
      ],
    ),   
  ); 
  } 
} 

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    if (!iterator.moveNext()) return null;
    return iterator.current;
  }
}