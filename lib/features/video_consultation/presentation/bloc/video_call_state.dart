import 'package:equatable/equatable.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/video_consultation.dart';

abstract class VideoCallState extends Equatable {
  const VideoCallState();
  @override
  List<Object?> get props => [];
}

class VideoCallInitializing extends VideoCallState {
  const VideoCallInitializing();
}

class VideoCallPermissionDenied extends VideoCallState {
  const VideoCallPermissionDenied();
}

class VideoCallConnecting extends VideoCallState {
  const VideoCallConnecting(this.consultation);
  final VideoConsultation consultation;
  @override
  List<Object?> get props => [consultation];
}

class VideoCallActive extends VideoCallState {
  const VideoCallActive({
    required this.consultation,
    required this.messages,
    this.isMuted = false,
    this.isCameraOff = false,
    this.isSpeakerOn = true,
    this.isChatOpen = false,
    this.unreadCount = 0,
    this.lowBitrate = false,
  });

  final VideoConsultation consultation;
  final List<ChatMessage> messages;
  final bool isMuted;
  final bool isCameraOff;
  final bool isSpeakerOn;
  final bool isChatOpen;
  final int unreadCount;
  final bool lowBitrate;

  VideoCallActive copyWith({
    VideoConsultation? consultation,
    List<ChatMessage>? messages,
    bool? isMuted,
    bool? isCameraOff,
    bool? isSpeakerOn,
    bool? isChatOpen,
    int? unreadCount,
    bool? lowBitrate,
  }) =>
      VideoCallActive(
        consultation: consultation ?? this.consultation,
        messages: messages ?? this.messages,
        isMuted: isMuted ?? this.isMuted,
        isCameraOff: isCameraOff ?? this.isCameraOff,
        isSpeakerOn: isSpeakerOn ?? this.isSpeakerOn,
        isChatOpen: isChatOpen ?? this.isChatOpen,
        unreadCount: unreadCount ?? this.unreadCount,
        lowBitrate: lowBitrate ?? this.lowBitrate,
      );

  @override
  List<Object?> get props => [
        consultation,
        messages,
        isMuted,
        isCameraOff,
        isSpeakerOn,
        isChatOpen,
        unreadCount,
        lowBitrate,
      ];
}

class VideoCallEnded extends VideoCallState {
  const VideoCallEnded();
}

class VideoCallErrorState extends VideoCallState {
  const VideoCallErrorState(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
