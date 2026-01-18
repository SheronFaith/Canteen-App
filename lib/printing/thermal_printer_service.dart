import 'dart:typed_data';
import 'dart:io';

import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_pos_printer_platform_image_3/flutter_pos_printer_platform_image_3.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/bill.dart';
import 'receipt_builder.dart';

enum ThermalConnectionType { none, bluetooth, usb }

class ThermalPrinterService {
  ThermalPrinterService._();

  static final ThermalPrinterService instance = ThermalPrinterService._();

  // Required persistence keys (new settings screen).
  static const _prefsKeyType = 'printer_type';
  static const _prefsKeyBluetoothAddress = 'bluetooth_address';
  static const _prefsKeyUsbId = 'usb_device_id';
  static const _prefsKeyUsbVendorId = 'usb_vendor_id';
  static const _prefsKeyUsbProductId = 'usb_product_id';
  static const _prefsKeyUsbName = 'usb_device_name';

  // Back-compat keys used by the previous setup screen.
  static const _legacyPrefsKeyBtMac = 'printer_bt_mac';

  ThermalConnectionType _connectionType = ThermalConnectionType.none;

  String? _lastError;

  BluetoothConnection? _btConnection;

  String? _bluetoothMac;

  UsbPrinterDeviceInfo? _usbDevice;
  bool _usbConnected = false;

  ThermalConnectionType get connectionType => _connectionType;

  String? get lastErrorMessage => _lastError;

  String? get bluetoothAddress => _bluetoothMac;

  String? get usbDeviceId => _usbDevice?.id;

  bool get isConnected {
    if (_connectionType == ThermalConnectionType.bluetooth) {
      return _btConnection?.isConnected ?? false;
    }
    if (_connectionType == ThermalConnectionType.usb) {
      return _usbConnected;
    }
    return false;
  }

  Future<SharedPreferences> _prefs() => SharedPreferences.getInstance();

  Future<void> _persistSelection() async {
    final prefs = await _prefs();
    if (_connectionType == ThermalConnectionType.none) {
      await prefs.remove(_prefsKeyType);
    } else {
      await prefs.setString(_prefsKeyType, _connectionType.name);
    }
    if (_bluetoothMac != null) {
      await prefs.setString(_prefsKeyBluetoothAddress, _bluetoothMac!);
      // Back-compat
      await prefs.setString(_legacyPrefsKeyBtMac, _bluetoothMac!);
    }

    final usb = _usbDevice;
    if (usb != null) {
      await prefs.setString(_prefsKeyUsbId, usb.id);
      await prefs.setString(_prefsKeyUsbVendorId, usb.vendorId);
      await prefs.setString(_prefsKeyUsbProductId, usb.productId);
      await prefs.setString(_prefsKeyUsbName, usb.name);
    }
  }

  Future<void> _loadSelection() async {
    final prefs = await _prefs();

    final type = prefs.getString(_prefsKeyType);
    final bt = prefs.getString(_prefsKeyBluetoothAddress) ??
        prefs.getString(_legacyPrefsKeyBtMac);
    final usbId = prefs.getString(_prefsKeyUsbId);
    final usbVid = prefs.getString(_prefsKeyUsbVendorId);
    final usbPid = prefs.getString(_prefsKeyUsbProductId);
    final usbName = prefs.getString(_prefsKeyUsbName);

    if (bt != null && bt.isNotEmpty) {
      _bluetoothMac = bt;
    }
    if (type == ThermalConnectionType.bluetooth.name) {
      _connectionType = ThermalConnectionType.bluetooth;
    } else if (type == ThermalConnectionType.usb.name) {
      _connectionType = ThermalConnectionType.usb;
    } else {
      if (type != null) {
        await prefs.remove(_prefsKeyType);
      }
      _connectionType = ThermalConnectionType.none;
    }

    if (usbId != null && usbVid != null && usbPid != null && usbName != null) {
      _usbDevice = UsbPrinterDeviceInfo(
        id: usbId,
        vendorId: usbVid,
        productId: usbPid,
        name: usbName,
      );
    }
  }

  Future<void> loadSettings() => _loadSelection();

  Future<void> selectPrinterType(ThermalConnectionType type) async {
    // Selecting a type should not crash; close any active transport.
    await disconnect();
    _connectionType = type;
    await _persistSelection();
  }

