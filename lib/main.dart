import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:memorize/provider/add_member_provider.dart';
import 'package:memorize/provider/chat_provider.dart';
import 'package:memorize/provider/group_request_provider.dart';
import 'package:memorize/provider/permission_handler_provider.dart';
import 'package:memorize/provider/splashScreen_provider.dart';
import 'package:memorize/screens/chat/kamera_shortcut_screen.dart';
import 'package:memorize/screens/home/homeTabBar.dart';
import 'package:memorize/screens/splash/alpha_screen.dart';
import 'package:memorize/screens/splash/splash_screen.dart';
import 'package:memorize/style/colors.dart';
import 'package:provider/provider.dart';
import 'package:memorize/provider/mobileAuth_provider.dart';
import 'package:memorize/provider/navigation_provider.dart';
import 'package:memorize/provider/group_creation_provider.dart';
import 'package:memorize/provider/checkBox_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisiere Firebase zuerst


  // Enable offline persistence
  FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);

  runApp(MyApp());
}


class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<bool> _firstLaunch;

  @override
  void initState() {
    super.initState();
    _firstLaunch = _checkFirstLaunch();
  }

  Future<bool> _checkFirstLaunch() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstLaunch = prefs.getBool('first_launch') ?? true;
    if (isFirstLaunch) {
      await prefs.setBool('first_launch', false);
    }
    return isFirstLaunch;
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => QRScannerProvider()),
          ChangeNotifierProvider(create: (context) => SplashProvider()),
          ChangeNotifierProvider(create: (context) => NavigationProvider()),
          ChangeNotifierProvider(create: (context) => MobileAuth()),
          ChangeNotifierProvider(create: (context) => GroupImageUploadProvider()),
          ChangeNotifierProvider(create: (context) => GroupRequestProvider()),
          ChangeNotifierProvider(create: (context) => GroupProvider()),
          ChangeNotifierProvider(create: (context) => CheckboxNotifier()),
          ChangeNotifierProvider(create: (context) => PermissionHandlerProvider()),
          ChangeNotifierProvider(create: (context) => ChatProvider()),
        ],
        child: MaterialApp(
          title: 'Phone Auth Demo',
          theme: ThemeData(
            useMaterial3: true,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue)
                .copyWith(background: backgroundColor),
            iconTheme: IconThemeData(
              color: whiteColor,
            ),
          ),
          home: FutureBuilder<bool>(
            future: _firstLaunch,
            builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else {
                if (snapshot.data == true) {
                  return AlphaScreen();
                } else {
                  return SplashScreen();
                }
              }
            },
          ),
          routes: {
            '/home': (context) => HomeScreen(),
            '/CameraShortcutScreen': (context) => CameraShortcutScreen(),
          },
        ));
  }
}

