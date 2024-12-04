import 'package:flutter/material.dart';
import 'package:memorize/provider/mobileAuth_provider.dart';
import 'package:memorize/screens/chat/kamera_shortcut_screen.dart';
import 'package:memorize/style/colors.dart';

import '../../style/designSystem.dart';
import '../../widgets/custom_widgets.dart';
import '../login/mobileLogin_screen.dart';
import '../settings/qr_scanner.dart';



class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    var appBarHeight = AppBar().preferredSize.height;
    var auth = MobileAuth(); // Instanz von MobileAuth erstellen
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30),
      child: ListView(
        children: [
          SizedBox(height: appBarHeight * 2,),
          CustomButton(
            text: "QR-Code",
            onPressed: () async {

                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => QRScanner()),
                );
            },
          ),
          SizedBox(height: 30),
          CustomButton(
            text: "Logout",
            onPressed: () async {
              try {
                await auth.logout(); // Abmelden
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => LoginWithPhone()),
                );
              } catch (e) {
                print("Fehler beim Abmelden: $e");
                // Handhabung des Fehlers, z.B. Anzeige einer Fehlermeldung
              }
            },
          ),
          SizedBox(height: 30),
          const Divider(
            height: 2,
            thickness: 1,
            endIndent: 0,
            color: whiteColor,
          ),
          SizedBox(height: 10),
          Center(child: Text(
            "Dev Tools",
            style: DesignSystem.header1,
          ),),
          SizedBox(height: 30),
          CustomButton(
            text: "Kamera Shortcut (TEST)",
            onPressed: () async {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => CameraShortcutScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}

