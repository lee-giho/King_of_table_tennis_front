import 'package:flutter/material.dart';
import 'package:king_of_table_tennis/screen/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "king_of_table_tennis",
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.light(),
        primarySwatch: Colors.red
      ),
      home: LoginScreen(),
    );
  }
}