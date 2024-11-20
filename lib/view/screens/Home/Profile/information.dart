import 'package:flutter/material.dart';

class InformationPage extends StatelessWidget {
  const InformationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "About Us",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome to Didicab",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              "My name is Muhammad Danish, and I am the creator of Didicab. "
                  "Didicab is designed to offer an intuitive and seamless experience for users seeking "
                  "reliable and efficient transportation services."
                  " Our app is built with a user-friendly interface to ensure that you can navigate "
                  "and use our features with ease.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              "About Didicab",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "At Didicab, our mission is to provide safe, affordable, and convenient transportation solutions"
                  " to our customers. We understand the importance of timely and secure rides,"
                  " which is why our app connects you with professional drivers in real-time. "
                  "Our platform ensures that every ride you take is monitored for safety, and we "
                  "strive to maintain the highest standards of service quality.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              "How to Use the App",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "Using Didicab is simple and straightforward. First, download the app from the App "
                  "Store or Google Play Store. Once installed, open the app and sign up with your "
                  "details. You can then enter your destination to find available drivers nearby."
                  " Select a ride option that suits your needs, and a driver will be on their way "
                  "to pick you up. Our app provides real-time tracking so you can see the exact "
                  "location of your driver and estimated arrival time.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              "Our Features",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "1. Real-time tracking: Monitor your ride in real-time with our integrated GPS"
                  " tracking system.\n\n2. Secure payments: Enjoy the convenience of secure payment "
                  "options including credit cards, debit cards, and mobile wallets.\n\n3."
                  " 24/7 customer support: Our dedicated customer support team is available around"
                  " the clock to assist you with any queries or issues.\n\n4. Ride history: Access"
                  " your ride history to review past trips and manage your travel expenses.\n\n5. "
                  "Safety features: We prioritize your safety with in-app emergency features, "
                  "driver background checks, and ride-sharing options.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              "Protection and Safety",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "Your safety is our top priority. At Didicab, we implement rigorous safety measures to ensure"
                  " that your ride is secure and comfortable. Our drivers undergo thorough background checks "
                  "and training to provide you with the best possible service. In addition, our app features "
                  "an emergency button that allows you to quickly contact local authorities and our support "
                  "team in case of any urgent situations. We are committed to offering a secure environment where you can travel with peace of mind.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              "Company Introduction",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "Didicab was founded with the vision of transforming the transportation "
                  "industry by providing an efficient and reliable ride-hailing service. "
                  "Our company is driven by innovation and a commitment to excellence. We continually "
                  "strive to enhance our platform with new features and improvements to meet the evolving needs of our users."
                  " We believe in the power of technology to connect people and improve lives, and we are dedicated to making every ride"
                  " with Didicab a pleasant experience.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              "Thank you for choosing Didicab. We look forward to serving you and making your journey enjoyable"
                  " and safe.",
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
