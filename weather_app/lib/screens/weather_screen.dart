import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';
import '../services/weather_service.dart';
import '../services/location_service.dart';
import 'package:lottie/lottie.dart';
import 'package:weather_app/services/weather_service.dart';


class WeatherScreen extends StatefulWidget {
  final double latitude;
  final double longitude;

  const WeatherScreen({Key? key, required this.latitude, required this.longitude}) : super(key: key);

  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  String weatherCondition = ""; 
  Map<String, dynamic>? weatherData;
  String temperature = 'Đang tải...';
  String city = 'Không xác định';
  String description = '';
  int humidity = 0;
  double windSpeed = 0.0;
  String weatherIcon = '';
  List<Map<String, dynamic>> forecast = [];
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    loadWeather();
    fetchWeatherData();
  }

Future<void> fetchWeatherData() async {
  try {
    var data = await WeatherService().fetchWeather(widget.latitude, widget.longitude);
    setState(() {
      weatherData = data;
      weatherCondition = data['weather'][0]['main'];
    });
  } catch (e) {
    print("Error fetching weather data: $e");
  }
}

Future<void> loadWeather() async {
  try {
    var position = await LocationService().getCurrentLocation();
    var data = await WeatherService().fetchWeather(position.latitude, position.longitude); // Kiểm tra cách gọi hàm ở đây

    setState(() {
      weatherData = data;
      // weatherCondition = data['weather'][0]['main'];
      temperature = '${data['main']['temp'].round()}°C';
      city = data['name'];
      description = data['weather'][0]['description'];
      humidity = data['main']['humidity'];
      windSpeed = data['wind']['speed'].toDouble();
      weatherIcon = data['weather'][0]['icon'];
    });
  } catch (e) {
    setState(() {
      temperature = 'Lỗi tải dữ liệu';
      description = '';
    });
  }
}


  String getWeatherAnimation(String weatherCondition) {
  switch (weatherCondition.toLowerCase()) {
    case 'clear sky':
      return 'assets/clear.json';
    case 'few clouds':
    case 'scattered clouds':
    case 'broken clouds':
    case 'overcast clouds':
      return 'assets/cloudy.json';
    case 'shower rain':
    case 'rain':
    case 'moderate rain':
      return 'assets/rainy.json';
    case 'thunderstorm':
      return 'assets/thunderstorm.json';
    case 'snow':
      return 'assets/snow.json';
    default:
      return 'assets/cloudy.json'; // Mặc định nếu không có dữ liệu phù hợp
  }
}

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Dự báo thời tiết'),
          actions: [
            IconButton(
              icon: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode),
              onPressed: () {
                setState(() {
                  isDarkMode = !isDarkMode;
                });
              },
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(city, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              Lottie.asset(getWeatherAnimation(weatherCondition.isNotEmpty ? weatherCondition : "default"), width: 150, height: 150),
              Text(temperature, style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold)),
              Text(description, style: TextStyle(fontSize: 20)),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Icon(Icons.water, color: Colors.blue),
                      Text('$humidity%'),
                      Text('Độ ẩm')
                    ],
                  ),
                  SizedBox(width: 30),
                  Column(
                    children: [
                      Icon(Icons.air, color: Colors.green),
                      Text('$windSpeed m/s'),
                      Text('Gió')
                    ],
                  )
                ],
              ),
              SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: forecast.length,
                  itemBuilder: (context, index) {
                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 5,
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(DateFormat('EEE').format(DateTime.parse(forecast[index]['date'])),
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Image.network('https://openweathermap.org/img/wn/${forecast[index]['icon']}@2x.png', width: 50),
                            Text('${forecast[index]['temp']}°C')
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: loadWeather,
                child: Text('Cập nhật'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
