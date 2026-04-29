import '../../domain/entities/favorite.dart';

class FavoriteDoctorModel extends FavoriteDoctor {
  const FavoriteDoctorModel({
    required super.doctorId,
    required super.fullName,
    required super.specialty,
    required super.rating,
    super.avatarUrl,
    super.centerId,
    super.centerName,
  });

  factory FavoriteDoctorModel.fromJson(Map<String, dynamic> json) {
    final doctor = json['doctor'] as Map<String, dynamic>? ?? json;
    return FavoriteDoctorModel(
      doctorId: doctor['id'] as String? ?? doctor['_id'] as String? ?? '',
      fullName: doctor['fullName'] as String? ?? '',
      specialty: doctor['specialty'] as String? ?? '',
      rating: (doctor['rating'] as num?)?.toDouble() ?? 0.0,
      avatarUrl: doctor['avatarUrl'] as String?,
      centerId: doctor['centerId'] as String?,
      centerName: doctor['centerName'] as String?,
    );
  }
}

class FavoriteCenterModel extends FavoriteCenter {
  const FavoriteCenterModel({
    required super.centerId,
    required super.name,
    required super.type,
    required super.rating,
    super.imageUrl,
    super.address,
  });

  factory FavoriteCenterModel.fromJson(Map<String, dynamic> json) {
    final center = json['center'] as Map<String, dynamic>? ?? json;
    return FavoriteCenterModel(
      centerId: center['id'] as String? ?? center['_id'] as String? ?? '',
      name: center['name'] as String? ?? '',
      type: center['type'] as String? ?? '',
      rating: (center['rating'] as num?)?.toDouble() ?? 0.0,
      imageUrl: center['imageUrl'] as String?,
      address: center['address'] as String?,
    );
  }
}
