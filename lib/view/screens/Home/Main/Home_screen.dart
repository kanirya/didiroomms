import 'package:awesome_icons/awesome_icons.dart';
import 'package:didiroomms/view/screens/Home/Main/room_search.dart';
import 'package:didiroomms/view/screens/Home/Main/search_place.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../../../utils/global/global_variables.dart';
import '../../../../view_models/provider/provider.dart';
import '../Profile/profile.dart';
import '../bookingDetails/booking_details.dart';

class homeScreen extends StatefulWidget {
  const homeScreen({super.key});

  @override
  State<homeScreen> createState() => _homeScreenState();
}

class _homeScreenState extends State<homeScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  void initState() {
    super.initState();
    // Fetch bookings when this screen initializes
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.fetchBookings();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final bookingCount = authProvider.bookingCount;
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: <Widget>[
          Page1Screen(),
          CustomerBookingDetails(),
          Page3Screen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(
            icon: Icon(
              Icons.home_max,
              size: 30,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(
                  Icons.book,
                  size: 35,
                ),
                if (bookingCount > 0)
                  Positioned(
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: BoxConstraints(
                        maxWidth: 20,
                        maxHeight: 20,
                      ),
                      child: Text(
                        '$bookingCount',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Bookings',
          ),
          const BottomNavigationBarItem(
            icon: Icon(
              Icons.history_edu,
              size: 37,
            ),
            label: 'History',
          ),
          const BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.userEdit),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}

class Page1Screen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: SvgPicture.asset(
            "assets/images/DIDIrooms.svg",
            color: mainColor,
          )),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        SearchScreen(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      const begin =
                          Offset(0.0, 1.0); // Start from below the screen
                      const end =
                          Offset.zero; // End at the center of the screen
                      const curve = Curves.easeInOut;

                      final tween = Tween(begin: begin, end: end)
                          .chain(CurveTween(curve: curve));
                      final offsetAnimation = animation.drive(tween);

                      return SlideTransition(
                        position: offsetAnimation,
                        child: child,
                      );
                    },
                  ));
                },
                borderRadius: BorderRadius.circular(20.0),
                splashColor: Colors.blueGrey.withOpacity(0.3),
                child: Container(
                  width: MediaQuery.of(context).size.width * .9,
                  height: 40,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.grey[250],
                      border: Border.all(width: 1)),
                  constraints: BoxConstraints(maxWidth: 400, minWidth: 300),
                  child: const Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          FontAwesomeIcons.searchLocation,
                          size: 18,
                        ),
                      ),
                      Text('Search for city, location or hotel')
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              height: 100,
              width: double.infinity,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      circularPlaceCard(
                          placeName: "Near by",
                          function: () {
                            ap.getCurrentLocation().then((onValue) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NearbyRoomsScreen(
                                    Rlocation: LatLng(
                                        ap.currentPosition!.latitude,
                                        ap.currentPosition!.longitude),
                                  ),
                                ),
                              );
                            });
                          },
                          icon: Icons.near_me,
                          backgroundColor: Colors.black12,
                          iconSize: 30,
                          iconColor: Colors.blue,
                          textColor: Colors.blue),
                      circularPlaceCard(
                          placeName: "Islamabad",
                          function: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NearbyRoomsScreen(
                                  Rlocation: LatLng(33.659357, 73.069142),
                                ),
                              ),
                            );
                          },
                          imageUrl: 'assets/images/islamabad.jpg'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget circularPlaceCard({
    String? imageUrl, // Make imageUrl optional
    IconData? icon, // Add an optional icon parameter
    required String placeName,
    required VoidCallback function,
    double containerSize = 55.0,
    double imageSize = 55.0,
    double iconSize = 24.0, // Add an icon size parameter
    double textSize = 13.0,
    Color backgroundColor = Colors.white,
    Color textColor = Colors.black,
    Color iconColor = Colors.black, // Add an icon color parameter
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(25),
          onTap: function,
          splashColor: Colors.blueGrey.withOpacity(0.3),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Container(
              width: containerSize,
              height: containerSize,
              decoration: BoxDecoration(
                color: backgroundColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: imageUrl != null // Check if imageUrl is provided
                    ? CircleAvatar(
                        radius: imageSize / 2,
                        backgroundImage: AssetImage(imageUrl),
                      )
                    : Icon(
                        icon, // If no image, display the icon
                        size: iconSize,
                        color: iconColor,
                      ),
              ),
            ),
          ),
        ),
        SizedBox(height: 8.0),
        Text(
          placeName,
          style: TextStyle(
            fontSize: textSize,
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class Page2Screen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Page 2')),
      body: Center(
        child: Text(
          'This is Page 2',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

class Page3Screen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Page 3')),
      body: Center(
        child: Text(
          'This is Page 3',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
