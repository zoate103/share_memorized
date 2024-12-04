import 'package:flutter/material.dart';

class AppBarAnimationProvider extends ChangeNotifier {
  late AnimationController _animationController;

  Animation<double>? animation;

  void initializeAnimation(TickerProvider tickerProvider) {
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: tickerProvider,
    );
    animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.fastOutSlowIn,
    );
    notifyListeners();
  }

  void disposeAnimation() {
    _animationController.dispose();
  }

  void toggleAppBar() {
    if (_animationController.status == AnimationStatus.completed) {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }
  }
}
