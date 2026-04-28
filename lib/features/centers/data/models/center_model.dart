import '../../domain/entities/center.dart';
import '../../domain/entities/center_detail.dart';
import '../../domain/entities/working_hours.dart';

class CenterModel extends Center {
  const CenterModel({
    required super.id,
    required super.name,
    required super.type,
    required super.address,
    required super.city,
    required super.phone,
    required super.rating,
    required super.reviewCount,
    required super.distanceKm,
    required super.specializations,
    required super.isOpenNow,
    required super.isFavorite,
    super.imageUrl,
    super.closingTime,
    super.latitude,
    super.longitude,
  });

  factory CenterModel.fromJson(Map<String, dynamic> json,
      {double? distanceKm}) {
    return CenterModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: _parseType(json['type'] as String?),
      address: json['address'] as String? ?? '',
      city: json['city'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      distanceKm: distanceKm ??
          (json['distanceKm'] as num?)?.toDouble() ??
          0.0,
      specializations: (json['specializations'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      isOpenNow: json['isOpenNow'] as bool? ?? false,
      isFavorite: json['isFavorite'] as bool? ?? false,
      imageUrl: json['imageUrl'] as String?,
      closingTime: json['closingTime'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  static CenterType _parseType(String? type) => switch (type?.toLowerCase()) {
        'hospital' => CenterType.hospital,
        'clinic' => CenterType.clinic,
        'pharmacy' => CenterType.pharmacy,
        'laboratory' => CenterType.laboratory,
        'diagnostic' => CenterType.diagnostic,
        _ => CenterType.clinic,
      };
}

class WorkingHoursModel extends WorkingHours {
  const WorkingHoursModel({
    required super.day,
    required super.openTime,
    required super.closeTime,
    required super.isOpen,
  });

  factory WorkingHoursModel.fromJson(Map<String, dynamic> json) =>
      WorkingHoursModel(
        day: json['day'] as String,
        openTime: json['openTime'] as String? ?? '',
        closeTime: json['closeTime'] as String? ?? '',
        isOpen: json['isOpen'] as bool? ?? true,
      );
}

class CenterReviewModel extends CenterReview {
  const CenterReviewModel({
    required super.id,
    required super.reviewerName,
    required super.rating,
    required super.comment,
    required super.createdAt,
    super.reviewerAvatarUrl,
  });

  factory CenterReviewModel.fromJson(Map<String, dynamic> json) =>
      CenterReviewModel(
        id: json['id'] as String,
        reviewerName: json['reviewerName'] as String? ?? 'Anonymous',
        rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
        comment: json['comment'] as String? ?? '',
        createdAt: DateTime.parse(json['createdAt'] as String),
        reviewerAvatarUrl: json['reviewerAvatarUrl'] as String?,
      );
}

class CenterDetailModel extends CenterDetail {
  const CenterDetailModel({
    required super.id,
    required super.name,
    required super.type,
    required super.address,
    required super.city,
    required super.phone,
    required super.rating,
    required super.reviewCount,
    required super.distanceKm,
    required super.specializations,
    required super.isOpenNow,
    required super.isFavorite,
    super.imageUrl,
    super.closingTime,
    super.latitude,
    super.longitude,
    required super.services,
    required super.workingHours,
    required super.reviews,
    super.website,
    super.email,
    super.about,
  });

  factory CenterDetailModel.fromJson(Map<String, dynamic> json) {
    return CenterDetailModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: CenterModel._parseType(json['type'] as String?),
      address: json['address'] as String? ?? '',
      city: json['city'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0.0,
      specializations: (json['specializations'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      isOpenNow: json['isOpenNow'] as bool? ?? false,
      isFavorite: json['isFavorite'] as bool? ?? false,
      imageUrl: json['imageUrl'] as String?,
      closingTime: json['closingTime'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      services: (json['services'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      workingHours: (json['workingHours'] as List<dynamic>?)
              ?.map((e) =>
                  WorkingHoursModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      reviews: (json['reviews'] as List<dynamic>?)
              ?.map((e) =>
                  CenterReviewModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      website: json['website'] as String?,
      email: json['email'] as String?,
      about: json['about'] as String?,
    );
  }
}
