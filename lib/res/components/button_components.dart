import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final double cornerRadius;
  final Color color;
  final VoidCallback onPressed;
  final TextStyle textStyle;
  final double width;

  const CustomButton({
    Key? key,
    required this.text,
    required this.cornerRadius,
    required this.color,
    required this.onPressed,
    this.width= 1,
    this.textStyle = const TextStyle(color: Colors.white, fontSize: 16),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent, // Makes the button color customizable
      child: Container(
        width: MediaQuery.of(context).size.width*width,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(cornerRadius), // Dynamic corner radius
          splashColor: Colors.white.withOpacity(0.3), // Ripple effect color
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: color, // Dynamic background color
              borderRadius: BorderRadius.circular(cornerRadius),
            ),
            child: Center(
              child: Text(
                text,
                style: textStyle, // Dynamic text style
              ),
            ),
          ),
        ),
      ),
    );
  }
}
