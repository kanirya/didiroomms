
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

import '../../../res/components/custom.dart';
import '../../../utils/global/global_variables.dart';
import '../../../view_models/provider/provider.dart';
import '../Home/Main/Home_screen.dart';
import 'information_screen.dart';

class OtpScreen extends StatefulWidget {
  final String verificationID;

  const OtpScreen({super.key, required this.verificationID});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  String? otpcode;

  @override
  Widget build(BuildContext context) {
     final isLoading =
         Provider.of<AuthProvider>(context, listen: true).isLoading;
    return Scaffold(
      body: SafeArea(
        child:
        isLoading == true
            ? const Center(
          child: CircularProgressIndicator(
            color: Colors.yellow,
          ),
        )
            :
        Center(
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: 25,
              horizontal: 35,
            ),
            child: ListView(children: [
              Align(
                alignment: Alignment.topLeft,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(Icons.arrow_back),
                ),
              ),
              Container(width: 80,height: 80,child: Icon(Icons.design_services,size: 30,),),
              const SizedBox(
                height: 220,
              ),
              Center(
                child: const Text(
                  "Verification",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                "Enter the OTP send to your phone number.",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black38,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 15,
              ),
              Pinput(
                length: 6,
                showCursor: true,
                defaultPinTheme: PinTheme(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border:
                      Border.all(color: Colors.blueGrey),
                    ),
                    textStyle: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w600)),
                onCompleted: (value) {
                  setState(() {
                    otpcode = value;
                  });
                },
              ),
              const SizedBox(
                height: 25,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 50,
                child: CustomButton(
                  color: buttonColor,
                  text: "Verify",
                  onPressed: () {
                    if (otpcode != null) {
                      verifyOtp(context, otpcode!);
                    } else {
                      showSnackBar(context, "Enter 6-Digits code");
                    }
                  },
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                "Didn't receive any code?",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(
                height: 14,
              ),
              const Text("Resend new code",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ))
            ]),
          ),
        ),
      ),
    );
  }

  void verifyOtp(BuildContext context, String userOtp) {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    ap.verifyOtp(
      context: context,
      verificationId: widget.verificationID,
      userOtp: userOtp,
      onSuccess: () {
        ap.checkExistingUser().then(
              (value) async {
            if (value == true) {
               ap.getDataFromFirestore().then(
                     (value) => ap.saveUserDataToSp().then(
                       (value) => ap.setSignIn().then(
                         (value) => Navigator.pushAndRemoveUntil(
                         context,
                         MaterialPageRoute(
                            builder: (context) =>
                            const homeScreen()),
                            (route) => false),
                  ),
                ),
              );
            } else {
              //new user
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const informationScreen()),
                      (route) => false);
            }
          },
        );
      },
    );
  }
}
