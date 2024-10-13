import 'package:flutter/material.dart';

class Dialogs {
  static void showSnakbar(BuildContext context, String msg) {
    ScaffoldMessenger
        .of(context)
        .showSnackBar(SnackBar(content: Text(msg),
      backgroundColor: Colors.blue.withOpacity(.8),
      behavior: SnackBarBehavior.floating,));
    }

  static void showProgressbar(BuildContext context) {
    
    showDialog(context: context, builder: (_) => Center(child: CircularProgressIndicator()),);
  }
}