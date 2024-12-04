import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../screens/home/homeTabBar.dart';
import '../screens/login/mobileLogin_screen.dart';
import '../screens/login/register_screen.dart';
import '../provider/permission_handler_provider.dart';

class SplashProvider with ChangeNotifier {
  final permissionHandlerProvider = PermissionHandlerProvider();
  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<int> _checkUser() async {
    User? user = auth.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (userDoc.exists) {
        final data = userDoc.data();
        if (data != null &&
            data['username'] != null &&
            data['username'].trim().isNotEmpty) {
          return 2; // User is logged in and has username set
        } else {
          return 1; // User is logged in but has no username
        }
      }
    }
    return 0; // User is not logged in
  }

  Future<void> checkPermissionsAndNavigate(BuildContext context) async {
    await permissionHandlerProvider.checkPermissions();
    if (permissionHandlerProvider.allPermissionsGranted) {
      _navigateBasedOnUser(context);
    }
  }

  Future<void> _navigateBasedOnUser(BuildContext context) async {
    final status = await _checkUser();
    switch (status) {
      case 0:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => LoginWithPhone()));
        break;
      case 1:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => RegisterScreen()));
        break;
      case 2:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomeScreen()));
        break;
      default:
        break;
    }
  }
}
