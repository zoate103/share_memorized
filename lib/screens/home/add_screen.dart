import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:memorize/style/designSystem.dart';
import 'package:memorize/widgets/custom_widgets.dart';
import 'package:provider/provider.dart';

import '../../provider/group_request_provider.dart';
import '../../provider/group_creation_provider.dart';

class AddGroupTab extends StatelessWidget {
  AddGroupTab({Key? key});

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  final TextEditingController groupNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var appBarHeight = AppBar().preferredSize.height;
    return  Padding(
      padding: const EdgeInsets.only(left: 30, right: 30, bottom: 120),
      child: ListView(
        children: [
          SizedBox(height: appBarHeight * 2,),
          CustomImagePicker(), //Gruppenbild
          SizedBox(height: 10.0),
          Text("Information:", style: DesignSystem.header1,),
          SizedBox(height: 10.0),
          CustomTextField(hintText: "Group Name", controller: groupNameController),
          SizedBox(height: 10.0),
          CustomTextArea(hintText: "Description", controller: descriptionController),
          SizedBox(height: 15.0),
          Text("Share Options:", style: DesignSystem.header1,),
          SizedBox(height: 10.0),
          CustomCheckBox(text: "QR-Code", icon: Icon(Icons.qr_code_2, color: Colors.white)),
          SizedBox(height: 15.0),
          CustomButton(
            text: "Create",
            onPressed: () async {
              print('Button clicked');
              // Zugriff auf die Provider
              final imageUploadProvider = Provider.of<GroupImageUploadProvider>(context, listen: false);
              final groupProvider = Provider.of<GroupProvider>(context, listen: false);
              final groupRequestProvider = Provider.of<GroupRequestProvider>(context, listen: false);

              // Überprüfung, ob ein Bild ausgewählt wurde
              if (imageUploadProvider.image != null) {
                await groupProvider.createGroup(
                  groupName: groupNameController.text,
                  description: descriptionController.text,
                  groupImage: imageUploadProvider.image!,
                  groupRequestProvider: groupRequestProvider,  // Hinzufügen der fehlenden Parameter
                );
                imageUploadProvider.resetImage();
              } else {
                print('Kein Bild ausgewählt');
              }
            },
          ),
        ],
      ),
    );
  }
}
