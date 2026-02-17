import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/current_condition_card.dart';
import 'package:weather_app/hourly_forecast_card.dart';
import 'weather_api.dart';

class WeatherAppHomepage extends StatefulWidget {
  const WeatherAppHomepage({super.key});

  @override
  State<WeatherAppHomepage> createState() => _WeatherAppHomepageState();
}

class _WeatherAppHomepageState extends State<WeatherAppHomepage> {
  late Future<Map<String, dynamic>> weather;
  late Future<String> sky;

  Future<String> getCurrentSky() async {
    try {
      String cityName = "Bhubaneswar";
      final res = await http.get(
        Uri.parse(
            "https://api.openweathermap.org/data/2.5/weather?q=$cityName&APPID=$openWeatherAPIkey"),
      );

      if (res.statusCode != 200) {
        throw 'Failed to load sky condition';
      }

      final data = jsonDecode(res.body);
      return data['weather'][0]['main'];
    } catch (e) {
      return 'Unknown';
    }
  }

  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      String cityName = "Bhubaneswar";

      final res = await http.get(
          Uri.parse("https://api.tomorrow.io/v4/weather/forecast?location=$cityName&apikey=$weatherAPIkey")
      );

      final data = jsonDecode(res.body);

      if (res.statusCode != 200) {
        throw "Error: ${data['message'] ?? 'An unknown error occurred'}";
      }

      return data;

    } catch (e) {
      throw e.toString();
    }
  }

  @override
  void initState() {
    super.initState();
    weather = getCurrentWeather();
    sky = getCurrentSky();
  }

  @override
  Widget build (BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(25, 28, 30, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(25, 28, 30, 1),
        leading: const Icon(Icons.location_on_rounded, color: Colors.white, size: 28),
        title: const Text("Weather App"),
        titleSpacing: 1,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            iconSize: 25,
            color: Colors.white,
            onPressed: () {
              setState(() {});
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: Future.wait([
          weather,
          sky,
        ]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator.adaptive(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          }

          final tomorrowIoData = snapshot.data![0] as Map<String, dynamic>;
          final currentSky = snapshot.data![1] as String;
          final currentWeatherData = tomorrowIoData['timelines']['minutely'][0]['values'];
          final currentTemp = (currentWeatherData['temperature']);
          final pressure = currentWeatherData['pressureSurfaceLevel'];
          final humidity = currentWeatherData['humidity'];
          final windSpeed = currentWeatherData['windSpeed'];
          final uvIndex = currentWeatherData['uvIndex'];
          final precipitation = currentWeatherData['rainIntensity'];
          final visibility = currentWeatherData['visibility'];

          final hourlyForecasts = tomorrowIoData['timelines']['hourly'] as List;
          final now = DateTime.now();
          final startIndex = hourlyForecasts.indexWhere((forecast) {
            final forecastTime = DateTime.parse(forecast['time']);
            return forecastTime.isAfter(now);
          });
          final validStartIndex = startIndex == -1 ? 0 : startIndex;

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 10,
                  color: const Color.fromRGBO(39, 43, 46, 1),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: SizedBox(
                        width: 405,
                        height: 220,
                        child: Column(
                          children: [
                            Icon(
                                currentSky == 'Clear' ?  Icons.sunny : Icons.cloud,
                                size: 90,
                                color: Colors.white
                            ),
                            Text('${currentTemp.toStringAsFixed(1)} °C',
                              style: const TextStyle(color: Colors.white,
                                fontSize: 50,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Text(currentSky,
                              style: const TextStyle(color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 10,
                  color: const Color.fromRGBO(39, 43, 46, 1),
                  margin: const EdgeInsets.fromLTRB(20, 15, 20, 5),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                            children: [
                              const Row(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(8, 3, 8, 7),
                                    child: Text("Current conditions",
                                      style: TextStyle(color: Colors.white,
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      CurrentConditionCard(
                                        icon: Icons.remove_red_eye,
                                        title: 'Visibility',
                                        value: '$visibility',
                                      ),
                                      CurrentConditionCard(
                                        icon: Icons.wb_sunny_sharp,
                                        title: 'UV index',
                                        value: '$uvIndex',
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      CurrentConditionCard(
                                        icon: Icons.water_drop,
                                        title: 'Precipitation',
                                        value: '$precipitation mm',
                                      ),
                                      CurrentConditionCard(
                                        icon: Icons.water_drop_outlined,
                                        title: 'Humidity',
                                        value: '$humidity%',
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      CurrentConditionCard(
                                        icon: Icons.air_rounded,
                                        title: 'Wind',
                                        value: '$windSpeed m/s',
                                      ),
                                      CurrentConditionCard(
                                        icon: Icons.speed_rounded,
                                        title: 'Pressure',
                                        value: '${pressure.toStringAsFixed(0)} mb',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                        ),
                      ),
                    ),
                  ),
                ),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 10,
                  color: const Color.fromRGBO(39, 43, 46, 1),
                  margin: const EdgeInsets.all(20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            const Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.fromLTRB(8, 3, 8, 4),
                                  child: Text("Hourly forecast",
                                    style: TextStyle(color: Colors.white,
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                              ],
                            ),
                            // SingleChildScrollView(
                            //   scrollDirection: Axis.horizontal,
                            //   child: Row(
                            //     children: [
                            //       for (int i=0; i<5; i++)
                            //         if (validStartIndex + i < hourlyForecasts.length)
                            //           HourlyForecastCard(
                            //               time: "${DateTime.parse(hourlyForecasts[validStartIndex + i]['time']).toLocal().hour}:00",
                            //               weather: Icons.cloud,
                            //               temp: "${(hourlyForecasts[validStartIndex + i]['values']['temperature'] as num).toStringAsFixed(0)}°"
                            //           ),
                            //     ],
                            //   ),
                            // ),

                            SizedBox(
                              height: 145,
                              child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: 5,
                                  itemBuilder: (context, index){
                                    final hourlyData = hourlyForecasts[validStartIndex + index];
                                    final weatherCode = hourlyData['values']['weatherCode'];

                                    final String hourlySky = weatherCode > 1102 ? 'Clouds' : 'Clear';
                                    final IconData weatherIcon = hourlySky == 'Clouds' ? Icons.cloud : Icons.sunny;

                                    return HourlyForecastCard(
                                        time: "${DateTime.parse(hourlyForecasts[validStartIndex + index]['time']).toLocal().hour}:00",
                                        weather: weatherIcon,
                                        temp: "${(hourlyForecasts[validStartIndex + index]['values']['temperature'] as num).toStringAsFixed(0)}°"
                                    );
                                  }
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      ),
    );
  }
}
