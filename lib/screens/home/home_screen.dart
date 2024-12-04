import 'package:flutter/material.dart';

import '../../widgets/custom_widgets.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({Key? key});

  @override
  Widget build(BuildContext context) {
    var appBarHeight = AppBar().preferredSize.height;
    return  ListView(
          children: [
            SizedBox(height: appBarHeight * 2,),
            GroupContainer(
              text: "Favorites:",
              child: GroupListHorizontal(),
            ),
            SizedBox(height: 15,),
            GroupContainer(
              text: "Active groups:",
              child: GroupListHorizontal(),
            ),
            SizedBox(height: 15,),
          ],
    );
  }
}
