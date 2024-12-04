import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  Stream<QuerySnapshot> getChat(String groupId) {
    return _firestore
        .collection('groups')
        .doc(groupId)
        .collection('chat')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<DocumentSnapshot> getUserInfo(String userId) async {
    return _firestore.collection('users').doc(userId).get();
  }

  Future<void> uploadImageFromGallery(String groupId, String messageId) async {
    return uploadImage(groupId, messageId, ImageSource.gallery);
  }

  Future<void> uploadImageFromCamera(String groupId, String messageId) async {
    return uploadImage(groupId, messageId, ImageSource.camera);
  }

  Future<void> uploadImage(
      String groupId, String messageId, ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    final String userId = FirebaseAuth.instance.currentUser!.uid;

    if (pickedFile != null) {
      File file = File(pickedFile.path);
      try {
        // Upload to Firebase Storage
        TaskSnapshot snapshot = await _storage
            .ref('chat_images/$groupId/${DateTime.now().toIso8601String()}')
            .putFile(file);
        String downloadUrl = await snapshot.ref.getDownloadURL();

        // Save message to Firestore
        await _firestore
            .collection('groups')
            .doc(groupId)
            .collection('chat')
            .add({
          'imageUrl': downloadUrl,
          'messageId': messageId,
          'userId': userId,
          'timestamp': Timestamp.now(),
        });
      } catch (e) {
        print(e);
        // Handle upload error
      }
    } else {
      print('No image selected.');
      // Handle no image selected
    }
  }

  Future<void> precacheGroupImages(BuildContext context, String groupId) async {
    // Get the chat messages for the specific group
    QuerySnapshot<Map<String, dynamic>> chatSnapshot = await _firestore
        .collection('groups')
        .doc(groupId)
        .collection('chat')
        .get();

    // Iterate over the chat messages and store image URLs
    List<String> imageUrls = [];
    for (var chatDoc in chatSnapshot.docs) {
      Map<String, dynamic> chatData = chatDoc.data();
      if (chatData.containsKey('imageUrl')) {
        String imageUrl = chatData['imageUrl'];
        imageUrls.add(imageUrl);
      }
    }

    // Precache images outside of the loop
    for (var imageUrl in imageUrls) {
      precacheImage(CachedNetworkImageProvider(imageUrl), context);
    }
  }
}
