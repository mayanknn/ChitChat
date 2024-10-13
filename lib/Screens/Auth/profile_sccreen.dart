import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:chitchat/Screens/Auth/login_screen.dart';
import 'package:chitchat/api/apis.dart';
import 'package:chitchat/helper/dialogs.dart';
import 'package:chitchat/models/chat_user.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileScreen extends StatefulWidget {
  final ChatUser user;

  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formkey = GlobalKey<FormState>();
  String? _image;

  @override
  Widget build(BuildContext context) {
    Size mq = MediaQuery.of(context).size;  // Define mq here
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text("Chit Chat"),
          actions: [],
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.all(10.0),
          child: FloatingActionButton.extended(
            backgroundColor: Colors.red,
            onPressed: () async {
              Dialogs.showProgressbar(context);

              await Apis.updateActiveStatus(false);
              await FirebaseAuth.instance.signOut();
              await GoogleSignIn().signOut();
              Navigator.pop(context);
              Navigator.pop(context);
              Apis.auth = FirebaseAuth.instance;
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginScreen(),
                  ));
            },
            icon: Icon(Icons.logout),
            label: Text("Logout"),
          ),
        ),
        body: Form(
          key: _formkey,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
            child: SingleChildScrollView(
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    width: mq.width,
                    height: mq.height * .03,
                  ),
                  Stack(
                    children: [
                      _image != null
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(mq.height * .1),
                        child: Image.file(
                          File(_image!),
                          width: mq.height * .2,
                          height: mq.height * .2,
                          fit: BoxFit.cover,
                        ),
                      )
                          : ClipRRect(
                        borderRadius: BorderRadius.circular(mq.height * .1),
                        child: CachedNetworkImage(
                          width: mq.height * .2,
                          height: mq.height * .2,
                          fit: BoxFit.cover,
                          imageUrl: widget.user.image,
                          placeholder: (context, url) => CircularProgressIndicator(),
                          errorWidget: (context, url, error) => Icon(Icons.error),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: -8,
                        child: MaterialButton(
                          elevation: 1,
                          onPressed: () {
                            _showBottomSheet();
                          },
                          shape: CircleBorder(),
                          child: Icon(
                            Icons.edit,
                            color: Colors.blue,
                          ),
                          color: Colors.white,
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: mq.height * .03,
                  ),
                  Text(
                    widget.user.email,
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  ),
                  SizedBox(
                    height: mq.height * .05,
                  ),
                  TextFormField(
                    onSaved: (val) => Apis.me.name = val ?? '',
                    validator: (val) =>
                    val != null && val.isNotEmpty ? null : 'Required Field',
                    initialValue: widget.user.name,
                    decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.person,
                          color: Colors.blue,
                        ),
                        hintText: 'eg. Sumit Sharma',
                        label: Text("Name"),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12))),
                  ),
                  SizedBox(
                    height: mq.height * .02,
                  ),
                  TextFormField(
                    onSaved: (val) => Apis.me.about = val ?? '',
                    validator: (val) =>
                    val != null && val.isNotEmpty ? null : 'Required Field',
                    initialValue: widget.user.about,
                    decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.info_outline,
                          color: Colors.blue,
                        ),
                        hintText: 'eg.Feeling Happy',
                        label: Text("About"),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12))),
                  ),
                  SizedBox(
                    height: mq.height * .02,
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      if (_formkey.currentState!.validate()) {
                        _formkey.currentState!.save();
                        Apis.updateUserInfo().then((value) => {
                              Dialogs.showSnakbar(
                                  context, "Updated SuccessFully")
                            });
                      }
                    },
                    icon: Icon(Icons.edit),
                    label: Text(
                      "Update",
                      style: TextStyle(fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                        minimumSize: Size(mq.width * .4, mq.height * .06)),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showBottomSheet() {
    Size mq1 = MediaQuery.of(context).size;
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return ListView(
            shrinkWrap: true,
            padding: EdgeInsets.only(top: 20, bottom: mq.height * .05),
            children: [
              Center(
                  child: Text(
                "Pick Profile Picture",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              )),
              SizedBox(
                height: mq.height * .02,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: CircleBorder(),
                          fixedSize: Size(mq.width * .3, mq.height * .15)),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        final XFile? image =
                            await picker.pickImage(source: ImageSource.gallery);
                        if (image != null) {
                          print(
                              "Image Path ${image.path} -- MimeType ${image.mimeType}");
                          setState(() {
                            _image = image.path;
                          });
                          Apis.updateProfileInfo(File(_image!));
                          Navigator.pop(context);

                        }
                      },
                      child: Image.asset('assets/images/image.png')),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: CircleBorder(),
                          fixedSize: Size(mq.width * .3, mq.height * .15)),
                      onPressed: () async{
                        final ImagePicker picker = ImagePicker();
                        final XFile? image =
                            await picker.pickImage(source: ImageSource.camera);
                        if (image != null) {
                          print("Image Path ${image.path} -- MimeType ${image
                              .mimeType}");
                        }
                        setState(() {
                          _image = image?.path;
                        });
                        Apis.updateProfileInfo(File(_image!));
                        Navigator.pop(context);
                      },
                      child: Image.asset('assets/images/camera.png'))
                ],
              )
            ],
          );
        },
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))));
  }
}
