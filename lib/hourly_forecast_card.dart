import 'package:flutter/material.dart';

class HourlyForecastCard extends StatelessWidget {
  final String time;
  final IconData weather;
  final String temp;

  const HourlyForecastCard({
    super.key,
    required this.time,
    required this.weather,
    required this.temp
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 7.5, horizontal: 25),
      margin: EdgeInsets.all(8),
      decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(10),
          color: Color.fromRGBO(25, 28, 30, 1)
      ),
      child: Column(
        children: [
          Text(
            time,
            style: TextStyle(color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          Icon(weather, size: 45, color: Colors.white),
          Text(
            temp,
            style: TextStyle(color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              height: 2,
              letterSpacing: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}