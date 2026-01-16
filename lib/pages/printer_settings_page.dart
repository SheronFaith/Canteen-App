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

    // Debug logs.
    // ignore: avoid_print
    print('[PrinterSettings] Bonded devices count: ${devices.length}');

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

    // Debug logs.
    // ignore: avoid_print
    print('[PrinterSettings] USB devices count: ${devices.length}');

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
      SnackBar(content: Text(message)),
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
          ? 'Bluetooth printer connected'
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
          ? 'Test print started'
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
          ? 'USB printer connected'
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
          ? 'Test print started'
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
            color: Colors.black.withAlpha((0.05 * 255).round()),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: const Color(0xFFF0F0F0), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF333333),
        elevation: 0,
        title: Text(
          'Printer Settings',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF333333),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshAll,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Printer Type',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 12),
              _buildCard(
                child: RadioGroup<ThermalConnectionType>(
                  groupValue: _selectedType,
                  onChanged: (value) => _onTypeChanged(value),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RadioListTile<ThermalConnectionType>(
                        value: ThermalConnectionType.bluetooth,
                        title: Text(
                          'Bluetooth',
                          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                        ),
                      ),
                      RadioListTile<ThermalConnectionType>(
                        value: ThermalConnectionType.usb,
                        title: Text(
                          'USB',
                          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_selectedType == ThermalConnectionType.bluetooth) ...[
                Text(
                  'Bluetooth Printer',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 12),
                _buildCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Paired Devices',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF666666),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_loadingDevices)
                        const Center(child: CircularProgressIndicator())
                      else if (_bondedDevices.isEmpty)
                        Text(
                          'No paired Bluetooth printers found. Pair your printer in Bluetooth settings.',
                          style: GoogleFonts.inter(
                              fontSize: 12, color: const Color(0xFF666666)),
                        )
                      else
                        SizedBox(
                          height: 180,
                          child: RadioGroup<String>(
                            groupValue: _selectedBluetoothAddress,
                            onChanged: (value) {
                              setState(() {
                                _selectedBluetoothAddress = value;
                              });
                            },
                            child: ListView.builder(
                              itemCount: _bondedDevices.length,
                              itemBuilder: (context, index) {
                                final d = _bondedDevices[index];
                                final title = d.name ?? 'Unknown';
                                return RadioListTile<String>(
                                  value: d.address,
                                  title: Text(
                                    title,
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: Text(
                                    d.address,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: const Color(0xFF666666),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _connectBluetooth,
                              child: const Text('Connect'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: _testBluetooth,
                          child: const Text('Test Print'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (_selectedType == ThermalConnectionType.usb) ...[
                Text(
                  'USB Printer',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 12),
                _buildCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Connected Devices',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF666666),
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_loadingUsbDevices)
                        const Center(child: CircularProgressIndicator())
                      else if (_usbDevices.isEmpty)
                        Text(
                          'No USB printer detected. Connect the printer via OTG/USB and power it ON.\n\nIf it still shows nothing, this printer may not be USB-Serial (bulk USB printer class).',
                          style: GoogleFonts.inter(
                              fontSize: 12, color: const Color(0xFF666666)),
                        )
                      else
                        SizedBox(
                          height: 180,
                          child: RadioGroup<String>(
                            groupValue: _selectedUsbDeviceId,
                            onChanged: (value) {
                              setState(() {
                                _selectedUsbDeviceId = value;
                              });
                            },
                            child: ListView.builder(
                              itemCount: _usbDevices.length,
                              itemBuilder: (context, index) {
                                final d = _usbDevices[index];
                                final title = d.name;
                                final subtitle = <String>[
                                  'VID: ${d.vendorId}',
                                  'PID: ${d.productId}',
                                ].join(' • ');

                                return RadioListTile<String>(
                                  value: d.id,
                                  title: Text(
                                    title,
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: Text(
                                    subtitle,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: const Color(0xFF666666),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _connectUsb,
                              child: const Text('Connect'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: _testUsb,
                          child: const Text('Test Print'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
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
