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
      id: json['centerId'] as String? ?? '',
      name: json['centerName'] as String? ?? '',
      type: _parseType(json['centerType'] as String?),
      address: json['address'] as String? ?? '',
      city: json['city'] as String? ?? '',
      phone: json['phoneNumber'] as String? ?? '',
      rating: 0.0,
      reviewCount: 0,
      distanceKm: distanceKm ??
          (json['distance'] as num?)?.toDouble() ??
          0.0,
      specializations: (json['specializations'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      isOpenNow: json['isOpenNow'] as bool? ?? false,
      isFavorite: false,
      imageUrl: json['logoUrl'] as String?,
      closingTime: null,
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
    final whRaw = json['workingHours'];
    final workingHours = whRaw is Map<String, dynamic>
        ? whRaw.entries.map((e) {
            final val = e.value as String?;
            if (val == null) {
              return WorkingHoursModel(
                  day: e.key, openTime: '', closeTime: '', isOpen: false);
            }
            final parts = val.split('-');
            return WorkingHoursModel(
              day: e.key,
              openTime: parts.isNotEmpty ? parts[0] : '',
              closeTime: parts.length > 1 ? parts[1] : '',
              isOpen: true,
            );
          }).toList()
        : <WorkingHoursModel>[];

    return CenterDetailModel(
      id: json['centerId'] as String? ?? '',
      name: json['centerName'] as String? ?? '',
      type: CenterModel._parseType(json['centerType'] as String?),
      address: json['address'] as String? ?? '',
      city: json['city'] as String? ?? '',
      phone: json['phoneNumber'] as String? ?? '',
      rating: 0.0,
      reviewCount: 0,
      distanceKm: (json['distance'] as num?)?.toDouble() ?? 0.0,
      specializations: (json['specializations'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      isOpenNow: json['isOpenNow'] as bool? ?? false,
      isFavorite: false,
      imageUrl: json['logoUrl'] as String?,
      closingTime: null,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      services: (json['servicesOffered'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      workingHours: workingHours,
      reviews: [],
      website: null,
      email: json['email'] as String?,
      about: null,
    );
  }
}
