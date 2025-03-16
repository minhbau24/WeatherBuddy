import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  final String apiKey = "Xuanuio";

  Future<Map<String, dynamic>> fetchWeather(double latitude, double longitude) async {
    final url = "https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=$apiKey&units=metric";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Failed to load weather data");
    }
  }
}
