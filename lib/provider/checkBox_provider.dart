import 'package:flutter/material.dart';

class CheckboxNotifier with ChangeNotifier {
  bool _isChecked = false;

  bool get isChecked => _isChecked;

  void toggle() {
    _isChecked = !_isChecked;
    notifyListeners();
  }
}
