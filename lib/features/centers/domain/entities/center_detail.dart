import 'package:equatable/equatable.dart';
import 'center.dart';
import 'working_hours.dart';

class CenterReview extends Equatable {
  const CenterReview({
    required this.id,
    required this.reviewerName,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.reviewerAvatarUrl,
  });

  final String id;
  final String reviewerName;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final String? reviewerAvatarUrl;

  @override
  List<Object?> get props => [id, reviewerName, rating, comment, createdAt];
}

class CenterDetail extends Center {
  const CenterDetail({
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
    required this.services,
    required this.workingHours,
    required this.reviews,
    this.website,
    this.email,
    this.about,
  });

  final List<String> services;
  final List<WorkingHours> workingHours;
  final List<CenterReview> reviews;
  final String? website;
  final String? email;
  final String? about;

  @override
  List<Object?> get props => [
        ...super.props,
        services,
        workingHours.length,
        reviews.length,
      ];
}
