import 'package:flutter/material.dart';
import 'package:weather_app/weather_app_homepage.dart';

void main() {
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget{
  const WeatherApp({super.key});

  @override
  Widget build (BuildContext context){
    return MaterialApp(
        home: WeatherAppHomepage()
    );
  }
}