import 'package:climate_app/homescreen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      primaryColor: Colors.white,
      accentColor: Colors.white,

    ),
    home: HomeScreen(),
  ));
}



