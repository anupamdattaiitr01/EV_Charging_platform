import 'package:flutter/material.dart';
import 'package:multi_page_ev_charge/getstarted_page.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {

  // This ensures that all the flutter framework is fully booted even before executing the native flutter code
  // Establishes the connection between the dart code and computer hardware
  // Dart code  <=> C++ code that talks to the computer hardware
  // Also present in the runApp function
  // done to establish connection before calling runApp
  // So that Firebase connection is made securely

  WidgetsFlutterBinding.ensureInitialized();

  //tells the app exactly to which online database to talk to when we requested an authentication process

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  // Key is like the unique id that is handed over by the MyApp
  // to the parent class Stateless Widget to keep record of each widget

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Widget => return type of the function build
    // build => function that is called when app loads and if state changes
    // context => acts a GPS location --> helps to know the exact screen and
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      // entry route for the app
      // loads this page first
      home: getstarted_page(),
    );
  }
}