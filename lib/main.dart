import 'package:climate_app/splash.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
     primaryColor: Colors.white,
    ),
    home: const SplashScreen(),
  ));
}  