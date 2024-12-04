import 'package:flutter/material.dart';
import 'package:flutter_shortcuts/flutter_shortcuts.dart';
import 'package:provider/provider.dart';


import 'package:memorize/widgets/custom_widgets.dart';

import '../../provider/splashScreen_provider.dart';
import '../chat/kamera_shortcut_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final FlutterShortcuts flutterShortcuts = FlutterShortcuts();
  bool _permissionsChecked = false;

  @override
  void initState() {
    super.initState();
    _initializeShortcuts();
    _checkPermissionsAndNavigate();
  }

  void _initializeShortcuts() {
    flutterShortcuts.initialize(debug: true);
    flutterShortcuts.listenAction((String incomingAction) {
      if (incomingAction == 'CameraShortcutAction') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => CameraShortcutScreen()),
        );
      }
    });
    _setShortcutItem();
  }


  void _setShortcutItem() async {
    await flutterShortcuts.setShortcutItems(
      shortcutItems: <ShortcutItem>[
        const ShortcutItem(
          id: "camera_shortcut_id",
          action: 'CameraShortcutAction',
          shortLabel: 'Camera Shortcut',
          icon: 'assets/images/logo/Logo.png',
          shortcutIconAsset: ShortcutIconAsset.flutterAsset,
        ),
      ],
    );
  }

  Future<void> _checkPermissionsAndNavigate() async {
    await Provider.of<SplashProvider>(context, listen: false).checkPermissionsAndNavigate(context);
    setState(() {
      _permissionsChecked = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/logo/Logo.png'),
            if (!_permissionsChecked)
              CircularProgressIndicator(),
            if (_permissionsChecked)
              CustomButton(
                text: "Try again",
                onPressed: _checkPermissionsAndNavigate,
              ),
          ],
        ),
      ),
    );
  }
}