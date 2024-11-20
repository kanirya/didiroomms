
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../view_models/provider/provider.dart';
import '../Home/Main/Home_screen.dart';
import '../../../view_models/Model/user_model.dart';

class informationScreen extends StatefulWidget {
  const informationScreen({super.key});

  @override
  State<informationScreen> createState() => _informationScreenState();
}

class _informationScreenState extends State<informationScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for the form fields
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String? _selectedGender;

  @override
  void dispose() {
    // Dispose of the controllers when the widget is disposed
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              // Background image that fills the extra space
              Positioned.fill(
                child: Image.asset(
                  'assets/images/4.png',
                  fit: BoxFit.cover,
                ),
              ),
              Center(
                child: SingleChildScrollView(
                  child: Container(
                    width: constraints.maxWidth > 600 ? 500 : double.infinity,
                    // Fixed width on larger screens
                    padding: EdgeInsets.all(20),
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // First Name Field
                          TextFormField(
                            controller: _firstNameController,
                            decoration: InputDecoration(
                              labelText: 'First Name',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your first name';
                              } else if (!RegExp(r'^[a-zA-Z]+$')
                                  .hasMatch(value)) {
                                return 'Only alphabets are allowed';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16),
                          // Last Name Field
                          TextFormField(
                            controller: _lastNameController,
                            decoration: InputDecoration(
                              labelText: 'Last Name',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your last name';
                              } else if (!RegExp(r'^[a-zA-Z]+$')
                                  .hasMatch(value)) {
                                return 'Only alphabets are allowed';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16),
                          // Gender Dropdown
                          DropdownButtonFormField<String>(
                            value: _selectedGender,
                            decoration: InputDecoration(
                              labelText: 'Gender',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            items: ['Male', 'Female', 'Other']
                                .map((gender) => DropdownMenuItem(
                                      value: gender,
                                      child: Text(gender),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedGender = value;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select your gender';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16),
                          // Email Field
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              } else if (!value.endsWith('@gmail.com')) {
                                return 'Email should end with @gmail.com';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 32),
                          ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                storeData();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Text(
                              'Save',
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void storeData() {

    final ap = Provider.of<AuthProvider>(context, listen: false);
    UserModel userModel =UserModel(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      gender: _selectedGender!,
      createdAt: "",
      phoneNumber: "",
      uid: "",
    );

      ap.saveUserDataToFirebase(
        context: context,
        userModel: userModel,
        onSuccess: () {
          ap.saveUserDataToSp().then(
                (value) => ap.setSignIn().then(
                  (value) => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => homeScreen(),
                ),
                    (route) => false,
              ),
            ),
          );
        },
      );



  }
}
