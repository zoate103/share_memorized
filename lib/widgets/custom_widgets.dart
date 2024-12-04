import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:memorize/style/colors.dart';
import 'package:memorize/style/designSystem.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../provider/checkBox_provider.dart';
import '../provider/group_creation_provider.dart';

import '../provider/group_request_provider.dart';
import '../provider/mobileAuth_provider.dart';
import '../screens/chat/chat_screen.dart';

class GroupListHorizontal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<GroupRequestProvider>(
      builder: (context, provider, child) {
        return ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: provider.groupDetails.length,
          itemBuilder: (BuildContext context, int index) {
            var group = provider.groupDetails[index];
            return LayoutBuilder(
              builder: (context, constraints) {
                final containerWidth = constraints.maxHeight * (16 / 9);
                return GestureDetector(
                  onTap: () {
                    print("Selected group: ${group['groupName']}");
                    print("Group ID: ${group['groupId']}");
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(group: group),
                      ),
                    );
                  },
                  child: FutureBuilder(
                    future: precacheImage(
                        NetworkImage(group['imageUrl'] as String), context),
                    // Hier wird das Bild vorgeladen
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return Container(
                          width: containerWidth,
                          height: constraints.maxHeight,
                          child: Stack(
                            children: [
                              CachedNetworkImage(
                                imageUrl: group['imageUrl'] as String,
                                colorBlendMode: BlendMode.darken,
                                color: Colors.black.withOpacity(0.5),
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Center(
                                    child: CircularProgressIndicator(
                                        color: mainColor)),
                                errorWidget: (context, url, error) =>
                                    Center(child: Icon(Icons.error)),
                                imageBuilder: (context, imageProvider) =>
                                    Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25),
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                    color: whiteColor,
                                    image: DecorationImage(
                                      image: imageProvider,
                                      fit: BoxFit.cover,
                                      colorFilter: ColorFilter.mode(
                                        Colors.black.withOpacity(0.5),
                                        BlendMode.darken,
                                      ),
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      Align(
                                        alignment: Alignment.bottomLeft,
                                        child: Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text(
                                            group['groupName'] as String,
                                            style: DesignSystem.header3,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 8,
                                        right: 8,
                                        child: Icon(
                                          Icons.qr_code_sharp,
                                          size: 20,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Positioned(
                                        top: 8,
                                        left: 8,
                                        child: Row(
                                          children: [
                                            Text(
                                              group['member'].length.toString(),
                                              // Anzahl der Gruppenmitglieder
                                              style: DesignSystem.memberCount,
                                            ),
                                            const SizedBox(width: 5),
                                            const Icon(
                                              Icons.people,
                                              size: 15,
                                              color: Colors.white,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return SizedBox(); //Center(child: CircularProgressIndicator(color: mainColor)); // Placeholder während des Ladens
                      }
                    },
                  ),
                );
              },
            );
          },
          separatorBuilder: (BuildContext context, int index) {
            return SizedBox(width: 10);
          },
        );
      },
    );
  }
}

class GroupContainer extends StatelessWidget {
  final String text;
  final Widget child;
  final double borderRadius;
  final double sidePadding;
  final VoidCallback? onRightTextTap;

  GroupContainer(
      {super.key,
      required this.child,
      required this.text,
      this.onRightTextTap,
      this.borderRadius = 25.0,
      this.sidePadding = 15.0});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 30.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                text,
                style: DesignSystem.header1,
              ),
              InkWell(
                onTap: onRightTextTap,
                child: Padding(
                  padding: EdgeInsets.only(right: 30.0),
                  child: Text(
                    "Show all",
                    style: DesignSystem.showAllButton,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10.0),
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final containerHeight =
                constraints.maxHeight < 130.0 ? constraints.maxHeight : 130.0;

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: sidePadding),
              child: Container(
                height: containerHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(borderRadius),
                  color: highlightColor,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: constraints.maxWidth - (2 * sidePadding),
                    minHeight: containerHeight,
                    maxWidth: constraints.maxWidth - (2 * sidePadding),
                    maxHeight: containerHeight,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: child,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class CustomUserImagePicker extends StatefulWidget {
  final ValueChanged<String> onImageSelected;

  const CustomUserImagePicker({Key? key, required this.onImageSelected})
      : super(key: key);

  @override
  _CustomUserImagePickerState createState() => _CustomUserImagePickerState();
}

class _CustomUserImagePickerState extends State<CustomUserImagePicker> {
  String? _selectedImagePath;
  String _defaultImagePath = 'assets/images/user/user.png';

  @override
  Widget build(BuildContext context) {
    final mobileAuth = Provider.of<MobileAuth>(context, listen: false);
    return GestureDetector(
      onTap: () async {
        final picker = ImagePicker();
        final pickedFile = await picker.pickImage(source: ImageSource.gallery);

        if (pickedFile != null) {
          final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
          final downloadUrl =
              await mobileAuth.uploadImageToFirebase(uid, pickedFile.path);
          setState(() {
            _selectedImagePath = downloadUrl;
            mobileAuth.latestImageUrl = downloadUrl;
            widget.onImageSelected(downloadUrl);
          });
        }
      },
      child: CircleAvatar(
        radius: 100,
        backgroundImage: _selectedImagePath == null
            ? AssetImage(_defaultImagePath) as ImageProvider<Object>?
            : NetworkImage(_selectedImagePath!),
        backgroundColor: Colors.grey[300],
        child: _selectedImagePath == null
            ? Icon(Icons.camera_alt, color: Colors.white)
            : null,
      ),
    );
  }
}

class CustomImagePicker extends StatelessWidget {
  const CustomImagePicker({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<GroupImageUploadProvider>(
      builder: (context, imageUploadProvider, child) {
        return GestureDetector(
          onTap: () => imageUploadProvider.pickImage(),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: imageUploadProvider.image == null
                      ? whiteColor
                      : mainColor,
                  // Change border color when an image is selected
                  width: 2.0,
                ),
              ),
              child: imageUploadProvider.image == null
                  ? Icon(Icons.add_a_photo, color: Colors.white)
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: Image.file(imageUploadProvider.image!,
                          fit: BoxFit.cover),
                    ), // Display the selected image
            ),
          ),
        );
      },
    );
  }
}

class CustomCheckBox extends StatelessWidget {
  final String text;
  final Icon? icon;

  const CustomCheckBox({Key? key, required this.text, this.icon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CheckboxNotifier>(
      builder: (context, checkboxNotifier, child) {
        return Row(
          children: [
            InkWell(
              onTap: () => checkboxNotifier.toggle(),
              child: Container(
                height: 24, // you can adjust the size as needed
                width: 24,
                decoration: BoxDecoration(
                  color: checkboxNotifier.isChecked ? Colors.transparent : null,
                  border: Border.all(
                    color:
                        checkboxNotifier.isChecked ? mainColor : Colors.white,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: checkboxNotifier.isChecked
                    ? Icon(Icons.check, color: mainColor, size: 20)
                    : null,
              ),
            ),
            SizedBox(width: 8), // space between the checkbox and the text
            Text(
              text,
              style: DesignSystem.lable,
            ),
            if (icon != null) ...[
              SizedBox(width: 4), // Space between the text and the icon
              icon!,
            ],
          ],
        );
      },
    );
  }
}

class CustomButton extends StatelessWidget {
  final String text;
  final Function()? onPressed;
  final double widthFactor;

  const CustomButton(
      {Key? key, required this.text, this.onPressed, this.widthFactor = 0.8})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      child: SizedBox(
        height: 50,
        width:
            MediaQuery.of(context).size.width * widthFactor, // flexible width
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: whiteColor, // background color
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25), // border radius
            ),
            padding: EdgeInsets.symmetric(
              vertical: 10,
            ), // reduced vertical padding
          ),
          child: Text(
            text,
            style: DesignSystem.buttonText,
          ),
        ),
      ),
    );
  }
}

