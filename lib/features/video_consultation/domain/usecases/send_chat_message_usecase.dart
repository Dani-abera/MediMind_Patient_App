import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/video_consultation_repository.dart';

class SendChatMessageUsecase {
  SendChatMessageUsecase(this._repository);
  final VideoConsultationRepository _repository;

  Future<Either<Failure, void>> call(String consultationId, String content) =>
      _repository.sendMessage(consultationId, content);
}
