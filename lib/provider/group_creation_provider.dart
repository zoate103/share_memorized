import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter/material.dart';
import 'package:memorize/style/colors.dart';

import 'group_request_provider.dart';

class GroupImageUploadProvider with ChangeNotifier {
  File? _image;

  File? get image => _image;

  final picker = ImagePicker();

  Future pickImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final croppedFile = await ImageCropper().cropImage(
          sourcePath: pickedFile.path,
          aspectRatioPresets: Platform.isAndroid
              ? [
                  /*CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.ratio4x3,*/
                  CropAspectRatioPreset.ratio16x9
                ]
              : [
                  /*CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.ratio4x3,*/
                  CropAspectRatioPreset.ratio16x9
                ],
          uiSettings: [
            AndroidUiSettings(
                toolbarTitle: 'Bild zuschneiden',
                toolbarColor: blackColor,
                toolbarWidgetColor: mainColor,
                statusBarColor: blackColor,
                initAspectRatio: CropAspectRatioPreset.ratio16x9,
                hideBottomControls: true,
                lockAspectRatio: false),
            IOSUiSettings(
              title: 'Bild zuschneiden',
            )
          ]);
      if (croppedFile != null) {
        _image = File(croppedFile.path);
        notifyListeners();
      }
    }
  }

  void resetImage() {
    _image = null;
    notifyListeners();
  }
}

class GroupProvider with ChangeNotifier {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;

  Future createGroup({
    required String groupName,
    required String description,
    required File groupImage,
    required GroupRequestProvider groupRequestProvider,
  }) async {
    try {
      User? currentUser = auth.currentUser;

      if (currentUser != null) {
        // Bild hochladen
        TaskSnapshot snapshot = await storage
            .ref('groupImages/${groupName}_${currentUser.uid}')
            .putFile(groupImage);
        String imageUrl = await snapshot.ref.getDownloadURL();

        // Gruppe erstellen
        DocumentReference groupDocRef =
            await firestore.collection('groups').add(
          {
            'groupName': groupName,
            'description': description,
            'admin': currentUser.uid,
            'member': [currentUser.uid],
            'imageUrl': imageUrl,
            // 'qrData' wird hier noch nicht hinzugefügt, weil die 'groupId' noch nicht existiert
          },
        );

// Speichern Sie die groupId und qrData im Gruppendokument
        await firestore.collection('groups').doc(groupDocRef.id).update({
          'groupId': groupDocRef.id,
          'qrData': groupDocRef.id,
          // füge 'qrData' hinzu und setze es auf den Wert von 'groupId'
        });

        // Erstellen Sie die Chat-Collection für die Gruppe
        await firestore
            .collection('groups')
            .doc(groupDocRef.id)
            .collection('chat')
            .add({});

        // Fügen Sie die Gruppen-ID dem Benutzer hinzu
        await firestore
            .collection('users')
            .doc(currentUser.uid)
            .collection('groups')
            .add(
          {
            'groupId': groupDocRef.id, // Fügen Sie die Gruppen-ID hinzu
          },
        );

        // Aktualisiere die Gruppen des Benutzers
        groupRequestProvider.getUserGroups();
      }
    } catch (e) {
      print('Fehler beim Erstellen der Gruppe: $e');
      throw e;
    }
  }
}
