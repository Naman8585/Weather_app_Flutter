// This is the Screen where the searched Location Displayed
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:weather_app/Data/model.dart';
import 'package:http/http.dart' as http;

class SearchResultsScreen extends StatefulWidget {
  final String location;

  const SearchResultsScreen({super.key, required this.location});

  @override
  _SearchResultsScreenState createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  late Future<DefaultLocation> locationFuture;

  @override
  void initState() {
    super.initState();
    locationFuture = getData(widget.location);
  }

  Future<DefaultLocation> getData(String location) async {
    final response = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=$location&appid=3e0d4aff6e162a4461704dfc889e9705&units=metric'));

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return DefaultLocation.fromJson(data);
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather Details'),
      ),
      body: FutureBuilder<DefaultLocation>(
        future: locationFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data available'));
          } else {
            DefaultLocation location = snapshot.data!;
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      location.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 42.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    _buildWeatherCard(location), // Temperature and Climate Widget, Code at Line 82
                    const SizedBox(height: 20.0),
                    _buildInfoRow(location), // Humidity and Wind Speed Widget, Code at line 123
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildWeatherCard(DefaultLocation location) {
    return Card(
      color: Colors.blueAccent,
      elevation: 5.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            location.weather.isNotEmpty
                ? Image.network(
              'http://openweathermap.org/img/wn/${location.weather[0].icon}@2x.png',
              width: 100.0,
            )
                : const Icon(Icons.cloud, size: 80.0, color: Colors.white),
            const SizedBox(height: 10.0),
            Text(
              "${location.main.temp}°C",
              style: const TextStyle(
                fontSize: 30.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10.0),
            Text(
              location.weather.isNotEmpty ? location.weather[0].description : '',
              style: const TextStyle(
                fontSize: 20.0,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(DefaultLocation location) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildInfoCard(
          title: "Humidity",
          value: "${location.main.humidity}%",
        ),
        const SizedBox(width: 20.0),
        _buildInfoCard(
          title: "Wind Speed",
          value: "${location.wind.speed} m/s",
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
  }) {
    return Card(
      color: Colors.blueAccent,
      elevation: 5.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10.0),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18.0,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
