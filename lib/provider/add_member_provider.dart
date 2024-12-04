import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../screens/home/homeTabBar.dart';

class QRScannerProvider with ChangeNotifier {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  late QRViewController controller;

  void onQRViewCreated(BuildContext context, QRViewController controller) {
    this.controller = controller;

    controller.resumeCamera(); // Kamera fortsetzen

    controller.scannedDataStream.listen((scanData) async {
      final groupId = scanData
          .code; // Hier gehen wir davon aus, dass der gescannte Code die Gruppen-ID ist.
      final userId = FirebaseAuth.instance.currentUser!.uid;

      print('Scanned group ID: $groupId'); // Zum Debuggen

      // Überprüfe, ob der Benutzer bereits in der Gruppe ist
      final firestore = FirebaseFirestore.instance;
      QuerySnapshot querySnapshot = await firestore
          .collection('users')
          .doc(userId)
          .collection('groups')
          .where('groupId', isEqualTo: groupId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Der Benutzer ist bereits in der Gruppe
        Fluttertoast.showToast(
            msg: "Sie sind bereits Mitglied dieser Gruppe!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      } else {
        // Füge den Benutzer zur Gruppe hinzu
        await firestore
            .collection('users')
            .doc(userId)
            .collection('groups')
            .add(
          {
            'groupId': groupId,
          },
        );

        DocumentReference groupDocRef =
            await firestore.collection('groups').doc(groupId);
        await groupDocRef.update(
          {
            'member': FieldValue.arrayUnion([userId]),
          },
        );

        Fluttertoast.showToast(
            msg: "Erfolgreich zur Gruppe hinzugefügt!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0);
      }

      // Kamera anhalten und zur Startseite zurückkehren
      controller.pauseCamera();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );

      notifyListeners();
    });
  }

  void disposeController() {
    controller.dispose();
  }
}
