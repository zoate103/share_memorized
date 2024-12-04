import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../../provider/mobileAuth_provider.dart';
import '../../style/colors.dart';
import '../../style/designSystem.dart';
import '../../widgets/custom_widgets.dart';
import '../home/homeTabBar.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController usernameController = TextEditingController();
  String? imagePath;

  void handleImageSelected(String? selectedPath) {
    setState(() {
      imagePath = selectedPath;
    });
  }

  Future<void> handleRegister() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      final mobileAuth = Provider.of<MobileAuth>(context, listen: false);
      String? imageUrl = mobileAuth.latestImageUrl;

      if (usernameController.text.isEmpty) {
        // Zeigt einen Fehler an, dass alle Felder ausgefüllt sein müssen
        print('Error: Alle Felder müssen ausgefüllt sein.');
        print('Username: ${usernameController.text}');
        Fluttertoast.showToast(
            msg: "Alle Felder müssen ausgefüllt sein.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.grey,
            textColor: Colors.white,
            fontSize: 16.0
        );
      } else if (!await mobileAuth.isUsernameUnique(usernameController.text)) {
        // Zeigt einen Fehler an, dass der Benutzername bereits verwendet wird.
        print('Error: Der Benutzername wird bereits verwendet.');
        print('Username: ${usernameController.text}');
        Fluttertoast.showToast(
            msg: "Der Benutzername wird bereits verwendet.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.grey,
            textColor: Colors.white,
            fontSize: 16.0
        );
      } else {
        await mobileAuth.updateUserProfile(
            uid,
            usernameController.text,
            imageUrl // Es ist in Ordnung, wenn imageUrl null ist.
        );

        // Nach erfolgreicher Registrierung zum HomeScreen navigieren
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      }
    } catch (e) {
      print('Fehler beim Registrieren: $e');
      print('Username: ${usernameController.text}');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          "Register",
          style: DesignSystem.appBarTitle,
        ),
        backgroundColor: backgroundColor,
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(10),
          child: Column(
            children: [
              CustomUserImagePicker(onImageSelected: handleImageSelected),
              CustomTextField(hintText: 'Username', controller: usernameController),
              const SizedBox(
                height: 15,
              ),
              const SizedBox(
                height: 30,
              ),
              CustomButton(
                text: "Register",
                onPressed: () {
                  handleRegister();
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
