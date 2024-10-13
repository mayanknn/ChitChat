import 'package:chitchat/models/chat_user.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../Screens/Auth/login_screen.dart';

class ProfileDailog extends StatelessWidget {
  const ProfileDailog({super.key, required this.user});

  final ChatUser user;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: SizedBox(width: mq.width * .6, height: mq.height * .35,child: Stack(
        children: [
          Text(user.name,style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),),
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(mq.height * .25),
              child: CachedNetworkImage(
                width: mq.width * .5,
                // height: mq.height * .2,
                fit: BoxFit.cover,
                imageUrl: user.image,
                placeholder: (context, url) => CircularProgressIndicator(),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ),
          ),

        ],
      ),),
    );
  }
}
