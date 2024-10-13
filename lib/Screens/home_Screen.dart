import 'dart:convert';
import 'dart:math';

import 'package:chitchat/Screens/Auth/profile_sccreen.dart';
import 'package:chitchat/api/apis.dart';
import 'package:chitchat/models/chat_user.dart';
import 'package:chitchat/widgets/chat_user_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ChatUser> list = [];
  final List<ChatUser> _search = [];

  bool _isSeach = false;

  @override
  void initState() {
    super.initState();
    Apis.getSelfInfo();
    SystemChannels.lifecycle.setMessageHandler((message) {
      print("Message $message");
      if(Apis.auth.currentUser != null){
        if(message.toString().contains('resume')) Apis.updateActiveStatus(true);
        if(message.toString().contains('pause')) Apis.updateActiveStatus(false);
      }

      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>FocusScope.of(context).unfocus(),
      child: WillPopScope(
        onWillPop: (){
          if(_isSeach){
            setState(() {
              _isSeach=!_isSeach;
            });
            return Future.value(false);
          }
          else{
            return Future.value(true);
          }

        },
        child: Scaffold(
          appBar: AppBar(
            leading: Icon(Icons.home),
            title: _isSeach
                ? TextField(
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Name',

              ),
              autofocus: true,
              style: TextStyle(fontSize: 17, letterSpacing: 0.5),
              onChanged:(val){
                _search.clear();
                for(var i in list){
                  if(i.name.toLowerCase().contains(val.toLowerCase())){
                    _search.add(i);
                  }
                  setState(() {
                    _search;
                  });
                }
              },
            )
                : Text("Chit Chat"),
            actions: [
              IconButton(
                  onPressed: () {
                    setState(() {
                      _isSeach = !_isSeach;
                    });
                  },
                  icon: Icon(_isSeach ? CupertinoIcons.clear : Icons.search)),
              IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfileScreen(user: Apis.me),
                        ));
                  },
                  icon: Icon(CupertinoIcons.profile_circled)),
            ],
          ),
          floatingActionButton: Padding(
            padding: const EdgeInsets.all(10.0),
            child: FloatingActionButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                await GoogleSignIn().signOut();
              },
              child: Icon(Icons.add_comment_rounded),
            ),
          ),
          body: StreamBuilder(
            stream: Apis.getAllUsers(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                case ConnectionState.none:
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                case ConnectionState.active:
                case ConnectionState.done:
                  final data = snapshot.data?.docs;
                  list =
                      data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];
                  if (list.isNotEmpty) {
                    return ListView.builder(
                      itemBuilder: (context, index) {
                        return ChatUserCard(user: _isSeach?_search[index]:list[index]);
                      },
                      itemCount: _isSeach?_search.length:list.length,
                      physics: BouncingScrollPhysics(),
                    );
                  } else {
                    return Center(
                        child: Text(
                          "No Connection Found",
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ));
                  }
              }
            },
          ),
        ),
      ),
    );
  }
}
