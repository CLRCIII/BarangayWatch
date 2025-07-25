import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather.dart';

class WeatherService {
  // Note: In a real app, you would use your own API key
  // and possibly store it in a secure way
  static const String _apiKey = '332934c4de7c6f44b18f0933a168232f';
  static const String _baseUrl =
      'https://api.openweathermap.org/data/2.5/weather';

  Future<Weather> getWeather(double lat, double lon) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl?lat=$lat&lon=$lon&units=metric&appid=$_apiKey'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        return Weather(
          temperature: (data['main']['temp'] as num).toDouble(),
          condition: data['weather'][0]['main'],
          humidity: data['main']['humidity'],
        );
      } else {
        // For demo purposes, return mock data if API key is not set
        return Weather(temperature: 28.5, condition: 'Cloudy', humidity: 75);
      }
    } catch (e) {
      // Return mock data in case of error
      return Weather(temperature: 28.5, condition: 'Cloudy', humidity: 75);
    }
  }
}
