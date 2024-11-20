import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'dart:math';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../../../view_models/provider/provider.dart';
import 'Room_booking.dart';

class NearbyRoomsScreen extends StatefulWidget {
  final LatLng Rlocation;

  NearbyRoomsScreen({super.key, required this.Rlocation});

  @override
  _NearbyRoomsScreenState createState() => _NearbyRoomsScreenState();
}

class _NearbyRoomsScreenState extends State<NearbyRoomsScreen> {
  final CollectionReference roomsRef =
  FirebaseFirestore.instance.collection('Rooms');

  String _selectedSortOption = 'Nearest';
  String _selectedRoomType = 'All';
  List<String> roomTypes = ['All']; // Default room type list with 'All'
  RangeValues _selectedPriceRange = RangeValues(500, 10000); // Default price range
  double minPrice = 500;
  double maxPrice = 10000;

  @override
  void initState() {
    super.initState();
    _fetchRoomTypes();
  }




  Future<List<Map<String, dynamic>>> _fetchNearbyRooms() async {
    QuerySnapshot snapshot = await roomsRef.get();
    List<Map<String, dynamic>> nearbyRooms = [];

    for (var doc in snapshot.docs) {
      GeoPoint roomLocation = doc['latlng'];
      double distance = calculateDistance(
        widget.Rlocation.latitude,
        widget.Rlocation.longitude,
        roomLocation.latitude,
        roomLocation.longitude,
      );

      // Check if 'price' is stored as an int or String and handle accordingly
      int roomPrice;
      if (doc['price'] is int) {
        roomPrice = doc['price'];
      } else if (doc['price'] is String) {
        roomPrice = int.parse(doc['price']);
      } else {

        continue;
      }

      // Filter rooms based on distance, room type, and price range
      if (distance <= 25 &&
          (_selectedRoomType == 'All' || doc['roomType'] == _selectedRoomType) &&
          roomPrice >= _selectedPriceRange.start &&
          roomPrice <= _selectedPriceRange.end) {
        nearbyRooms.add({
          'room': doc,
          'distance': distance,
        });
      }
    }

    _sortRooms(nearbyRooms);

    return nearbyRooms;
  }

  // Fetch room types from Firestore and update roomTypes list
  Future<void> _fetchRoomTypes() async {
    QuerySnapshot snapshot = await roomsRef.get();
    Set<String> typesSet = {'All','King Suite','Twin Suite','Dormitory'}; // Use a set to avoid duplicates

    for (var doc in snapshot.docs) {
      String roomType = doc['roomType'];
      typesSet.add(roomType);
    }

    setState(() {
      roomTypes = typesSet.toList(); // Update the room types dynamically
    });
  }

