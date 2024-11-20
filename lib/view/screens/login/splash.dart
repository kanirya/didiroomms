import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../view_models/provider/provider.dart';
import '../Home/Main/Home_screen.dart';
import 'login.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    super.initState();
    Timer(Duration(seconds: 3), () {
      ap.isSignedIn == true
          ?

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => homeScreen()),
            (Route<dynamic> route) => false,
      )
          : Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => loginScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/images/logo.svg',
              width: 150, // Adjust size as needed
              height: 150,
            ),
            const SizedBox(height: 20,),

          ],
        ),
      ),
    );
  }
}