import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionHandlerProvider with ChangeNotifier {
  Map<Permission, PermissionStatus> _statuses = {};

  Map<Permission, PermissionStatus> get statuses => _statuses;

  Future<void> requestPermissions() async {
    _statuses = await [
      Permission.camera,
      Permission.location,
    ].request();

    notifyListeners();
  }

  bool get allPermissionsGranted {
    return _statuses[Permission.camera]?.isGranted == true &&
        _statuses[Permission.location]?.isGranted == true;
  }

  Future<void> checkPermissions() async {
    await requestPermissions();
    notifyListeners();
  }
}