  // Haversine Formula for distance calculation
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371; // Radius of the Earth in km
    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = R * c;
    return distance;
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }


  void _sortRooms(List<Map<String, dynamic>> rooms) {
    if (_selectedSortOption == 'Nearest') {
      rooms.sort((a, b) => a['distance'].compareTo(b['distance']));
    } else if (_selectedSortOption == 'Far') {
      rooms.sort((a, b) => b['distance'].compareTo(a['distance']));
    } else if (_selectedSortOption == 'Mixed') {
      rooms.shuffle();
    }
  }
  int getAvailableRooms(Map<String, dynamic> roomData) {
    // Check if roomAvailability exists and has a value for 'available'
    if (roomData.containsKey('roomAvailability') && roomData['roomAvailability'] != null) {
      Map<String, dynamic> roomAvailability = roomData['roomAvailability'];
      if (roomAvailability.containsKey('available') && roomAvailability['available'] != null) {
        // Return the available number of rooms
        return roomAvailability['available'];
      }
    }

    // If roomAvailability or 'available' is missing, return total rooms count
    if (roomData.containsKey('rooms') && roomData['rooms'] != null) {
      return int.parse(roomData['rooms']);  // Assuming rooms is stored as a string, convert it to an int
    }

    // Default to 0 if no data is available
    return 0;
  }

  Widget _buildRoomCard(DocumentSnapshot room, double distance) {
    List<dynamic> imageUrls = room['imageUrl'];
    List<String> imageUrl = List<String>.from(imageUrls);
    Map<String, dynamic> services = room['Services'];
    Map<String, dynamic> location = room['location'];
    String price = room['price'];
    String roomType = room['roomType'];


    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RoomBookingCalendar(
                imageUrls: imageUrl,
                roomId: room.id,
                price: room['price'],
                location: room['location'],
                services: room['Services'],
                ownerId: room['ownerId'],
                roomType: room['roomType'],
              ),
            ),
          );
        },
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  CarouselSlider.builder(
                    itemCount: imageUrls.length,
                    itemBuilder: (context, index, realIndex) {
                      return buildImage(
                          imageUrls[index], index, imageUrls.length);
                    },
                    options: CarouselOptions(
                      height: 200,
                      enlargeCenterPage: true,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${location['city']}, ${location['street']}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                    SizedBox(height: 7),
                    Text(
                      'Landmark: ${location['landmark']}',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Price: Rs $price/-',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    Text(
                      'Room Type: $roomType',
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '${distance.toStringAsFixed(2)} km away from searched location',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                    Divider(color: Colors.grey),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          if (services['AC'])
                            _buildServiceIcon("AC"),
                          if (services['wifi'])
                            _buildServiceIcon("WiFi"),
                          if (services['Food'])
                            _buildServiceIcon("Food"),
                          if (services['laundry'])
                            _buildServiceIcon("Laundry"),
                          if (services['parking'])
                            _buildServiceIcon("Parking"),
                          if (services['roomService'])
                            _buildServiceIcon("Room Service"),
                          if (services['library'])
                            _buildServiceIcon("Library"),
                          if (services['workStation'])
                            _buildServiceIcon("WorkStation"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildImage(String url, int index, int totalImages) {
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            image: DecorationImage(
              image: NetworkImage(url),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          bottom: 10,
          right: 10,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${index + 1}/$totalImages',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildServiceIcon(String label) {
    return
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: Colors.grey,
            ),
            child: Padding(
              padding: const EdgeInsets.all(3.0),
              child: Text(
                label,
                style: TextStyle(fontSize: 10,color: Colors.white),
              ),
                ),
          ),
        );
  }
  void _showPriceRangeModal() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        RangeValues tempPriceRange = _selectedPriceRange; // Temporary variable to track the live state within the modal

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Select Price Range',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                  ),
                  RangeSlider(
                    values: tempPriceRange,
                    min: minPrice,
                    max: maxPrice,
                    divisions: 20,
                    labels: RangeLabels(
                      '${tempPriceRange.start.toStringAsFixed(0)}',
                      '${tempPriceRange.end.toStringAsFixed(0)}',
                    ),
                    onChanged: (RangeValues values) {
                      setModalState(() {
                        tempPriceRange = values; // Update modal state in real-time
                      });
                    },
                    activeColor: Colors.blueGrey,
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedPriceRange = tempPriceRange;
                      });
                      Navigator.pop(context); // Close modal after selecting range
                    },
                    child: Text('Apply',style: TextStyle(color: Colors.white),),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: Text('Available Rooms Nearby',style: GoogleFonts.lato(textStyle: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 19)),),
      ),
      body: Column(
        children: [
          // Filters Row
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Room Type Filter
                Expanded(
                  child: InkWell(
                    onTap: () {

                      showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          return Container(
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: roomTypes.map((type) {
                                  return ListTile(
                                    title: Text(type),
                                    onTap: () {
                                      setState(() {
                                        _selectedRoomType = type;
                                      });
                                      Navigator.pop(context);
                                    },
                                  );
                                }).toList(),
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blueGrey, width: 1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedRoomType,
                            style: TextStyle(color: Colors.blueGrey),
                          ),
                          Icon(Icons.arrow_drop_down, color: Colors.blueGrey),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 4),

                // Sorting Filter
                Expanded(
                  child: InkWell(
                    onTap: () {
                      // Sort dropdown
                      showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          return Container(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <String>['Nearest', 'Mixed', 'Far']
                                  .map((sortOption) {
                                return ListTile(
                                  title: Text(sortOption),
                                  onTap: () {
                                    setState(() {
                                      _selectedSortOption = sortOption;
                                    });
                                    Navigator.pop(context);
                                  },
                                );
                              }).toList(),
                            ),
                          );
                        },
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blueGrey, width: 1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedSortOption,
                            style: TextStyle(color: Colors.blueGrey),
                          ),
                          Icon(Icons.arrow_drop_down, color: Colors.blueGrey),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 4),

                // Price Range Filter
                Expanded(
                  child: InkWell(
                    onTap: () {
                      _showPriceRangeModal();
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 3),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blueGrey, width: 1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Price Range',
                            style: TextStyle(color: Colors.blueGrey),
                          ),
                          Icon(Icons.attach_money, color: Colors.blueGrey),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Room List
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchNearbyRooms(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error fetching rooms."));
                } else if (snapshot.hasData) {
                  List<Map<String, dynamic>> nearbyRooms = snapshot.data!;
                  if (nearbyRooms.isEmpty) {
                    return Center(child: Text("No rooms found nearby."));
                  } else {
                    return ListView.builder(
                      itemCount: nearbyRooms.length,
                      itemBuilder: (context, index) {
                        var roomData = nearbyRooms[index];
                        DocumentSnapshot room = roomData['room'];
                        double distance = roomData['distance'];
                        return _buildRoomCard(room, distance);
                      },
                    );
                  }
                } else {
                  return Center(child: Text("No data found."));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
