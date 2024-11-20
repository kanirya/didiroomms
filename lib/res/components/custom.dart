
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final Color color;
  const CustomButton({super.key, required this.text, required this.onPressed,required this.color});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 60, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 16),
      ),
    );
  }}


void showSnackBar(BuildContext context, String content) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(content),
    ),
  );
}



Widget textField2(
    {required String hintText,

      required TextInputType inputType,
      required TextEditingController controller}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: TextFormField(
      keyboardType: inputType,
      controller: controller,
      cursorColor: Colors.black,
      cursorWidth: 1,

      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400,),
      decoration: InputDecoration(
        alignLabelWithHint: true,
        border: OutlineInputBorder(
            borderSide: BorderSide(width: 1,)
        ),
        label: Text(hintText,style: TextStyle(color: Colors.black),),
        enabledBorder: OutlineInputBorder(

          borderSide: const BorderSide(color: Colors.black),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black),
        ),
      ),
    ),
  );
}

class ProfileMenuWidget extends StatelessWidget {
  const ProfileMenuWidget({
    super.key,
    required this.title,
    required this.icon,
    required this.onPress,
    this.endIcon = true,
    this.textColor,
  });

  final String title;
  final IconData icon;
  final VoidCallback onPress;
  final bool endIcon;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: ListTile(
        onTap: onPress,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: Colors.blue.withOpacity(0.1),
          ),
          child: Icon(
            icon,
            color: Colors.blueAccent,
            size: 28,
          ),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium?.apply(color: textColor),
        ),
        trailing: endIcon
            ? Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: Colors.grey.withOpacity(0.1),
          ),
          child: const Icon(
            Icons.chevron_right,
            size: 18,
            color: Colors.grey,
          ),
        )
            : null,
      ),
    );
  }
}
