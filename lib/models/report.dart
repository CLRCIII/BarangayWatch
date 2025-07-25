import 'package:cloud_firestore/cloud_firestore.dart';
import 'weather.dart';

class Report {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String title;
  final String description;
  final String imagePath; // Changed from imageUrl to imagePath
  final double latitude;
  final double longitude;
  final String status;
  final DateTime createdAt;
  final Weather? weather;

  Report({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.title,
    required this.description,
    required this.imagePath, // Changed from imageUrl to imagePath
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.createdAt,
    this.weather,
  });

  // Factory constructor for Firestore data (if you still use Firestore for some data)
  factory Report.fromMap(String id, Map<String, dynamic> map) {
    Weather? weather;
    if (map['weather'] != null) {
      weather = Weather(
        temperature: (map['weather']['temperature'] ?? 0.0).toDouble(),
        condition: map['weather']['condition'] ?? 'Unknown',
        humidity: map['weather']['humidity'] ?? 0,
      );
    }

    return Report(
      id: id,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userEmail: map['userEmail'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      imagePath: map['imagePath'] ?? '', // Changed from imageUrl to imagePath
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      status: map['status'] ?? 'Pending',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      weather: weather,
    );
  }

  // Factory constructor for local storage data
  factory Report.fromLocalMap(String id, Map<String, dynamic> map) {
    Weather? weather;
    if (map['weather'] != null) {
      weather = Weather(
        temperature: (map['weather']['temperature'] ?? 0.0).toDouble(),
        condition: map['weather']['condition'] ?? 'Unknown',
        humidity: map['weather']['humidity'] ?? 0,
      );
    }

    DateTime createdAt;
    if (map['createdAt'] is String) {
      createdAt = DateTime.parse(map['createdAt']);
    } else if (map['createdAt'] is DateTime) {
      createdAt = map['createdAt'];
    } else {
      createdAt = DateTime.now();
    }

    return Report(
      id: id,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userEmail: map['userEmail'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      imagePath: map['imagePath'] ?? '',
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      status: map['status'] ?? 'Pending',
      createdAt: createdAt,
      weather: weather,
    );
  }

  // Convert to Map for JSON serialization (without DateTime object)
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'id': id,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'title': title,
      'description': description,
      'imagePath': imagePath,
      'latitude': latitude,
      'longitude': longitude,
      'status': status,
      // Note: createdAt will be handled separately in the service
    };

    if (weather != null) {
      map['weather'] = {
        'temperature': weather!.temperature,
        'condition': weather!.condition,
        'humidity': weather!.humidity,
      };
    }

    return map;
  }
}