class CustomExpandableAppBar extends StatefulWidget
    implements PreferredSizeWidget {
  final String imageUrl;
  final String groupName;
  final String qrData;
  final double preferredHeight;

  CustomExpandableAppBar({
    required this.imageUrl,
    required this.groupName,
    required this.qrData,
    this.preferredHeight = kToolbarHeight,
  });

  @override
  _CustomExpandableAppBarState createState() => _CustomExpandableAppBarState();

  @override
  // TODO: implement preferredSize
  Size get preferredSize => throw UnimplementedError();

  getPreferredSize() {}
}

class _CustomExpandableAppBarState extends State<CustomExpandableAppBar> {
  bool isOpen = false;

  void toggleAppBar() {
    setState(() {
      isOpen = !isOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: toggleAppBar,
      child: AppBar(
        title: Text(
          widget.groupName,
        ),
        bottom: PreferredSize(
          preferredSize: widget.getPreferredSize(),
          child: AnimatedContainer(
            duration: Duration(seconds: 1),
            height: isOpen ? widget.preferredHeight : 0.0,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  widget.imageUrl,
                  fit: BoxFit.cover,
                ),
                if (isOpen)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: 100,
                      height: 100,
                      child: QrImageView(
                        data: widget.qrData,
                        version: QrVersions.auto,
                        size: 100.0,
                        gapless: false,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
