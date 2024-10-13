import 'package:chitchat/Screens/Auth/login_screen.dart';
import 'package:chitchat/Screens/home_Screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';




void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // Define Firebase options
  FirebaseOptions firebaseOptions = const FirebaseOptions(
      apiKey: "AIzaSyDhRItG_HYxbuKbhuwa4K1T_mSPjMYO_cc",
      projectId: "chitchat-79939",
      messagingSenderId: "202021738870",
      appId: "1:202021738870:android:4a633e325b3feb695f0257"
  );

  await Firebase.initializeApp(
    options: firebaseOptions,
  );
  FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true
  );

  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chit Chat',
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 1,
          iconTheme: IconThemeData(
            color: Colors.black
          ),
          titleTextStyle: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.normal,
              fontSize: 19,
          ),
          backgroundColor: Colors.white,
        )
      ),

      home:LoginScreen(),
    );
  }
}

