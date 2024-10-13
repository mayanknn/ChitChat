import 'package:chitchat/Screens/Chatscreen.dart';
import 'package:chitchat/api/apis.dart';
import 'package:chitchat/helper/mydate.dart';
import 'package:chitchat/models/chat_user.dart';
import 'package:chitchat/models/messages.dart';
import 'package:chitchat/widgets/Dialogs/profile_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;

  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  Message? _message;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * .04, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.blue.shade50,
      elevation: 1,
      child: InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(user: widget.user),
                ));
          },
          child: StreamBuilder(
            stream: Apis.getLastMessage(widget.user),
            builder: (context, snapshot) {
              final data = snapshot.data?.docs;
              final _list =
                  data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
              if (_list.isNotEmpty) {
                _message = _list[0];
              }
              return ListTile(
                leading: InkWell(
                  onTap: () {
                    showDialog(context: context, builder: (_) =>ProfileDailog(user: widget.user,));
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                        MediaQuery.of(context).size.height * .3),
                    child: CachedNetworkImage(
                      imageUrl: widget.user.image,
                      placeholder: (context, url) => CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                  ),
                ),
                title: Text(widget.user.name),
                subtitle: Text(
                  _message != null
                      ? _message!.type == Type.image
                          ? 'Image'
                          : _message!.msg
                      : widget.user.about,
                  maxLines: 1,
                ),
                trailing: _message == null
                    ? null
                    : _message!.read.isEmpty &&
                            _message!.fromid != Apis.user.uid
                        ? Container(
                            width: 15,
                            height: 15,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.blue,
                            ),
                          )
                        : Text(Mydate.getLastMessageTime(
                            context: context, time: _message!.sent)),
              );
            },
          )),
    );
  }
}
