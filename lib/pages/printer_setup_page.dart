import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:google_fonts/google_fonts.dart';

import '../printing/thermal_printer_service.dart';

class PrinterSetupPage extends StatefulWidget {
  const PrinterSetupPage({super.key});

  @override
  State<PrinterSetupPage> createState() => _PrinterSetupPageState();
}

class _PrinterSetupPageState extends State<PrinterSetupPage> {
  ThermalConnectionType _connectionType =
      ThermalPrinterService.instance.connectionType;

  Future<void> _connectBluetooth() async {
    final devices =
        await ThermalPrinterService.instance.getBondedBluetoothDevices();
    if (!mounted) {
      return;
    }
    if (devices.isEmpty) {
      _showSnack(
          'No paired Bluetooth printers found. Pair your printer in Bluetooth settings.');
      return;
    }

    final selected = await _selectBluetoothDevice(devices);
    if (selected == null) {
      return;
    }

    await ThermalPrinterService.instance
        .selectBluetoothPrinter(selected.address);

    final ok = await ThermalPrinterService.instance.connectBluetooth(
      macAddress: selected.address,
    );
    setState(() {
      _connectionType = ThermalPrinterService.instance.connectionType;
    });
    _showSnack(
      ok
          ? 'Bluetooth printer connected'
          : (ThermalPrinterService.instance.lastErrorMessage ??
              'Bluetooth connect failed'),
    );
  }

  Future<void> _connectUsb() async {
    final devices = await ThermalPrinterService.instance.getUsbDevices();
    if (!mounted) {
      return;
    }
    if (devices.isEmpty) {
      _showSnack(
        'No USB printer detected. This printer may not be USB-Serial (bulk USB printer class).',
      );
      return;
    }

    final selected = await _selectUsbDevice(devices);
    if (selected == null) {
      return;
    }

    final ok =
        await ThermalPrinterService.instance.connectUsb(device: selected);
    setState(() {
      _connectionType = ThermalPrinterService.instance.connectionType;
    });
    _showSnack(
      ok
          ? 'USB printer connected'
          : (ThermalPrinterService.instance.lastErrorMessage ??
              'USB connect failed'),
    );
  }

  Future<void> _testPrint() async {
    final ok = await ThermalPrinterService.instance.testPrint();
    _showSnack(
      ok
          ? 'Test print started'
          : (ThermalPrinterService.instance.lastErrorMessage ??
              'Printer not connected'),
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<BluetoothDevice?> _selectBluetoothDevice(
      List<BluetoothDevice> devices) {
    return showDialog<BluetoothDevice>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text(
            'Select Bluetooth Printer',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700),
          ),
          children: [
            for (final d in devices)
              SimpleDialogOption(
                onPressed: () => Navigator.pop(context, d),
                child: Text(
                  '${d.name ?? 'Unknown'} (${d.address})',
                  style: GoogleFonts.inter(fontSize: 13),
                ),
              ),
          ],
        );
      },
    );
  }

  Future<UsbPrinterDeviceInfo?> _selectUsbDevice(
      List<UsbPrinterDeviceInfo> devices) {
    String labelFor(UsbPrinterDeviceInfo d) {
      return '${d.name} (VID: ${d.vendorId}, PID: ${d.productId})';
    }

    return showDialog<UsbPrinterDeviceInfo>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text(
            'Select USB Device',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700),
          ),
          children: [
            for (final d in devices)
              SimpleDialogOption(
                onPressed: () => Navigator.pop(context, d),
                child: Text(
                  labelFor(d),
                  style: GoogleFonts.inter(fontSize: 13),
                ),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusText = switch (_connectionType) {
      ThermalConnectionType.none => 'Not connected',
      ThermalConnectionType.bluetooth => 'Connected (Bluetooth)',
      ThermalConnectionType.usb => 'Connected (USB)',
    };

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF333333),
        elevation: 0,
        title: Text(
          'Printer Setup',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF333333),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Status: $statusText',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF666666),
              ),
            ),
            const SizedBox(height: 16),
            _buildCard(
              title: 'Bluetooth Printer',
              subtitle: 'Connect via Bluetooth',
              icon: Icons.bluetooth_rounded,
              color: const Color(0xFF2196F3),
              buttonText: 'Connect',
              onPressed: _connectBluetooth,
            ),
            const SizedBox(height: 12),
            _buildCard(
              title: 'USB Printer',
              subtitle: 'Connect via USB',
              icon: Icons.usb_rounded,
              color: const Color(0xFF9C27B0),
              buttonText: 'Connect',
              onPressed: _connectUsb,
            ),
            const SizedBox(height: 12),
            _buildCard(
              title: 'Test Print',
              subtitle: 'Print a sample receipt',
              icon: Icons.print_rounded,
              color: const Color(0xFF4CAF50),
              buttonText: 'Test Print',
              onPressed: _testPrint,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).round()),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: const Color(0xFFF0F0F0), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withAlpha((0.1 * 255).round()),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF333333),
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
            const SizedBox(width: 12),
            TextButton(
              onPressed: onPressed,
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFE59737),
              ),
              child: Text(
                buttonText,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