  /// Ensures required Bluetooth runtime permissions are granted.
  ///
  /// On Android 12+ (API 31+) the OS enforces runtime permissions:
  /// - BLUETOOTH_CONNECT for reading bonded devices / connecting.
  /// - BLUETOOTH_SCAN for operations that may cancel discovery internally.
  ///
  /// This method never throws; it sets [lastErrorMessage] on failure.
  Future<bool> ensureBluetoothPermissions({bool requireScan = false}) async {
    if (!Platform.isAndroid) return true;

    _lastError = null;

    try {
      // ignore: avoid_print
      print('[Printer] OS: ${Platform.operatingSystemVersion}');

      final connectStatus = await Permission.bluetoothConnect.status;
      // ignore: avoid_print
      print('[Printer] BLUETOOTH_CONNECT status: $connectStatus');

      var scanStatus = PermissionStatus.granted;
      if (requireScan) {
        scanStatus = await Permission.bluetoothScan.status;
        // ignore: avoid_print
        print('[Printer] BLUETOOTH_SCAN status: $scanStatus');
      }

      final needsConnect = !connectStatus.isGranted;
      final needsScan = requireScan && !scanStatus.isGranted;

      PermissionStatus connectResult = connectStatus;
      PermissionStatus scanResult = scanStatus;

      if (needsConnect) {
        connectResult = await Permission.bluetoothConnect.request();
        // ignore: avoid_print
        print('[Printer] BLUETOOTH_CONNECT request result: $connectResult');
      }
      if (needsScan) {
        scanResult = await Permission.bluetoothScan.request();
        // ignore: avoid_print
        print('[Printer] BLUETOOTH_SCAN request result: $scanResult');
      }

      final ok =
          connectResult.isGranted && (!requireScan || scanResult.isGranted);
      if (ok) return true;

      _lastError = 'Bluetooth permission required';

      final permanentlyDenied = connectResult.isPermanentlyDenied ||
          (requireScan && scanResult.isPermanentlyDenied);
      if (permanentlyDenied) {
        await openAppSettings();
      }

      return false;
    } catch (e) {
      _lastError = 'Bluetooth permission check failed: $e';
      return false;
    }
  }

  Future<List<BluetoothDevice>> getBondedBluetoothDevices() async {
    _lastError = null;
    try {
      final permitted = await ensureBluetoothPermissions(requireScan: false);
      if (!permitted) {
        return <BluetoothDevice>[];
      }

      final enabled = await FlutterBluetoothSerial.instance.isEnabled;
      if (enabled != true) {
        final requested = await FlutterBluetoothSerial.instance.requestEnable();
        if (requested != true) {
          _lastError = 'Bluetooth is disabled';
          return <BluetoothDevice>[];
        }
      }

      final devices = await FlutterBluetoothSerial.instance.getBondedDevices();

      // Debug logs to understand why listing is empty.
      // ignore: avoid_print
      print('[Printer] Bonded devices count: ${devices.length}');
      for (final d in devices) {
        // ignore: avoid_print
        print('[Printer] Bonded: ${d.name ?? 'Unknown'} (${d.address})');
      }

      return devices;
    } catch (e) {
      _lastError = 'Unable to read paired Bluetooth devices: $e';
      return <BluetoothDevice>[];
    }
  }

  Future<List<UsbPrinterDeviceInfo>> getUsbDevices() async {
    _lastError = null;
    try {
      final found = <UsbPrinterDeviceInfo>[];

      final sub = PrinterManager.instance
          .discovery(type: PrinterType.usb)
          .listen((device) {
        final String? vid = device.vendorId;
        final String? pid = device.productId;
        final name = device.name;
        if (name.isEmpty) return;

        // Some platforms/devices may not provide VID/PID. We require them
        // to connect reliably.
        if (vid == null || pid == null || vid.isEmpty || pid.isEmpty) {
          return;
        }

        final id = UsbPrinterDeviceInfo.buildId(
          vendorId: vid,
          productId: pid,
          name: name,
        );
        if (found.any((d) => d.id == id)) return;
        found.add(
          UsbPrinterDeviceInfo(
            id: id,
            vendorId: vid,
            productId: pid,
            name: name,
          ),
        );
      });

      // USB discovery may be a stream that never closes. Collect briefly.
      await Future.delayed(const Duration(milliseconds: 900));
      await sub.cancel();

      // Debug logs.
      // ignore: avoid_print
      print('[Printer] USB printers count: ${found.length}');
      for (final d in found) {
        // ignore: avoid_print
        print(
          '[Printer] USB: vid=${d.vendorId} pid=${d.productId} name=${d.name}',
        );
      }

      return found;
    } catch (e) {
      _lastError = 'Unable to list USB printers: $e';
      return <UsbPrinterDeviceInfo>[];
    }
  }

  Future<bool> connectBluetooth({String? macAddress}) async {
    await _loadSelection();

    _lastError = null;

    final permitted = await ensureBluetoothPermissions(requireScan: true);
    if (!permitted) {
      _lastError ??= 'Bluetooth permission required';
      return false;
    }

    final mac = macAddress ?? _bluetoothMac;
    if (mac == null || mac.isEmpty) {
      _lastError = 'No Bluetooth printer selected';
      return false;
    }

    // Persist selection as soon as the user chooses it.
    _bluetoothMac = mac;
    await _persistSelection();

    try {
      final enabled = await FlutterBluetoothSerial.instance.isEnabled;
      if (enabled != true) {
        final requested = await FlutterBluetoothSerial.instance.requestEnable();
        if (requested != true) {
          _lastError = 'Bluetooth is disabled';
          return false;
        }
      }

      // Validate that the address is still bonded.
      final bonded = await getBondedBluetoothDevices();
      final exists = bonded.any((d) => d.address == mac);
      if (!exists) {
        _lastError =
            'Selected printer is not paired. Pair it in Bluetooth settings.';
        return false;
      }
    } catch (e) {
      _lastError = 'Bluetooth unavailable: $e';
      _connectionType = ThermalConnectionType.none;
      return false;
    }

    try {
      await _btConnection?.close();
    } catch (_) {}
    _btConnection = null;

    try {
      final conn = await BluetoothConnection.toAddress(mac);
      _btConnection = conn;
      _connectionType = ThermalConnectionType.bluetooth;
      await _persistSelection();
      return conn.isConnected;
    } catch (e) {
      _lastError = 'Failed to connect to Bluetooth printer: $e';
      _connectionType = ThermalConnectionType.none;
      return false;
    }
  }

