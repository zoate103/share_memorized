import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:memorize/style/designSystem.dart';
import 'package:provider/provider.dart';
import '../../provider/group_request_provider.dart';
import 'package:path/path.dart';

import '../../style/colors.dart';
import 'chat_screen.dart';

class CameraShortcutScreen extends StatefulWidget {
  CameraShortcutScreen({Key? key}) : super(key: key);

  @override
  _CameraShortcutScreenState createState() => _CameraShortcutScreenState();
}

class _CameraShortcutScreenState extends State<CameraShortcutScreen> {
  XFile? _image;
  final ImagePicker _picker = ImagePicker();
  String? _selectedGroupId;

  @override
  Widget build(BuildContext context) {
    GroupRequestProvider groupProvider = Provider.of<GroupRequestProvider>(context);
    List<Map<String, dynamic>> groups = groupProvider.groupDetails;

    return Scaffold(
      appBar: AppBar(
        title: Text('Snapshot', style: DesignSystem.appBarTitle,),
        backgroundColor: blackColor,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: (_image != null)
                ? Center(child: Image.file(File(_image!.path), fit: BoxFit.fill,))
                : Center(child: Container(child: Text("Create a Snapshot", style: DesignSystem.header2))),
          ),
          DropdownButton<String>(
            dropdownColor: blackColor,
            hint: Text('Wähle eine Gruppe', style: TextStyle(color: whiteColor)),
            value: _selectedGroupId,
            onChanged: (String? newValue) {
              setState(() {
                _selectedGroupId = newValue;
              });
            },
            items: groups.map<DropdownMenuItem<String>>((group) {
              return DropdownMenuItem<String>(
                value: group['groupId'],
                child: Text(group['groupName'], style: TextStyle(color: whiteColor)),
              );
            }).toList(),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: backgroundColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.camera, color: mainColor, size: 40,),
              onPressed: () async {
                _image = await _picker.pickImage(source: ImageSource.camera);
                setState(() {});
              },
            ),
            IconButton(
              icon: Icon(Icons.cloud_upload, color: mainColor, size: 40,),
              onPressed: _selectedGroupId != null && _image != null ? () async {
                await uploadImageToFirebase(context);
              } : null,
            ),
          ],
        ),
      ),
    );
  }

  Future uploadImageToFirebase(BuildContext context) async {
    String fileName = basename(_image!.path);
    FirebaseStorage storage = FirebaseStorage.instance;

    Reference ref = storage.ref().child('chat_images/$_selectedGroupId/$fileName');
    UploadTask uploadTask = ref.putFile(File(_image!.path));
    await uploadTask;

    ref.getDownloadURL().then((fileURL) async {
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(_selectedGroupId)
          .collection('chat')
          .add({
        'imageUrl': fileURL,
        'userId': FirebaseAuth.instance.currentUser!.uid,
        'timestamp': Timestamp.now(),
      });

      GroupRequestProvider groupProvider = Provider.of<GroupRequestProvider>(context, listen: false);
      List<Map<String, dynamic>> groups = groupProvider.groupDetails;
      Map<String, dynamic> group = groups.firstWhere((g) => g['groupId'] == _selectedGroupId);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(group: group),
        ),
      );
    });
  }
}

