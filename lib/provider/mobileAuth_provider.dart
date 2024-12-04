import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import '../screens/home/homeTabBar.dart';
import '../screens/login/register_screen.dart';

import 'dart:io';

class MobileAuth extends ChangeNotifier {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool otpVisibility = false;
  String verificationID = "";
  String? latestImageUrl;

  Future initialize() async {
    await Firebase.initializeApp().whenComplete(() {
      print("completed");
    });
  }

  Future loginWithPhone(String phoneNumber) async {
    auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await auth.signInWithCredential(credential).then((value) {
          print("You are logged in successfully!");
        });
      },
      verificationFailed: (FirebaseAuthException e) {
        print(e.message);
      },
      codeSent: (String verificationId, int? resendToken) {
        otpVisibility = true;
        verificationID = verificationId;
        notifyListeners();
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  Future<void> createOrUpdateUser(String uid) async {
    try {
      await firestore.collection('users').doc(uid).set(
        {
          'userId': auth.currentUser?.uid,
          'createdAt': Timestamp.now(),
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      print('Fehler beim Erstellen/Aktualisieren des Benutzers: $e');
      throw e;
    }
  }

  Future<void> navigateBasedOnUsername(String uid, BuildContext context) async {
    // Überprüfen, ob das 'username' Feld gesetzt ist
    DocumentSnapshot userDoc =
        await firestore.collection('users').doc(uid).get();
    Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
    if (userDoc.exists && userData != null && userData['username'] != null) {
      // Wenn 'username' gesetzt ist, lenkt Benutzer zu HomeScreen um
      Fluttertoast.showToast(
          msg: "You are logged in successfully!!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.grey,
          textColor: Colors.black,
          fontSize: 16.0);
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomeScreen()));
    } else {
      // Andernfalls lenkt den Benutzer zur RegisterScreen um.
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => RegisterScreen()));
    }
  }

  // Im 'verifyOTP' Methode
  Future verifyOTP(String otp, BuildContext context) async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationID, smsCode: otp);

    await auth.signInWithCredential(credential).then((value) async {
      print("You are logged in successfully!");
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        print(currentUser.uid);
        // Benutzer in Firestore erstellen oder aktualisieren
        await createOrUpdateUser(currentUser.uid);
        Future.delayed(Duration.zero,
            () => navigateBasedOnUsername(currentUser.uid, context));
      }
    });
  }

  Future<void> updateUserProfile(
      String uid, String username, String? imagePath) async {
    try {
      String profileUrl;

      if (imagePath != null && imagePath.startsWith('http')) {
        // Wenn imagePath eine URL ist
        profileUrl = imagePath;
      } else if (imagePath != null) {
        // Wenn imagePath ein lokaler Dateipfad ist
        profileUrl = await uploadImageToFirebase(uid, imagePath);
      } else {
        // Wenn kein imagePath bereitgestellt wird = Standardpfad
        profileUrl = 'assets/images/user/user.png';
      }

      // Nutzerdaten in Firestore aktualisieren
      await firestore.collection('users').doc(uid).set(
        {
          'username': username,
          'profileImg': profileUrl,
          'updatedAt': Timestamp.now(),
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      print('Fehler beim Aktualisieren des Benutzerprofils: $e');
      throw e;
    }
  }

  Future<String> uploadImageToFirebase(String uid, String imagePath) async {
    File file = File(imagePath);

    if (!file.existsSync()) {
      print('Die Datei existiert nicht: $imagePath');
      throw Exception('Die Datei existiert nicht: $imagePath');
    }

    try {
      // Pfad für das Bild in Firebase Storage erstellen
      String filePath = 'images/$uid.png';
      await FirebaseStorage.instance.ref().child(filePath).putFile(file);
      // URL des Bildes abrufen
      String downloadUrl =
          await FirebaseStorage.instance.ref().child(filePath).getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Fehler beim Hochladen des Bildes: $e');
      throw e;
    }
  }

  Future<bool> isUsernameUnique(String username) async {
    final QuerySnapshot result = await firestore
        .collection('users')
        .where('username', isEqualTo: username)
        .limit(1)
        .get();
    final List<DocumentSnapshot> docs = result.docs;
    return docs.length ==
        0; // Wenn kein Dokument zurückgegeben wird, ist der Benutzername eindeutig.
  }

  Future logout() async {
    try {
      await auth.signOut();
    } catch (e) {
      print("Fehler beim Ausloggen: $e");
      throw e;
    }
  }
}
