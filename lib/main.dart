import 'package:admin_mysiswa/webpages/home_webpage.dart';
import 'package:admin_mysiswa/webpages/login_webpage.dart';
import 'package:admin_mysiswa/webpages/overview_webpage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyDUnUj2X38xYOhzwB3pQEDXjfHw4lAC3lU",
      authDomain: "student-card-appointment-f7812.firebaseapp.com",
      projectId: "student-card-appointment-f7812",
      storageBucket: "student-card-appointment-f7812.appspot.com",
      messagingSenderId: "254546470262",
      appId: "1:254546470262:web:58b11df8cc65520ad58657",
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Web App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
