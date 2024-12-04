import 'package:flutter/material.dart';
import 'package:memorize/screens/home/settings_screen.dart';

//UI Screens
import '../screens/home/add_screen.dart';
import '../screens/home/home_screen.dart';

class NavigationProvider with ChangeNotifier {
  int _selectedIndex = 1;

  final List<Widget> _widgetOptions = <Widget>[
    AddGroupTab(),
    HomeTab(),
    SettingsScreen(),
  ];

  List<String> _appBarTitles = ['Create Group', 'Home', 'Settings'];

  int get selectedIndex => _selectedIndex;

  String get currentTitle => _appBarTitles[_selectedIndex];

  Widget get currentScreen => _widgetOptions[_selectedIndex];

  void changeIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }
}
