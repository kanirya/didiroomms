import 'package:flutter/material.dart';

class CustomSnackbar {
  static void show(
      BuildContext context, {
        required String message,
        Color backgroundColor = Colors.red,
        Duration duration = const Duration(seconds: 3),
        SnackBarAction? action,
      }) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: backgroundColor,
      duration: duration,
      action: action,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
