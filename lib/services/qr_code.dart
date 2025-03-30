import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:scan/scan.dart';

class QRViewExample extends StatefulWidget {
  const QRViewExample({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;
  final ImagePicker _picker = ImagePicker();

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  Future<void> _scanFromGallery() async {
    try {
      final XFile? pickedFile =
          await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final String? qrData = await Scan.parse(pickedFile.path);
        if (qrData != null && qrData.isNotEmpty) {
          _processQRData(qrData);
        } else {
          _showErrorSnackBar('No QR code found in the image');
        }
      }
    } catch (e) {
      _showErrorSnackBar('Error scanning from gallery: $e');
    }
  }

  void _processQRData(String qrData) {
    try {
      final Map<String, dynamic> itemData = json.decode(qrData);
      // Process the data
      print(itemData);
      // Navigate back with result
      Navigator.pop(context, itemData);
    } catch (e) {
      _showErrorSnackBar('Invalid QR code format: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Scanner'),
        actions: [
          if (Platform.isIOS)
            IconButton(
              icon: const Icon(Icons.photo_library),
              onPressed: _scanFromGallery,
              tooltip: 'Scan from gallery',
            ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Theme.of(context).colorScheme.primary,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: MediaQuery.of(context).size.width * 0.8,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: (result != null)
                  ? Text(
                      'Barcode Type: ${result!.format}   Data: ${result!.code}')
                  : const Text('Scan a code'),
            ),
          )
        ],
      ),
      floatingActionButton: Platform.isIOS
          ? FloatingActionButton(
              onPressed: _scanFromGallery,
              tooltip: 'Pick from gallery',
              child: const Icon(Icons.photo_library),
            )
          : null,
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });
      if (scanData.code != null && scanData.code!.isNotEmpty) {
        _processQRData(scanData.code!);
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
