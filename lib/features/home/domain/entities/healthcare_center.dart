import 'package:equatable/equatable.dart';

class HealthcareCenter extends Equatable {
  const HealthcareCenter({
    required this.id,
    required this.name,
    required this.distanceKm,
    required this.specializations,
    this.imageUrl,
    this.latitude,
    this.longitude,
  });

  final String id;
  final String name;
  final double distanceKm;
  final List<String> specializations;
  final String? imageUrl;
  final double? latitude;
  final double? longitude;

  String get formattedDistance => distanceKm < 1
      ? '${(distanceKm * 1000).toInt()} m'
      : '${distanceKm.toStringAsFixed(1)} km';

  @override
  List<Object?> get props =>
      [id, name, distanceKm, specializations, imageUrl, latitude, longitude];
}
