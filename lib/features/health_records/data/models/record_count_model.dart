import '../../domain/entities/record_count.dart';

class RecordCountModel extends RecordCount {
  const RecordCountModel({
    required super.count,
    required super.canRequestPrediction,
  });

  factory RecordCountModel.fromJson(Map<String, dynamic> json) {
    return RecordCountModel(
      count: json['count'] as int? ?? 0,
      canRequestPrediction: json['canRequestPrediction'] as bool? ?? false,
    );
  }
}
