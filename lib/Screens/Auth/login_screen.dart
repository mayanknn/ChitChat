import 'package:chitchat/api/apis.dart';
import 'package:chitchat/helper/dialogs.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:chitchat/Screens/home_Screen.dart';

late Size mq;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final auth = FirebaseAuth.instance;
  bool _animate = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _animate = true;
      });
    });
  }

  Future<void> handleGoogleBtn() async {
    try {
      Dialogs.showProgressbar(context);
      // Sign out the current user
      // await GoogleSignIn().signOut();
      // await FirebaseAuth.instance.signOut();

      var user = await _signInWithGoogle();
      Navigator.pop(context);

      if (user != null) {
        print(user.user);
        if(await Apis.userExists()){
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreen(),
              )
          );
        }
        else{
          await Apis.createUser();
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreen(),
              ),
          );
        }
      }
    } catch (e) {
      print(e); // Add proper error handling here
    }
  }

  Future<UserCredential?> _signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        // User cancelled the sign-in
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      // Handle the error here
      print('Error during Google sign-in: $e');
      Dialogs.showSnakbar(context, 'Something Went Wrong Check Internet');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Welcome to Chit Chat"),
      ),
      body: Stack(
        children: [
          Positioned(
            top: mq.height * .10,
            left: mq.width * .25,
            width: mq.width * .5,
            child: AnimatedOpacity(
              opacity: _animate ? 1.0 : 0.0,
              duration: Duration(seconds: 1),
              child: Image.asset('assets/images/whatsapp.png'),
            ),
          ),
          Positioned(
            bottom: mq.height * .10,
            left: mq.width * .05,
            width: mq.width * .9,
            height: mq.height * .07,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade300,
                elevation: 1,
              ),
              onPressed: handleGoogleBtn,
              icon: Image.asset(
                "assets/images/google.png",
                height: mq.height * .05,
              ),
              label: RichText(
                text: TextSpan(
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 20,
                  ),
                  children: [
                    TextSpan(text: '     Login With'),
                    TextSpan(text: ' Google'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
