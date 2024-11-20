import 'dart:convert';
import 'dart:math';
import 'package:didiroomms/view/screens/Home/Main/room_search.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../../../../view_models/provider/provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({
    super.key,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _searchController = TextEditingController();
  bool _isSearchActive = false; // Track if the search field is active
  String _sessionToken = '123456789'; // If GoMaps requires session token
  List<dynamic> _placeSuggestions = []; // Store place suggestions
  FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_searchFocusNode); // Request focus
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_sessionToken.isEmpty) {
      setState(() {
        _sessionToken = (Random().nextInt(100000).toString());
      });
    }
    getSuggestions(_searchController.text);
  }

  void getSuggestions(String input) async {
    const String apiKey = "AlzaSyFM2AsH94SYO6Dc56j_vpMFZznvNTacn-w";
    String baseURL = 'https://maps.gomaps.pro/maps/api/place/autocomplete/json';
    String request =
        '$baseURL?input=$input&key=$apiKey&sessiontoken=$_sessionToken';

    try {
      var response = await http.get(Uri.parse(request));
      if (response.statusCode == 200) {
        setState(() {
          _placeSuggestions = json.decode(response.body)['predictions'];
        });
      } else {
        throw Exception('Failed to load predictions');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<Map<String, dynamic>> getPlaceDetails(String placeId) async {
    const String apiKey = "AlzaSyFM2AsH94SYO6Dc56j_vpMFZznvNTacn-w";
    String baseURL = 'https://maps.gomaps.pro/maps/api/place/details/json';
    String request = '$baseURL?place_id=$placeId&key=$apiKey';

    var response = await http.get(Uri.parse(request));

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['result'];
    } else {
      throw Exception('Failed to load place details');
    }
  }

  void _clearSearch() {
    _searchController.clear(); // Clear the search field
    setState(() {
      _isSearchActive = false;
      _placeSuggestions = []; // Clear suggestions when search is cleared
    });
  }

  @override
  Widget build(BuildContext context) {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Search Form with Back Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Search Field
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      decoration: InputDecoration(
                        hintStyle: TextStyle(fontSize: 14),
                        hintText: 'Search for city, location or hotel',
                        prefixIcon: IconButton(
                          icon: Icon(Icons.arrow_back),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        suffixIcon: _isSearchActive
                            ? IconButton(
                                icon: Icon(Icons.clear),
                                onPressed:
                                    _clearSearch, // Clear the search text
                              )
                            : null,
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 16.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Nearby Location Option
            InkWell(
              onTap: () {
                ap.getCurrentLocation().then((onValue) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NearbyRoomsScreen(
                        Rlocation: LatLng(ap.currentPosition!.latitude,
                            ap.currentPosition!.longitude),
                      ),
                    ),
                  );
                });
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
                child: Row(
                  children: [
                    Icon(Icons.my_location, color: Colors.blueAccent),
                    SizedBox(width: 8),
                    Text(
                      'Use my current location',
                      style: TextStyle(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),

            // Suggested Locations or Result List
            Expanded(
              child: _placeSuggestions.isEmpty
                  ? Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search, color: Colors.grey, size: 32),
                          SizedBox(width: 8),
                          Text(
                            'No suggestions available.',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _placeSuggestions.length,
                      itemBuilder: (context, index) {
                        var suggestion = _placeSuggestions[index];
                        return InkWell(
                          onTap: () async {
                          var placeDetails = await getPlaceDetails(suggestion['place_id']);
                          var lat = placeDetails['geometry']['location']['lat'];
                          var lng = placeDetails['geometry']['location']['lng'];

                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) => NearbyRoomsScreen(
                                Rlocation: LatLng(lat, lng), // Pass the latitude and longitude here
                              ),
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                const begin = Offset(1.0, 0.0); // Start off-screen to the right
                                const end = Offset.zero; // End at the center of the screen
                                const curve = Curves.easeInOut;

                                // Define the animation
                                var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                var offsetAnimation = animation.drive(tween);

                                // Build the transition
                                return SlideTransition(
                                  position: offsetAnimation,
                                  child: child,
                                );
                              },
                            ),
                          );
                        },

                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 16.0),
                            child: Row(
                              children: [
                                Icon(Icons.location_on_outlined,
                                    color: Colors.blue),
                                // Location icon
                                SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        suggestion['structured_formatting']
                                                ['main_text'] ??
                                            '',
                                        style: TextStyle(
                                          color: Colors.black,
                                          // Highlighted main text
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        suggestion['structured_formatting']
                                                ['secondary_text'] ??
                                            '',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          // Grey color for description
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            )
          ],
        ),
      ),
    );
  }
}
