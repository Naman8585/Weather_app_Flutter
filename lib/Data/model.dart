// This is the model that is created to fetch data from API
import 'dart:convert';

DefaultLocation defaultLocationFromJson(String str) => DefaultLocation.fromJson(json.decode(str));

String defaultLocationToJson(DefaultLocation data) => json.encode(data.toJson());

class DefaultLocation {
  List<Weather> weather;
  String base;
  Main main;
  Wind wind;
  String name;

  DefaultLocation({
    required this.weather,
    required this.base,
    required this.main,
    required this.wind,
    required this.name,
  });

  factory DefaultLocation.fromJson(Map<String, dynamic> json) => DefaultLocation(
    weather: List<Weather>.from(json["weather"].map((x) => Weather.fromJson(x))),
    base: json["base"],
    main: Main.fromJson(json["main"]),
    wind: Wind.fromJson(json["wind"]),
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "weather": List<dynamic>.from(weather.map((x) => x.toJson())),
    "base": base,
    "main": main.toJson(),
    "wind": wind.toJson(),
    "name": name,
  };
}

class Main {
  double temp;
  double feelsLike;
  double tempMin;
  double tempMax;
  int pressure;
  int humidity;

  Main({
    required this.temp,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.pressure,
    required this.humidity,
  });

  factory Main.fromJson(Map<String, dynamic> json) => Main(
    temp: json["temp"]?.toDouble(),
    feelsLike: json["feels_like"]?.toDouble(),
    tempMin: json["temp_min"]?.toDouble(),
    tempMax: json["temp_max"]?.toDouble(),
    pressure: json["pressure"],
    humidity: json["humidity"],
  );

  Map<String, dynamic> toJson() => {
    "temp": temp,
    "feels_like": feelsLike,
    "temp_min": tempMin,
    "temp_max": tempMax,
    "pressure": pressure,
    "humidity": humidity,
  };
}

class Weather {
  int id;
  String main;
  String description;
  String icon;

  Weather({
    required this.id,
    required this.main,
    required this.description,
    required this.icon,
  });

  factory Weather.fromJson(Map<String, dynamic> json) => Weather(
    id: json["id"],
    main: json["main"],
    description: json["description"],
    icon: json["icon"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "main": main,
    "description": description,
    "icon": icon,
  };
}

class Wind {
  double speed;

  Wind({
    required this.speed,
  });

  factory Wind.fromJson(Map<String, dynamic> json) => Wind(
    speed: json["speed"]?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "speed": speed,
  };
}

