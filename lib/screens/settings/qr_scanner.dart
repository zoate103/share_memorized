import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../../provider/add_member_provider.dart';
import '../home/homeTabBar.dart';

class QRScanner extends StatefulWidget {
  @override
  _QRScannerState createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner> {
  @override
  Widget build(BuildContext context) {
    final qrProvider = Provider.of<QRScannerProvider>(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
            }
        ),
      ),
      body: QRView(
        key: qrProvider.qrKey,
        onQRViewCreated: (controller) => qrProvider.onQRViewCreated(context, controller),
      ),
    );
  }

  @override
  void dispose() {
    Provider.of<QRScannerProvider>(context, listen: false).disposeController();
    super.dispose();
  }
}
