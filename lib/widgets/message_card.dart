import 'package:chitchat/api/apis.dart';
import 'package:chitchat/helper/mydate.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../Screens/Auth/login_screen.dart';
import '../models/messages.dart';

class MessageCard extends StatefulWidget {
  final Message message;

  const MessageCard({super.key, required this.message});

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    print("Building MessageCard for message: ${widget.message.msg}");
    return Apis.user.uid == widget.message.fromid
        ? _greenMessage()
        : _whiteMessage();
  }

  Widget _whiteMessage() {
    print("Displaying white message card");
    if (widget.message.read.isEmpty) {
      Apis.updateMessageRead(widget.message);
      print("Read Time Updated for message: ${widget.message.msg}");
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.message.type==Type.image? mq.width * .02:mq.width * .04),
            margin: EdgeInsets.symmetric(
                horizontal: mq.width * .04, vertical: mq.height * .01),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                    bottomRight: Radius.circular(30)),
                border: Border.all(color: Colors.lightBlue)),
            child: widget.message.type == Type.text
                ? Text(
              widget.message.msg,
              style: TextStyle(fontSize: 15, color: Colors.black),
            )
                : ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: CachedNetworkImage(
                imageUrl: widget.message.msg,
                placeholder: (context, url) =>
                    CircularProgressIndicator(strokeWidth: 2),
                errorWidget: (context, url, error) => Icon(
                  Icons.image,
                  size: 70,
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: mq.width * .04),
          child: Text(
            Mydate.getFormattedTime(
                context: context, time: widget.message.sent),
            style: TextStyle(fontSize: 13, color: Colors.black54),
          ),
        )
      ],
    );
  }

  Widget _greenMessage() {
    print("Displaying green message card");
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(
              width: mq.width * .04,
            ),
            if (widget.message.read.isNotEmpty)
              Icon(
                Icons.done_all_rounded,
                color: Colors.blue,
                size: 20,
              ),
            SizedBox(width: 3),
            Text(
              Mydate.getFormattedTime(
                  context: context, time: widget.message.sent),
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ],
        ),
        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.message.type==Type.image? mq.width * .02:mq.width * .04),
            margin: EdgeInsets.symmetric(
                horizontal: mq.width * .04, vertical: mq.height * .01),
            decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30)),
                border: Border.all(color: Colors.lightBlue)),
            child: widget.message.type == Type.text
                ? Text(
              widget.message.msg,
              style: TextStyle(fontSize: 15, color: Colors.black),
            )
                : ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: CachedNetworkImage(
                imageUrl: widget.message.msg,
                placeholder: (context, url) =>
                    CircularProgressIndicator(strokeWidth: 2),
                errorWidget: (context, url, error) => Icon(
                  Icons.image,
                  size: 70,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
