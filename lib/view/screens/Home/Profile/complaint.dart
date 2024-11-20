
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../utils/global/global_variables.dart';
import '../../../../view_models/provider/provider.dart';

class ComplaintPage extends StatefulWidget {
  @override
  _ComplaintPageState createState() => _ComplaintPageState();
}

class _ComplaintPageState extends State<ComplaintPage> {
  final TextEditingController _contactNumberController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _selectedComplaintType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Submit a Complaint'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Complaint Details',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                _buildDropdownField(
                  items: ['Driver Issue', 'Payment Issue', 'Ride Issue', 'In-app Bugs', 'Other'],
                  label: 'Complaint Type',
                  hintText: 'Select the type of complaint',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a complaint type';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      _selectedComplaintType = value;
                    });
                  },
                ),
                SizedBox(height: 16),
                _buildTextField(
                  controller: _contactNumberController,
                  label: 'Contact Number',
                  hintText: 'Enter your contact number',
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your contact number';
                    }
                    if (!RegExp(r'^\+?\d{10,15}$').hasMatch(value)) {
                      return 'Please enter a valid contact number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                _buildTextField(
                  controller: _descriptionController,
                  label: 'Description',
                  hintText: 'Describe your complaint in detail',
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please describe your complaint';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _submitComplaint(context);
                    }
                  },
                  child: Text('Submit Complaint'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    textStyle: TextStyle(fontSize: 18),
                    backgroundColor: mainColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      maxLines: maxLines,
      validator: validator,
    );
  }

  Widget _buildDropdownField({
    required List<String> items,
    required String label,
    required String hintText,
    required String? Function(String?) validator,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      items: items.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }

  void _submitComplaint(BuildContext context) {
    final contactNumber = _contactNumberController.text;
    final description = _descriptionController.text;

    final app = Provider.of<AuthProvider>(context, listen: false);
    int id=generateUniqueValue();
    final ref = FirebaseDatabase.instance.ref('complaints').child(id.toString());

    ref.set({
      "name": "${app.userModel.firstName.toString()} ${app.userModel.lastName.toString()}",
      "uid":app.userModel.uid.toString(),
      "userContact": app.userModel.phoneNumber.toString(),
      "email":app.userModel.email,
      "contactNumber": contactNumber,
      "description": description,
      "id":id

    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Complaint submitted successfully!'),
        ),
      );

      // Clear the form fields
      _contactNumberController.clear();
      _descriptionController.clear();
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit complaint: $error'),
        ),
      );
    });
  }
  int generateUniqueValue() {
    final DateTime now = DateTime.now();
    final int timestamp = now.millisecondsSinceEpoch;
    return -timestamp; // Negate the timestamp to ensure decreasing order
  }
}