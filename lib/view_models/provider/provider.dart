import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../res/components/custom.dart';
import '../../view/screens/login/otp_screen.dart';
import '../Model/user_model.dart';

class AuthProvider extends ChangeNotifier {
  bool _isSignedIn = false;

  bool get isSignedIn => _isSignedIn;
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  String? _uid;

  String get uid => _uid!;
  UserModel? _userModel;

  UserModel get userModel => _userModel!;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;


  Position? _currentPosition;
  Position? get currentPosition => _currentPosition;
  DatabaseReference bookingRef = FirebaseDatabase.instance.ref();

  // This will hold the count of bookings
  int _bookingCount = 0;

  int get bookingCount => _bookingCount;



  // Method to fetch bookings and update booking count
  Future<void> fetchBookings() async {
    try {
      DataSnapshot snapshot = await bookingRef
          .child('CustomerBookingDetails/${userModel.uid}')
          .get();

      if (snapshot.exists) {
        Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
        _bookingCount = data.length; // Count bookings based on data length
      } else {
        _bookingCount = 0; // No bookings found
      }

      notifyListeners(); // Notify listeners about the change
    } catch (e) {
      print("Error fetching bookings: $e");
      _bookingCount = 0; // Reset count on error
      notifyListeners();
    }
  }

  // Method to update the booking count
  void updateBookingCount(int count) {
    _bookingCount = count;
    notifyListeners();
  }


  LocationProvider() {
    getCurrentLocation();
  }





  AuthProvider() {
    checkSign();
  }

  void checkSign() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    _isSignedIn = s.getBool("is_signedin") ?? false;
    if (_isSignedIn) {
      getDataFromSP();  // Load user data if signed in
    }
    notifyListeners();
  }

  Future setSignIn() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    s.setBool("is_signedin", true);
    _isSignedIn = true;
    notifyListeners();
  }
  void signInWithPhone(BuildContext context, String phoneNumber) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential phoneAuthCredential) async {
          await _firebaseAuth.signInWithCredential(phoneAuthCredential);
        },
        verificationFailed: (error) {
          throw Exception(error.message);
        },
        codeSent: (verificationId, forceResendingToken) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OtpScreen(
                verificationID: verificationId,
              ),
            ),
          );
        },
        codeAutoRetrievalTimeout: (verificationId) {},
      );
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  void verifyOtp({
    required BuildContext context,
    required String verificationId,
    required String userOtp,
    required Function onSuccess,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      PhoneAuthCredential creds = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: userOtp);
      User user = (await _firebaseAuth.signInWithCredential(creds)).user!;
      if (user != null) {
        _uid = user.uid;
        onSuccess();
      }

      notifyListeners();
      _isLoading = false;
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message.toString());
      _isLoading = false;
      notifyListeners();
    }
  }

  // Database operations
  Future<bool> checkExistingUser() async {
    DocumentSnapshot snapshot =
        await _firebaseFirestore.collection("Customers").doc(_uid).get();
    if (snapshot.exists) {
      return true;
    } else {
      return false;
    }
  }

  void saveUserDataToFirebase({
    required BuildContext context,
    required UserModel userModel,
    required Function onSuccess,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      {
        userModel.createdAt = "${DateTime.now().day.toString()}-${DateTime.now().month.toString()}-${DateTime.now().year .toString()}";
        userModel.phoneNumber = _firebaseAuth.currentUser!.phoneNumber!;
        userModel.uid = _firebaseAuth.currentUser!.uid;
      };
      _userModel = userModel;

      // uploading to data base
      await _firebaseFirestore
          .collection("Customers")
          .doc(_uid)
          .set(userModel.toMap())
          .then((value) {
        onSuccess();
        _isLoading = false;
        notifyListeners();
      });
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message.toString());
      _isLoading = false;
      notifyListeners();
    }
  }

  Future getDataFromFirestore() async {
    await _firebaseFirestore
        .collection("Customers")
        .doc(_firebaseAuth.currentUser!.uid)
        .get()
        .then((DocumentSnapshot snapshot) {
      _userModel = UserModel(
          firstName: snapshot['firstName'],
          lastName: snapshot['lastName'],
          gender: snapshot['gender'],
          createdAt: snapshot['createdAt'],
          phoneNumber: snapshot['phoneNumber'],
          uid: snapshot['uid'],
          email: snapshot['email']);
      _uid = userModel.uid;
    });
  }

  // Storing data locally

  Future saveUserDataToSp() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.setString("user_model", jsonEncode(userModel.toMap()));
  }

  Future getDataFromSP() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String data = sp.getString("user_model") ?? '';
    _userModel = UserModel.fromMap(jsonDecode(data));
    _uid = _userModel!.uid;
    notifyListeners();
  }

  Future userSignOut() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    await _firebaseAuth.signOut();
    _isSignedIn = false;
    notifyListeners();
    sp.clear();
  }



  // Location Provider
  Future<void> getCurrentLocation() async {


    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      _currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
    }

  }

}