  Future<void> selectBluetoothPrinter(String macAddress) async {
    _bluetoothMac = macAddress;
    _connectionType = ThermalConnectionType.bluetooth;
    await _persistSelection();
  }

  Future<void> selectUsbDevice(String deviceId) async {
    _lastError = null;
    final parsed = UsbPrinterDeviceInfo.tryParse(deviceId);
    if (parsed == null) {
      _lastError = 'Invalid USB printer selection';
      return;
    }
    _usbDevice = parsed;
    _connectionType = ThermalConnectionType.usb;
    await _persistSelection();
  }

  Future<bool> connectUsb({UsbPrinterDeviceInfo? device}) async {
    await _loadSelection();

    _lastError = null;

    final target = device ?? _usbDevice;
    if (target == null) {
      _lastError = 'No USB printer selected';
      return false;
    }

    // Persist selection early.
    _usbDevice = target;
    await _persistSelection();

    try {
      await PrinterManager.instance.connect(
        type: PrinterType.usb,
        model: UsbPrinterInput(
          name: target.name,
          productId: target.productId,
          vendorId: target.vendorId,
        ),
      );
      _usbConnected = true;
      _connectionType = ThermalConnectionType.usb;
      await _persistSelection();
      return true;
    } catch (e) {
      _usbConnected = false;
      _connectionType = ThermalConnectionType.none;
      _lastError = 'Failed to connect to USB printer: $e';
      return false;
    }
  }

  Future<void> disconnect() async {
    if (_connectionType == ThermalConnectionType.bluetooth) {
      try {
        await _btConnection?.close();
      } catch (_) {}
      _btConnection = null;
    }
    if (_connectionType == ThermalConnectionType.usb) {
      try {
        await PrinterManager.instance.disconnect(type: PrinterType.usb);
      } catch (_) {}
      _usbConnected = false;
    }
    _connectionType = ThermalConnectionType.none;
    await _persistSelection();
  }

  Future<bool> testPrint() async {
    final bytes = await _buildTestReceiptBytes();
    return printBytes(bytes);
  }

  Future<bool> printBill(Bill bill) async {
    final receiptBytes = await buildEscPosReceipt(bill);
    return printBytes(receiptBytes);
  }

  Future<bool> printBytes(Uint8List bytes) async {
    _lastError = null;

    if (_connectionType == ThermalConnectionType.bluetooth) {
      final conn = _btConnection;
      if (conn == null || !conn.isConnected) {
        final ok = await connectBluetooth();
        if (!ok) {
          _lastError ??= 'Printer not connected';
          return false;
        }
      }

      final current = _btConnection;
      if (current == null || !current.isConnected) {
        _lastError = 'Printer not connected';
        return false;
      }

      try {
        current.output.add(bytes);
        await current.output.allSent;
        return true;
      } catch (e) {
        _lastError = 'Failed to send data to printer';
        return false;
      }
    }

    if (_connectionType == ThermalConnectionType.usb) {
      if (!_usbConnected) {
        final ok = await connectUsb();
        if (!ok) return false;
      }
      try {
        await PrinterManager.instance.send(type: PrinterType.usb, bytes: bytes);
        return true;
      } catch (e) {
        _lastError = 'Failed to send data to USB printer: $e';
        return false;
      }
    }

    _lastError = 'No printer connected';
    return false;
  }

  Future<Uint8List> _buildTestReceiptBytes() async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);

    final out = <int>[];
    out.addAll(generator.text(
      ' Abiruchi Food Work ',
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
        fontType: PosFontType.fontB,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
      linesAfter: 1,
    ));
    out.addAll(generator.text(
      'Test Print',
      styles: const PosStyles(align: PosAlign.center, bold: true),
      linesAfter: 1,
    ));
    out.addAll(generator.cut());

    return Uint8List.fromList(out);
  }
}

class UsbPrinterDeviceInfo {
  final String id;
  final String vendorId;
  final String productId;
  final String name;

  const UsbPrinterDeviceInfo({
    required this.id,
    required this.vendorId,
    required this.productId,
    required this.name,
  });

  static String buildId({
    required String vendorId,
    required String productId,
    required String name,
  }) {
    return '$vendorId:$productId:$name';
  }

  static UsbPrinterDeviceInfo? tryParse(String id) {
    final parts = id.split(':');
    if (parts.length < 3) return null;
    final vid = parts[0];
    final pid = parts[1];
    final name = parts.sublist(2).join(':');
    return UsbPrinterDeviceInfo(
      id: id,
      vendorId: vid,
      productId: pid,
      name: name,
    );
  }
}
