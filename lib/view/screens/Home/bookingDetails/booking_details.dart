import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../res/components/button_components.dart';
import '../../../../view_models/provider/provider.dart';
import 'extend_date.dart';

class CustomerBookingDetails extends StatefulWidget {
  @override
  _CustomerBookingDetailsState createState() => _CustomerBookingDetailsState();
}

class _CustomerBookingDetailsState extends State<CustomerBookingDetails> {
  final DatabaseReference bookingRef = FirebaseDatabase.instance.ref();
  List<Map<String, dynamic>> bookingList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBookings();
  }

  Future<void> fetchBookings() async {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    try {
      DataSnapshot snapshot = await bookingRef
          .child('CustomerBookingDetails/${ap.userModel.uid}')
          .get();

      List<Map<String, dynamic>> bookings = [];
      if (snapshot.exists) {
        Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
        data.forEach((key, value) {
          bookings.add(Map<String, dynamic>.from(value));
        });
      }

      setState(() {
        bookingList = bookings;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching bookings: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Bookings', style: GoogleFonts.poppins()),
        backgroundColor: Colors.yellow[700],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: bookingList.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> booking = bookingList[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookingDetailScreen(
                          days: booking['days'].toString(),
                          roomId: booking['roomId'],
                          total: booking['totalPrice'].toString(),
                          rooms: booking['numberOfRooms'].toString(),
                          checkin: booking['startDate'],
                          checkout: booking['endDate'],
                        ),
                      ),
                    );
                  },
                  child: Card(
                    margin: EdgeInsets.all(10),
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Check In Date: ${booking['startDate']}",
                            style: GoogleFonts.poppins(fontSize: 16),
                          ),
                          Text(
                            "Check Out Date: ${booking['endDate']}",
                            style: GoogleFonts.poppins(fontSize: 16),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  "Days: ${booking['days']}",
                                  style: GoogleFonts.poppins(fontSize: 16),
                                ),
                                Text(
                                  "Rooms: ${booking['numberOfRooms']}",
                                  style: GoogleFonts.poppins(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            "Total Price: Rs ${booking['totalPrice']}",
                            style: GoogleFonts.poppins(
                                fontSize: 16, color: Colors.green[600]),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class BookingDetailScreen extends StatefulWidget {
  final String roomId; // Pass the roomId to fetch room details
  final String days; // Total days for the booking
  final String total;
  final String rooms;
  final String checkin;
  final String checkout;

  const BookingDetailScreen({
    super.key,
    required this.roomId,
    required this.days,
    required this.total,
    required this.rooms,
    required this.checkin,
    required this.checkout,
  });

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  Map<String, dynamic>? roomData;
  Map<String, dynamic>? ownerData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRoomDetails(); // Fetch room details when the screen loads
  }

  // Fetch room details from Firestore
  Future<void> _fetchRoomDetails() async {
    try {
      DocumentSnapshot roomSnapshot = await FirebaseFirestore.instance
          .collection('Rooms')
          .doc(widget.roomId)
          .get();

      if (roomSnapshot.exists) {
        setState(() {
          roomData = roomSnapshot.data() as Map<String, dynamic>?;
          _fetchOwnerDetails(roomData!['ownerId']); // Fetch owner details
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching room details: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Fetch owner details from Firestore
  Future<void> _fetchOwnerDetails(String ownerId) async {
    try {
      DocumentSnapshot ownerSnapshot = await FirebaseFirestore.instance
          .collection('owners')
          .doc(ownerId)
          .get();

      if (ownerSnapshot.exists) {
        setState(() {
          ownerData = ownerSnapshot.data() as Map<String, dynamic>?;
        });
      }
    } catch (e) {
      print('Error fetching owner details: $e');
    }
  }

  // Build room details UI
  Widget _buildRoomDetails() {
    if (roomData == null) {
      return Center(child: Text('No data available for this room.'));
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              roomData!['roomType'] ?? 'Room Type',
              style: GoogleFonts.poppins(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Total Amount: Rs ${widget.total}',
              style: GoogleFonts.poppins(
                fontSize: 22,
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Total Days: ${widget.days}',
              style: GoogleFonts.poppins(
                fontSize: 20,
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'No of Rooms: ${widget.rooms}',
              style: GoogleFonts.poppins(
                fontSize: 20,
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.amber),
                SizedBox(width: 10),
                Text(
                  'Check-in: ${widget.checkin}',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            SizedBox(height: 5),
            Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.amber),
                SizedBox(width: 10),
                Text(
                  'Check-out: ${widget.checkout}',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            Divider(color: Colors.amber, thickness: 2),
            SizedBox(height: 8),
            Text(
              'Location:',
              style: GoogleFonts.poppins(
                  fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.amber, size: 30),
                SizedBox(width: 5),
                Expanded(
                  child: Text(
                    '${roomData!['location']['city']}, ${roomData!['location']['street']}',
                    style: GoogleFonts.poppins(fontSize: 18),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.near_me, color: Colors.amber, size: 30),
                SizedBox(width: 5),
                Expanded(
                  child: Text(
                    '${roomData!['location']['landmark']}',
                    style: GoogleFonts.poppins(fontSize: 18),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _openGoogleMaps,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
              ),
              child: Text(
                'Locate on Google Maps',
                style: GoogleFonts.poppins(fontSize: 16),
              ),
            ),
            SizedBox(height: 20),
            Divider(color: Colors.amber, thickness: 2),
            SizedBox(height: 8),
            Text(
              'Amenities:',
              style: GoogleFonts.poppins(
                  fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Wrap(
              spacing: 8.0,
              children: _buildAmenitiesIcons(),
            ),
            SizedBox(height: 20),
            Divider(color: Colors.amber, thickness: 2),
            SizedBox(height: 8),
            Text(
              'Images:',
              style: GoogleFonts.poppins(
                  fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Container(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: (roomData!['imageUrl'] as List).length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        roomData!['imageUrl'][index],
                        width: 150,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            _buildOwnerDetails(),
            SizedBox(height: 20),
            CustomButton(
              color: Colors.black,
              text: "Extend your stay",
              cornerRadius: 4,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ExtendBookingScreen(
                      checkoutDate: widget.checkout,
                      beforeCost: double.parse(widget.total),
                      dailyRate: double.parse(roomData!['price']),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _canCheckIn() ? _handleCheckIn : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _canCheckIn() ? Colors.amber : Colors.grey,
                  ),
                  child: Text(
                    'Check In',
                    style: GoogleFonts.poppins(fontSize: 16),
                  ),
                ),
                ElevatedButton(
                  onPressed: _canCheckOut() ? _handleCheckOut : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _canCheckOut() ? Colors.amber : Colors.grey,
                  ),
                  child: Text(
                    'Check Out',
                    style: GoogleFonts.poppins(fontSize: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openGoogleMaps() async {
    GeoPoint geoPoint =
        roomData!['latlng']; // Fetch the GeoPoint from Firestore
    final latitude = geoPoint.latitude; // Get the latitude
    final longitude = geoPoint.longitude; // Get the longitude

    final url =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  // Build amenities list based on available services and display as icons
  List<Widget> _buildAmenitiesIcons() {
    List<Widget> amenitiesIcons = [];
    Map<String, dynamic>? services = roomData!['Services'];

    if (services != null) {
      services.forEach((service, isAvailable) {
        if (isAvailable) {
          IconData iconData;
          switch (service.toLowerCase()) {
            case 'wifi':
              iconData = Icons.wifi;
              break;
            case 'food':
              iconData = Icons.fastfood;
              break;
            case 'laundry':
              iconData = Icons.local_laundry_service;
              break;
            case 'parking':
              iconData = Icons.local_parking;
              break;
            case 'roomservice':
              iconData = Icons.room_service;
              break;
            case 'workstation':
              iconData = Icons.computer;
              break;
            case 'library':
              iconData = Icons.library_books;
              break;
            default:
              iconData = Icons.info; // Default icon
          }

          amenitiesIcons.add(
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(iconData, color: Colors.amber, size: 30),
                Text(service, style: GoogleFonts.poppins(fontSize: 12)),
              ],
            ),
          );
        }
      });
    } else {
      amenitiesIcons.add(Text('No amenities available.'));
    }

    return amenitiesIcons;
  }

  Widget _buildOwnerDetails() {
    if (ownerData == null) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'Owner details not available.',
          style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.amber, width: 2),
      ),
      margin: EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(ownerData!['imageUrl']),
                child: ownerData!['imageUrl'] == null
                    ? Icon(Icons.person, size: 30, color: Colors.grey)
                    : null,
              ),
              SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ownerData!['name'] ?? 'Owner Name',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      ownerData!['phone'] ?? 'Owner Phone',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Check if the user can check-in
  bool _canCheckIn() {
    DateTime checkInDate = DateTime.parse(widget.checkin);
    return DateTime.now().isAfter(checkInDate.subtract(Duration(hours: 12))) &&
        DateTime.now().isBefore(checkInDate.add(Duration(days: 1)));
  }

  // Check if the user can check-out
  bool _canCheckOut() {
    DateTime checkOutDate = DateTime.parse(widget.checkout);
    return DateTime.now().isBefore(checkOutDate.add(Duration(hours: 12))) &&
        DateTime.now().isAfter(checkOutDate.subtract(Duration(days: 1)));
  }

  // Handle check-in action
  void _handleCheckIn() {
    // Implement check-in logic here
    print('Check In Button Pressed');
  }

  // Handle check-out action
  void _handleCheckOut() {
    // Implement check-out logic here
    print('Check Out Button Pressed');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Booking Details', style: GoogleFonts.poppins()),
        backgroundColor: Colors.amber,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : _buildRoomDetails(),
    );
  }
}
