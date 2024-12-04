import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:memorize/style/colors.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../provider/chat_provider.dart';
import '../../style/designSystem.dart';

class ChatScreen extends StatefulWidget {
  final Map<String, dynamic> group;

  ChatScreen({required this.group});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with AutomaticKeepAliveClientMixin<ChatScreen> {
  // Hinzufügen von AutomaticKeepAliveClientMixin
  bool isOpen = false;
  bool appBarOpen = false;
  bool bottomOpen = false;
  Size expandedSize = Size.fromHeight(250);

  void noAnimationToggle() {
    setState(() {
      appBarOpen = !appBarOpen;
      bottomOpen = !bottomOpen;
    });
  }

  @override
  void initState() {
    super.initState();
    Provider.of<ChatProvider>(context, listen: false).precacheGroupImages(
        context, widget.group['groupId']); // groupId is the id of your group
  }

  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<ImageInfo> _getImageInfo(
      BuildContext context, String? imageUrl) async {
    if (imageUrl == null) {
      throw ArgumentError('imageUrl cannot be null');
    }
    final ImageStream stream =
        Image.network(imageUrl).image.resolve(const ImageConfiguration());
    final Completer<ImageInfo> completer = Completer<ImageInfo>();
    void listener(ImageInfo info, bool synchronousCall) {
      if (!completer.isCompleted) {
        completer.complete(info);
      }
    }

    stream.addListener(
      ImageStreamListener(listener),
    );
    return completer.future;
  }

  // Diese Methode hält die Widgets im Speicher
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth * 0.05; // 10% des Bildschirms
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: whiteColor,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: <Widget>[
          IconButton(
            onPressed: noAnimationToggle,
            icon: Icon(Icons.keyboard_arrow_down),
            color: Colors.white,
          ),
        ],
        backgroundColor: blackColor,
        flexibleSpace: bottomOpen
            ? ShaderMask(
                shaderCallback: (Rect bounds) {
                  return LinearGradient(
                    colors: [Color(0x80000000), Colors.black],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ).createShader(bounds);
                },
                blendMode: BlendMode.darken,
                child: Image.network(
                  widget.group['imageUrl'],
                  fit: BoxFit.cover,
                ),
              )
            : ColorFiltered(
                colorFilter:
                    ColorFilter.mode(Color(0x99000000), BlendMode.darken),
                child: Image.network(
                  widget.group['imageUrl'],
                  fit: BoxFit.cover,
                ),
              ),
        title: GestureDetector(
          onTap: noAnimationToggle,
          child: Text(
            widget.group['groupName'] ?? 'No Group',
            style: DesignSystem.appBarTitle,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: appBarOpen ? expandedSize : Size.zero,
          child: Container(
            color: Colors.transparent,
            height: bottomOpen ? kToolbarHeight + expandedSize.height : 0,
            child: Column(
              children: [
                Text(
                  widget.group['groupName'] ?? 'No Group',
                  style: DesignSystem.header1,
                ),
                SizedBox(
                  height: 15,
                ),
                Align(
                  alignment: Alignment.center,
                  widthFactor: 1.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(width: 5),
                      const Icon(
                        Icons.people,
                        size: 30,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Text(
                  "Group QR-Code",
                  style: DesignSystem.header3,
                ),
                SizedBox(
                  height: 5,
                ),
                QrImageView(
                  foregroundColor: whiteColor,
                  data: widget.group['qrData'] ?? 'No QR-Code',
                  version: QrVersions.auto,
                  size: 100.0,
                  gapless: false,
                ),
                IconButton(
                  onPressed: noAnimationToggle,
                  icon: Icon(Icons.keyboard_arrow_up),
                  color: Colors.white,
                ),
              ],
            ),
          ), //_animation.value == 0 ? Size.zero : Size.fromHeight(_animation.value),
        ),
      ),
      body: widget.group['groupId'] != null
          ? StreamBuilder<QuerySnapshot>(
              stream: Provider.of<ChatProvider>(context, listen: false)
                  .getChat(widget.group['groupId']),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Something went wrong');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                return ListView.builder(
                  addAutomaticKeepAlives: true,
                  padding: EdgeInsets.only(
                      bottom: 80.0,
                      left: horizontalPadding,
                      right: horizontalPadding),
                  reverse: true,
                  itemCount: snapshot.data?.docs.length,
                  itemBuilder: (context, index) {
                    var message = snapshot.data?.docs[index];
                    return ListTile(
                      title: (message?['imageUrl'] != null &&
                              message?['imageUrl'] is String)
                          ? Column(children: [
                              FutureBuilder<DocumentSnapshot>(
                                future: Provider.of<ChatProvider>(context,
                                        listen: false)
                                    .getUserInfo(message?['userId']),
                                builder: (BuildContext context,
                                    AsyncSnapshot<DocumentSnapshot> snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.done) {
                                    if (snapshot.hasError) {
                                      return const Text(
                                          'Fehler beim Laden des Benutzerprofils');
                                    }
                                    Map<String, dynamic> data = snapshot.data!
                                        .data() as Map<String, dynamic>;
                                    String username = data['username'];
                                    String profileImageUrl = data['profileImg'];
                                    bool isCurrentUser = (message?['userId'] ==
                                        auth.currentUser?.uid);
                                    return Column(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: isCurrentUser
                                                  ? mainColor
                                                  : whiteColor,
                                              width: 2.0,
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: CircleAvatar(
                                            backgroundImage:
                                                CachedNetworkImageProvider(
                                                    profileImageUrl),
                                          ),
                                        ),
                                        Center(
                                            child: Text(username,
                                                style: DesignSystem.lable)),
                                        const SizedBox(
                                          height: 5,
                                        )
                                      ],
                                    );
                                  } else {
                                    return Container();
                                  }
                                },
                              ),
                              GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => Dialog(
                                      child: CachedNetworkImage(
                                        imageUrl: message?['imageUrl'],
                                        imageBuilder: (context, imageProvider) {
                                          return Image(
                                            image: imageProvider,
                                            fit: BoxFit.cover,
                                          );
                                        },
                                        placeholder: (context, url) =>
                                            Container(
                                          width: 250,
                                          // Sie können hier die erforderlichen festen Werte einstellen
                                          height: 250,
                                          // Sie können hier die erforderlichen festen Werte einstellen
                                          child: CircularProgressIndicator(),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            Icon(Icons.error),
                                      ),
                                    ),
                                  );
                                },
                                child: Stack(
                                  alignment: Alignment.bottomLeft,
                                  children: [
                                    CachedNetworkImage(
                                      imageUrl: message?['imageUrl'],
                                      imageBuilder: (context, imageProvider) {
                                        return Image(
                                          image: imageProvider,
                                          fit: BoxFit.cover,
                                        );
                                      },
                                      placeholder: (context, url) => Container(
                                        width: 250,
                                        // Sie können hier die erforderlichen festen Werte einstellen
                                        height:
                                            500, // Sie können hier die erforderlichen festen Werte einstellen
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.error),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(9.0),
                                        boxShadow: [
                                          BoxShadow(
                                            color: mainColor.withOpacity(0.3),
                                            offset: Offset(0, 0),
                                            blurRadius: 5.0,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ])
                          : Container(),
                    );
                  },
                );
              },
            )
          : Center(child: Text('Group load error!')),
      bottomNavigationBar: Container(
        height: MediaQuery.of(context).padding.bottom + 80,
        color: Colors.black,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FloatingActionButton(
              heroTag: "camera",
              onPressed: () {
                if (widget.group['groupId'] != null &&
                    widget.group['groupId'] is String) {
                  Provider.of<ChatProvider>(context, listen: false)
                      .uploadImageFromCamera(
                          widget.group['groupId'], 'yourSenderId');
                } else {
                  print("Group ID is not available or it's not a String");
                }
              },
              child: Icon(Icons.camera_alt, color: mainColor),
              backgroundColor: Colors.transparent,
              elevation: 0.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
                side: BorderSide(color: mainColor),
              ),
            ),
            SizedBox(width: 16),
            FloatingActionButton(
              heroTag: "gallery",
              mini: true,
              onPressed: () {
                if (widget.group['groupId'] != null &&
                    widget.group['groupId'] is String) {
                  Provider.of<ChatProvider>(context, listen: false)
                      .uploadImageFromGallery(
                          widget.group['groupId'], 'yourSenderId');
                } else {
                  print("Group ID is not available or it's not a String");
                }
              },
              child: Icon(Icons.attach_file, color: Colors.black),
              backgroundColor: Colors.white,
              elevation: 0.0,
            ),
          ],
        ),
      ),
    );
  }
}
