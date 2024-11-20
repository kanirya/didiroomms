import 'dart:convert';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_form_line_awesome_icons/modern_form_line_awesome_icons.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../res/components/custom.dart';

import '../../../../utils/global/global_variables.dart';
import '../../../../view_models/provider/provider.dart';
import '../../login/login.dart';
import 'complaint.dart';
import 'information.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    var isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    final app = Provider.of<AuthProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Profile",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(isDark ? LineAwesomeIcons.sun_o : LineAwesomeIcons.moon_o),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              Text("${app.userModel.firstName} ${app.userModel.lastName}", style: TextStyle(fontFamily: 'Montserrat', fontSize: 24, fontWeight: FontWeight.bold)),
              Text(app.userModel.phoneNumber,
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Date of Join:",
                    style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(app.userModel.createdAt),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => driverUpdateProfile())),
                  child: const Text(
                    "Edit Profile",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    side: BorderSide.none,
                    shape: StadiumBorder(),
                  ),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Row(
                children: [
                  Text(
                    "Powered by ",
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                  Text(
                    "DIDIrooms",
                    style: GoogleFonts.montserrat(
                        textStyle: TextStyle(fontWeight: FontWeight.bold)),
                  )
                ],
              ),
              const Divider(),
              const SizedBox(
                height: 10,
              ),
              ProfileMenuWidget(
                title: "Information",
                icon: LineAwesomeIcons.info,
                onPress: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => InformationPage()));
                },
              ),
              ProfileMenuWidget(
                title: "Complain",
                icon: Icons.edit,
                onPress: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ComplaintPage()));
                },
              ),
              ProfileMenuWidget(
                title: "Logout",
                icon: LineAwesomeIcons.sign_out,
                onPress: () {

                  _showLogoutDialog(context);
                },
                endIcon: false,
                textColor: Colors.red,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final app = Provider.of<AuthProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Container(
            padding: EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 15.0),
                Text(
                  'Are you sure you want to log out?',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18.0),
                ),
                SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                        app.userSignOut().then(
                              (value) => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => loginScreen(),
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: Text(
                        'Logout',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class driverUpdateProfile extends StatefulWidget {
  const driverUpdateProfile({super.key});

  @override
  State<driverUpdateProfile> createState() => _driverUpdateProfileState();
}

class _driverUpdateProfileState extends State<driverUpdateProfile> {
  TextEditingController nameEdit = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Edit Profile",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Form(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(13.0),
                  child:textField2(hintText: "New Name", inputType: TextInputType.text, controller: nameEdit),
                )
              ],
            ),
          ),
          Container(
              width: MediaQuery.of(context).size.width * .7,
              child: CustomButton(
                color: buttonColor,
                  text: "Save",
                  onPressed: () async {
                    if(nameEdit.text.isNotEmpty){
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.all(Radius.circular(15.0)),
                            ),
                            title: Text('Confirm Change',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            content: Text(
                              'Are you sure you want to change your name to "${nameEdit.text.toString()}"?',
                              style: TextStyle(fontSize: 16.0),
                            ),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(); // Close the dialog
                                },
                                child: Text('No',
                                    style: TextStyle(color: Colors.red)),
                              ),
                              TextButton(
                                onPressed: () {
                                  updateName(nameEdit.text.toString());
                                  Navigator.of(context).pop(); // Close the dialog
                                },
                                child: Text('Yes',
                                    style: TextStyle(color: Colors.green)),
                              ),
                            ],
                          );
                        },
                      );
                    }else {
                      showSnackBar(context, "Please Enter New name");
                    }
                  })),
        ],
      ),
    );
  }

  void updateName(String newName) async {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    try {
      await FirebaseFirestore.instance
          .collection('Customers')
          .doc(ap.userModel.uid)
          .update({'passengerName': newName});
      ap.userModel.firstName = newName;
      ap.notifyListeners();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      Map<String, dynamic> passengerMap =
      json.decode(prefs.getString('user_model') ?? '{}');
      passengerMap['firstName'] = newName;
      await prefs
          .setString('user_model', json.encode(passengerMap))
          .then((onValue) {
        showSnackBar(context, "Please Reload your app to see changes.");
      });
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }
}