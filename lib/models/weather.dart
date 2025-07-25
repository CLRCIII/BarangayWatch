class Weather {
  final double temperature;
  final String condition;
  final int humidity;

  Weather({
    required this.temperature,
    required this.condition,
    this.humidity = 0,
  });
}
