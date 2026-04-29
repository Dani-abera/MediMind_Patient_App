import 'package:equatable/equatable.dart';

class FavoriteDoctor extends Equatable {
  const FavoriteDoctor({
    required this.doctorId,
    required this.fullName,
    required this.specialty,
    required this.rating,
    this.avatarUrl,
    this.centerId,
    this.centerName,
  });

  final String doctorId;
  final String fullName;
  final String specialty;
  final double rating;
  final String? avatarUrl;
  final String? centerId;
  final String? centerName;

  @override
  List<Object?> get props =>
      [doctorId, fullName, specialty, rating, avatarUrl, centerId, centerName];
}

class FavoriteCenter extends Equatable {
  const FavoriteCenter({
    required this.centerId,
    required this.name,
    required this.type,
    required this.rating,
    this.imageUrl,
    this.address,
  });

  final String centerId;
  final String name;
  final String type;
  final double rating;
  final String? imageUrl;
  final String? address;

  @override
  List<Object?> get props =>
      [centerId, name, type, rating, imageUrl, address];
}
