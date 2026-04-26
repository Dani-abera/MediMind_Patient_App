import '../../domain/entities/healthcare_center.dart';

class HealthcareCenterModel extends HealthcareCenter {
  const HealthcareCenterModel({
    required super.id,
    required super.name,
    required super.distanceKm,
    required super.specializations,
    super.imageUrl,
    super.latitude,
    super.longitude,
  });

  factory HealthcareCenterModel.fromJson(Map<String, dynamic> json) {
    final specs = (json['specializations'] as List?)
            ?.map((e) => e.toString())
            .toList() ??
        [];
    return HealthcareCenterModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0.0,
      specializations: specs,
      imageUrl: json['imageUrl'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }
}
