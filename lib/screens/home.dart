import 'dart:convert';
import 'package:weather_app/screens/weather_details.dart';
import 'package:flutter/material.dart';
import 'package:weather_app/Data/model.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<DefaultLocation> defaultLocationFuture;
  final TextEditingController _controller = TextEditingController();
  final String _currentLocation = 'Delhi'; // Default location

  @override
  void initState() {
    super.initState();
    defaultLocationFuture = getData(_currentLocation);
  }

  Future<void> _refreshData() async {
    setState(() {
      defaultLocationFuture = getData(_currentLocation);
    });
  }

  void _searchLocation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchResultsScreen(location: _controller.text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          _buildMainContent(),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue, Colors.lightBlueAccent],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return FutureBuilder<DefaultLocation>(
      future: defaultLocationFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData) {
          return const Center(child: Text('No data available'));
        } else {
          DefaultLocation location = snapshot.data!;
          return RefreshIndicator(
            onRefresh: _refreshData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 30.0),
                    const Text(
                      "Weather App",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 36.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20.0),

                    _buildSearchTextField(), // Search Widget

                    const SizedBox(height: 30.0),
                    Center(
                      child: Column(
                        children: [
                          Text(
                            location.name,
                            style: const TextStyle(
                              fontSize: 42.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 20.0),
                          _buildWeatherCard(location), // Temperature and Climate Widget
                          const SizedBox(height: 20.0),
                          _buildInfoRow(location), // Humidity and Wind Speed Widgets
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }


 // Search Widget
  Widget _buildSearchTextField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: TextField(
        controller: _controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search for a city...',
          hintStyle: const TextStyle(color: Colors.white70),
          suffixIcon: IconButton(
            color: Colors.white,
            onPressed: _searchLocation,
            icon: const Icon(Icons.search),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: const BorderSide(color: Colors.white),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: const BorderSide(color: Colors.white54),
          ),
        ),
      ),
    );
  }


  // Temperature and Climate Widget
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
              location.weather.isNotEmpty
                  ? location.weather[0].description
                  : '',
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

  // Humidity and Wind speed Widgets
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

  // API Service Getdata method
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
}
