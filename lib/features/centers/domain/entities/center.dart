import 'package:equatable/equatable.dart';

enum CenterType { hospital, clinic, pharmacy, laboratory, diagnostic }

class Center extends Equatable {
  const Center({
    required this.id,
    required this.name,
    required this.type,
    required this.address,
    required this.city,
    required this.phone,
    required this.rating,
    required this.reviewCount,
    required this.distanceKm,
    required this.specializations,
    required this.isOpenNow,
    required this.isFavorite,
    this.imageUrl,
    this.closingTime,
    this.latitude,
    this.longitude,
  });

  final String id;
  final String name;
  final CenterType type;
  final String address;
  final String city;
  final String phone;
  final double rating;
  final int reviewCount;
  final double distanceKm;
  final List<String> specializations;
  final bool isOpenNow;
  final bool isFavorite;
  final String? imageUrl;
  final String? closingTime;
  final double? latitude;
  final double? longitude;

  String get formattedDistance => distanceKm < 1
      ? '${(distanceKm * 1000).toInt()} m away'
      : '${distanceKm.toStringAsFixed(1)} km away';

  String get openStatus {
    if (!isOpenNow) return 'Closed';
    if (closingTime != null) return 'Open now · Closes $closingTime';
    return 'Open now';
  }

  String get typeLabel => switch (type) {
    CenterType.hospital => 'Hospital',
    CenterType.clinic => 'Clinic',
    CenterType.pharmacy => 'Pharmacy',
    CenterType.laboratory => 'Laboratory',
    CenterType.diagnostic => 'Diagnostic',
  };

  Center copyWith({bool? isFavorite}) => Center(
        id: id,
        name: name,
        type: type,
        address: address,
        city: city,
        phone: phone,
        rating: rating,
        reviewCount: reviewCount,
        distanceKm: distanceKm,
        specializations: specializations,
        isOpenNow: isOpenNow,
        isFavorite: isFavorite ?? this.isFavorite,
        imageUrl: imageUrl,
        closingTime: closingTime,
        latitude: latitude,
        longitude: longitude,
      );

  @override
  List<Object?> get props => [
        id, name, type, address, city, rating, reviewCount,
        distanceKm, specializations, isOpenNow, isFavorite, imageUrl,
      ];
}
