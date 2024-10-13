import 'dart:convert';
import 'dart:io';
import 'package:chitchat/helper/mydate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:chitchat/api/apis.dart';
import 'package:chitchat/models/chat_user.dart';
import 'package:chitchat/widgets/message_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/messages.dart';
import 'Auth/login_screen.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;

  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Message> _list = [];
  var textController = TextEditingController();
  bool _isuploading = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.white, statusBarColor: Colors.white));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          flexibleSpace: appbar(),
        ),
        backgroundColor: Colors.blue.shade50,
        body: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: Apis.getAllMessages(widget.user),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                      return Center(child: CircularProgressIndicator());
                    case ConnectionState.active:
                    case ConnectionState.done:
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      final data = snapshot.data?.docs;
                      _list = data
                              ?.map((e) => Message.fromJson(e.data()))
                              .toList() ??
                          [];

                      if (_list.isEmpty) {
                        return Center(
                          child: Text(
                            "Say Hii..👋",
                            style: TextStyle(fontSize: 20),
                          ),
                        );
                      }

                      return ListView.builder(
                        reverse: true,
                        itemCount: _list.length,
                        itemBuilder: (context, index) {
                          return MessageCard(
                            message: _list[index],
                          );
                        },
                      );
                  }
                },
              ),
            ),
            if (_isuploading)
              Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: CircularProgressIndicator(),
                  )),

            chatInput(),

            // if (_showEmojiPicker) emojiPicker()
          ],
        ),
      ),
    );
  }

  Widget appbar() {
    return InkWell(
      onTap: () {},
      child: StreamBuilder(
        stream: Apis.getUserInfo(widget.user),
        builder: (context, snapshot) {
          final data = snapshot.data?.docs;
          final _list =
              data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                  )),
              ClipRRect(
                borderRadius: BorderRadius.circular(
                    MediaQuery.of(context).size.height * .03),
                child: CachedNetworkImage(
                  imageUrl:
                      _list.isNotEmpty ? _list[0].image : widget.user.image,
                  width: MediaQuery.of(context).size.height * .05,
                  height: MediaQuery.of(context).size.height * .05,
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _list.isNotEmpty ? _list[0].name : widget.user.name,
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.w500),
                  ),
                  SizedBox(
                    height: 2,
                  ),
                  Text(
                    _list.isNotEmpty
                        ? _list[0].isOnline
                            ? 'Online'
                            : Mydate.getLastActiveTime(
                                context: context,
                                lastActive: _list[0].lastActive)
                        : Mydate.getLastActiveTime(
                            context: context,
                            lastActive: widget.user.lastActive),
                    style: TextStyle(
                        fontSize: 13,
                        color: Colors.black,
                        fontWeight: FontWeight.w300),
                  ),
                ],
              )
            ],
          );
        },
      ),
    );
  }

  Widget chatInput() {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * .03,
          vertical: MediaQuery.of(context).size.height * .01),
      child: Row(
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Row(
                children: [
                  // IconButton(
                  //     onPressed: () {
                  //       setState(() {
                  //         _showEmojiPicker = !_showEmojiPicker;
                  //       });
                  //     },
                  //     icon: Icon(
                  //       Icons.emoji_emotions,
                  //       color: Colors.blue,
                  //     )),
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: TextField(
                      controller: textController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      decoration: InputDecoration(
                          hintText: "Type Something",
                          hintStyle: TextStyle(color: Colors.blue),
                          border: InputBorder.none),
                    ),
                  )),
                  IconButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        final List<XFile> images =
                            await picker.pickMultiImage(imageQuality: 70);
                        if (images.isNotEmpty) {
                          for (var element in images) {
                            setState(() {
                              _isuploading = true;
                            });
                            await Apis.sentChatImage(
                                widget.user, File(element.path));
                            setState(() {
                              _isuploading = false;
                            });
                          }
                        }
                      },
                      icon: Icon(
                        Icons.image,
                        color: Colors.blue,
                      )),
                  IconButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        final XFile? image = await picker.pickImage(
                            source: ImageSource.camera, imageQuality: 70);
                        if (image != null) {
                          setState(() {
                            _isuploading = true;
                          });
                          print(
                              "Image Path ${image.path} -- MimeType ${image.mimeType}");
                          await Apis.sentChatImage(
                              widget.user, File(image.path));
                          setState(() {
                            _isuploading = false;
                          });
                        }
                      },
                      icon: Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.blue,
                      )),
                ],
              ),
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * .02,
          ),
          MaterialButton(
            onPressed: () {
              if (textController.text.isNotEmpty) {
                Apis.sendMessage(widget.user, textController.text, Type.text);
                textController.text = '';
              }
            },
            minWidth: 0,
            padding: EdgeInsets.all(10),
            shape: CircleBorder(),
            color: Colors.green,
            child: Icon(
              Icons.send,
              color: Colors.white,
              size: 28,
            ),
          )
        ],
      ),
    );
  }

// Widget emojiPicker() {
//   return SizedBox(
//     height: 300,
//     child: EmojiPicker(
//       textEditingController: textController,
//       config: Config(
//         columns: 7,
//         checkPlatformCompatibility: true,
//         emojiViewConfig: EmojiViewConfig(
//           emojiSizeMax: 28 *
//               (foundation.defaultTargetPlatform ==
//                   TargetPlatform.iOS
//                   ? 1.2
//                   : 1.0),
//         ),
//         swapCategoryAndBottomBar: false,
//         skinToneConfig: const SkinToneConfig(),
//         categoryViewConfig: const CategoryViewConfig(),
//         bottomActionBarConfig: const BottomActionBarConfig(),
//         searchViewConfig: const SearchViewConfig(),
//       ),
//     ),
//   );
// }
}
