import 'package:equatable/equatable.dart';

abstract class VideoCallEvent extends Equatable {
  const VideoCallEvent();
  @override
  List<Object?> get props => [];
}

class VideoCallStarted extends VideoCallEvent {
  const VideoCallStarted(this.consultationId);
  final String consultationId;
  @override
  List<Object?> get props => [consultationId];
}

class VideoCallMicToggled extends VideoCallEvent {
  const VideoCallMicToggled();
}

class VideoCallCameraToggled extends VideoCallEvent {
  const VideoCallCameraToggled();
}

class VideoCallSpeakerToggled extends VideoCallEvent {
  const VideoCallSpeakerToggled();
}

class VideoCallCameraSwitched extends VideoCallEvent {
  const VideoCallCameraSwitched();
}

class VideoCallChatToggled extends VideoCallEvent {
  const VideoCallChatToggled();
}

class VideoCallMessageSent extends VideoCallEvent {
  const VideoCallMessageSent(this.content);
  final String content;
  @override
  List<Object?> get props => [content];
}

class VideoCallPeerLeft extends VideoCallEvent {
  const VideoCallPeerLeft();
}

class VideoCallEndRequested extends VideoCallEvent {
  const VideoCallEndRequested();
}

class VideoCallError extends VideoCallEvent {
  const VideoCallError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

class VideoCallBitrateUpdated extends VideoCallEvent {
  const VideoCallBitrateUpdated(this.kbps);
  final int kbps;
  @override
  List<Object?> get props => [kbps];
}

class VideoCallPeerJoined extends VideoCallEvent {
  const VideoCallPeerJoined(this.connectionId);
  final String connectionId;
  @override
  List<Object?> get props => [connectionId];
}
