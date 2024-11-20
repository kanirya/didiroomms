import 'package:country_picker/country_picker.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../res/components/custom.dart';
import '../../../utils/global/global_variables.dart';
import '../../../view_models/provider/provider.dart';

class loginScreen extends StatelessWidget {
  const loginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 200),
              Padding(
                padding:  EdgeInsets.fromLTRB(0, 0, 40, 10),
                child: Text('Start booking with us.',style: TextStyle(fontFamily: 'montserrat',fontSize: 18,fontWeight: FontWeight.bold)),
              ),
              CustomButton(
                color: buttonColor,
                  text: "Get Started",
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => loginScreen2()));
                  }),
            ]
        ),
      ),
    );
  }
}

class loginScreen2 extends StatefulWidget {
  const loginScreen2({super.key});

  @override
  State<loginScreen2> createState() => _loginScreen2State();
}

class _loginScreen2State extends State<loginScreen2> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  bool isTablet(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.shortestSide >= 600;
  }

  @override
  Widget build(BuildContext context) {
    bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    bool tablet = isTablet(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          if (isLandscape || tablet)
            Positioned.fill(
              child: Image.asset(
                'assets/images/4.png',
                fit: BoxFit.cover,
              ),
            ),
          SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  height: 50,
                ),
                SizedBox(
                  height: 500,
                  width: 320,
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (int page) {
                      setState(() {
                        _currentPage = page;
                      });
                    },
                    children: [
                      buildPage(
                        imagePath: 'assets/images/2.svg',
                        title: 'Find The Best Deals',
                        subtitle:
                            'Find the best deals on a fraction of the price of existing options.',
                      ),
                      buildPage(
                        imagePath: 'assets/images/1.svg',
                        title: 'Plan Your Travel Now',
                        subtitle:
                            'Book didirooms in twin cities, escape the ordinary.',
                      ),
                      buildPage(
                        imagePath: 'assets/images/3.svg',
                        title: 'Book Easily',
                        subtitle:
                            'Book your favorite place in just a few clicks.',
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                // Adjusted gap between container and button
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:
                      List.generate(3, (index) => buildDot(index, context)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RegistrationScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.amber, // Button color
                          padding: EdgeInsets.symmetric(
                              horizontal: 60, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text('Log in'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPage({
    required String imagePath,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5), // Shadow below the container
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            imagePath,
            height: 250,
            placeholderBuilder: (BuildContext context) =>
                CircularProgressIndicator(
              strokeWidth: 1,
            ),
          ),
          SizedBox(height: 20),
          Text(
            title,
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 10),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDot(int index, BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(horizontal: 5),
      height: 10,
      width: _currentPage == index ? 12 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? Colors.amber : Colors.grey,
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController PhoneController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool loading = false;

  Country selectedCountry = Country(
    phoneCode: "92",
    countryCode: "PK",
    e164Sc: 0,
    geographic: true,
    level: 1,
    name: "Pakistan",
    example: "Pakistan",
    displayName: "Pakistan",
    displayNameNoCountryCode: "PK",
    e164Key: "",
  );

  @override
  Widget build(BuildContext context) {
    final bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final bool isTablet = MediaQuery.of(context).size.shortestSide >= 600;

    final double containerWidth = 375;
    final double containerHeight = 700;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            if (isLandscape || isTablet)
              Positioned.fill(
                child: Image.asset(
                  'assets/images/4.png',
                  fit: BoxFit.cover,
                ),
              ),
            Center(
              child: Container(
                width:isLandscape? containerWidth:MediaQuery.of(context).size.width,
                height: isLandscape? containerHeight:MediaQuery.of(context).size.height,
                color: Colors.white,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 25, horizontal: 35),
                  child: ListView(
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                          icon: Icon(Icons.arrow_back_ios),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      Container(
                        height: 100,
                        width: 100,
                        child: Icon(
                          Icons.lock,
                          size: 40,
                        ),
                      ),
                      const SizedBox(
                        height: 240,
                      ),
                      Center(
                        child: Text(
                          "Registration",
                          style: GoogleFonts.montserrat(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text(
                        "Add your phone number. We will send you a verification code",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black38,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              cursorColor: Colors.amber,
                              controller: PhoneController,
                              onChanged: (value) {
                                setState(() {
                                  PhoneController.text = value;
                                });
                              },
                              keyboardType: TextInputType.phone,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              decoration: InputDecoration(
                                alignLabelWithHint: true,
                                label: Text("Enter Phone Number"),
                                hintStyle: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                  color: Colors.grey.shade600,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      const BorderSide(color: Colors.black12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18,),
                                  borderSide:
                                      const BorderSide(color: Colors.black,width: 2),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  borderSide: const BorderSide(
                                    color: Colors.redAccent,
                                    width: 1.5,
                                  ),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  borderSide: const BorderSide(
                                    color: Colors.redAccent,
                                    width: 1.5,
                                  ),
                                ),
                                prefixIcon: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: Container(
                                    width: 70,
                                    height: 20,
                                    child: Center(
                                      child: InkWell(
                                        onTap: () {
                                          showCountryPicker(
                                            countryListTheme:
                                                const CountryListThemeData(
                                              bottomSheetHeight: 500,
                                            ),
                                            context: context,
                                            onSelect: (value) {
                                              setState(() {
                                                selectedCountry = value;
                                              });
                                            },
                                          );
                                        },
                                        child: Text(
                                          "${selectedCountry.flagEmoji} +${selectedCountry.phoneCode}",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                suffixIcon: PhoneController.text.length > 9
                                    ? Container(
                                        height: 30,
                                        width: 30,
                                        margin: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.green,
                                        ),
                                        child: const Icon(
                                          Icons.done,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      )
                                    : null,
                                errorStyle: TextStyle(
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.w500,
                                ),
                                errorMaxLines: 1,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Phone number is required';
                                }
                                if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                                  return 'Phone number can only contain digits';
                                }
                                if (value.length < 10) {
                                  return 'Phone number must be at least 10 digits';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    sendPhoneNumber();
                                  }
                                },
                                child: loading == true
                                    ? CircularProgressIndicator(
                                        color: Colors.black38,
                                        strokeWidth: 2,
                                      )
                                    : Text(
                                        "Login",
                                        style: TextStyle(color: mainColor),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
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

  void sendPhoneNumber() {
    setState(() {
      loading = true;
    });
    final ap = Provider.of<AuthProvider>(context, listen: false);
    String phoneNumber = PhoneController.text.trim();
    ap.signInWithPhone(context, "+${selectedCountry.phoneCode}$phoneNumber");
  }
}
