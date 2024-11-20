

import 'package:didiroomms/utils/global/global_variables.dart';
import 'package:didiroomms/view/screens/login/splash.dart';
import 'package:didiroomms/view_models/InternetConnectivity/dependency_injection.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../view_models/provider/provider.dart';
void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Permission.locationWhenInUse.isDenied.then((value){
    if(value){
      Permission.locationWhenInUse.request();
    }
  });
  runApp(const MyApp());
  DependencyInjection.init();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_)=>AuthProvider()),
      ],
      child: GetMaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: mainColor),
          useMaterial3: true,


        ),
        home: SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
