import 'package:flutter/material.dart';
import 'screens/weather_screen.dart';

void main() {
  runApp(MyApp());
}

const double lat = 21.0285;
const double lon = 105.8542;

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: WeatherScreen(latitude: lat, longitude: lon),
    );
  }
}