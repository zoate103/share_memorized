import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:memorize/provider/navigation_provider.dart';
import 'package:memorize/screens/home/add_screen.dart';
import 'package:memorize/style/colors.dart';
import 'package:memorize/style/designSystem.dart';
import 'package:provider/provider.dart';
import 'package:flutter_floating_bottom_bar/flutter_floating_bottom_bar.dart';

import 'package:flutter/material.dart';

import '../../provider/group_request_provider.dart';



class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      Provider.of<GroupRequestProvider>(context, listen: false).setUserId(user.uid);
    }
    return Consumer<NavigationProvider>(
      builder: (context, navigationProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              navigationProvider.currentTitle,
              style: DesignSystem.appBarTitle,
            ),
            backgroundColor: backgroundColor,
          ),
          body: Center(child: navigationProvider.currentScreen),
          bottomNavigationBar: BottomBar(
              bottom: 50,
              width: 200,
              barColor: whiteColor,
              borderRadius: BorderRadius.circular(100),
              child: Container(
                child: Padding(
                  padding: const EdgeInsets.all(0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: Icon(Icons.add,
                            color: navigationProvider.selectedIndex == 0
                                ? mainColor
                                : blackColor),
                        onPressed: () => navigationProvider.changeIndex(0),
                      ),
                      IconButton(
                        icon: Icon(Icons.house_outlined,
                            color: navigationProvider.selectedIndex == 1
                                ? mainColor
                                : blackColor),
                        onPressed: () => navigationProvider.changeIndex(1),
                      ),
                      IconButton(
                        icon: Icon(Icons.settings_outlined,
                            color: navigationProvider.selectedIndex == 2
                                ? mainColor
                                : blackColor),
                        onPressed: () => navigationProvider.changeIndex(2),
                      ),
                    ],
                  ),
                ),
              ),
              body: (context, controller) => Center(
                child: navigationProvider.currentScreen,
              )),
        );
      },
    );
  }
}