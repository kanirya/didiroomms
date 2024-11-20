import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class NetworkController extends GetxController {
  final Connectivity _connectivity = Connectivity();

  @override
  void onInit() {
    super.onInit();
    _checkInitialConnection();
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  void _updateConnectionStatus(ConnectivityResult connectivityResult) async {
    if (connectivityResult == ConnectivityResult.none) {
      _showNoInternetSnackbar("No Internet Connection");
    } else {
      // Check if the device is connected to the internet
      bool isConnected = await _checkInternetConnection();
      if (!isConnected) {
        _showNoInternetSnackbar("Internet is not working");
      } else {
        if (Get.isSnackbarOpen) {
          Get.closeCurrentSnackbar();
        }
      }
    }
  }

  Future<void> _checkInitialConnection() async {
    ConnectivityResult result;
    try {
      result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
    } catch (e) {
      print('Failed to check connectivity: $e');
    }
  }

  Future<bool> _checkInternetConnection() async {
    try {
      // Try to connect to a reliable server
      final response = await http.get(Uri.parse('https://www.google.com'));
      return response.statusCode == 200; // Internet is working
    } catch (e) {
      return false; // No internet
    }
  }

  void _showNoInternetSnackbar(String message) {
    Get.rawSnackbar(
      messageText: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off, color: Colors.white, size: 30),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    offset: Offset(0.5, 0.5),
                    blurRadius: 3.0,
                    color: Colors.black.withOpacity(0.3),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.amber, // Yellow background
      snackStyle: SnackStyle.FLOATING,
      snackPosition: SnackPosition.TOP,
      borderRadius: 15,
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: EdgeInsets.all(15),
      boxShadows: [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          offset: Offset(0, 4),
          blurRadius: 10,
          spreadRadius: 1,
        )
      ],
      isDismissible: false,
      duration: Duration(days: 1),
      overlayBlur: 10.0,
      mainButton: TextButton(
        onPressed: () {
          Get.closeCurrentSnackbar();
          _checkInitialConnection();
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            "Retry",
            style: TextStyle(
              color: Colors.amber,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
