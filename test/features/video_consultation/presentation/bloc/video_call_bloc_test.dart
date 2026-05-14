import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medimind/features/video_consultation/domain/entities/chat_message.dart';
import 'package:medimind/features/video_consultation/domain/entities/video_consultation.dart';
import 'package:medimind/features/video_consultation/domain/usecases/get_consultation_usecase.dart';
import 'package:medimind/features/video_consultation/domain/usecases/join_consultation_usecase.dart';
import 'package:medimind/features/video_consultation/presentation/bloc/video_call_bloc.dart';
import 'package:medimind/features/video_consultation/presentation/bloc/video_call_event.dart';
import 'package:medimind/features/video_consultation/presentation/bloc/video_call_state.dart';
import 'package:medimind/features/video_consultation/services/video_signalr_service.dart';
import 'package:mocktail/mocktail.dart';

class MockGetConsultationUsecase extends Mock
    implements GetConsultationUsecase {}

class MockJoinConsultationUsecase extends Mock
    implements JoinConsultationUsecase {}

class MockVideoSignalRService extends Mock implements VideoSignalRService {}

final _consultation = VideoConsultation(
  id: 'c1',
  doctorName: 'Dr. Smith',
  doctorSpecialty: 'Cardiology',
  doctorAvatarUrl: '',
  status: ConsultationStatus.active,
  scheduledAt: DateTime(2025, 6, 1, 10, 0),
);

void main() {
  late MockGetConsultationUsecase mockGetConsultation;
  late MockJoinConsultationUsecase mockJoinConsultation;
  late MockVideoSignalRService mockSignalR;

  final offerStream = StreamController<Map<String, dynamic>>.broadcast();
  final answerStream = StreamController<Map<String, dynamic>>.broadcast();
  final iceStream = StreamController<Map<String, dynamic>>.broadcast();
  final chatStream = StreamController<ChatMessage>.broadcast();
  final peerLeftStream = StreamController<void>.broadcast();

  setUp(() {
    mockGetConsultation = MockGetConsultationUsecase();
    mockJoinConsultation = MockJoinConsultationUsecase();
    mockSignalR = MockVideoSignalRService();

    when(() => mockSignalR.onOffer)
        .thenAnswer((_) => offerStream.stream);
    when(() => mockSignalR.onAnswer)
        .thenAnswer((_) => answerStream.stream);
    when(() => mockSignalR.onIceCandidate)
        .thenAnswer((_) => iceStream.stream);
    when(() => mockSignalR.onChatMessage)
        .thenAnswer((_) => chatStream.stream);
    when(() => mockSignalR.onPeerLeft)
        .thenAnswer((_) => peerLeftStream.stream);
    when(() => mockSignalR.connectVideo(any()))
        .thenAnswer((_) async {});
    when(() => mockSignalR.disconnect())
        .thenAnswer((_) async {});
  });

  VideoCallBloc build() => VideoCallBloc(
        getConsultation: mockGetConsultation,
        joinConsultation: mockJoinConsultation,
        videoSignalR: mockSignalR,
      );

  group('VideoCallMicToggled', () {
    blocTest<VideoCallBloc, VideoCallState>(
      'toggles mic mute',
      build: build,
      seed: () => VideoCallActive(
        consultation: _consultation,
        messages: const [],
      ),
      act: (bloc) => bloc.add(const VideoCallMicToggled()),
      expect: () => [
        isA<VideoCallActive>()
            .having((s) => s.isMuted, 'isMuted', true),
      ],
    );

    blocTest<VideoCallBloc, VideoCallState>(
      'unmutes when already muted',
      build: build,
      seed: () => VideoCallActive(
        consultation: _consultation,
        messages: const [],
        isMuted: true,
      ),
      act: (bloc) => bloc.add(const VideoCallMicToggled()),
      expect: () => [
        isA<VideoCallActive>()
            .having((s) => s.isMuted, 'isMuted', false),
      ],
    );
  });

  group('VideoCallCameraToggled', () {
    blocTest<VideoCallBloc, VideoCallState>(
      'toggles camera off',
      build: build,
      seed: () => VideoCallActive(
        consultation: _consultation,
        messages: const [],
      ),
      act: (bloc) => bloc.add(const VideoCallCameraToggled()),
      expect: () => [
        isA<VideoCallActive>()
            .having((s) => s.isCameraOff, 'isCameraOff', true),
      ],
    );
  });

  group('VideoCallSpeakerToggled', () {
    blocTest<VideoCallBloc, VideoCallState>(
      'toggles speaker off',
      build: build,
      seed: () => VideoCallActive(
        consultation: _consultation,
        messages: const [],
        isSpeakerOn: true,
      ),
      act: (bloc) => bloc.add(const VideoCallSpeakerToggled()),
      expect: () => [
        isA<VideoCallActive>()
            .having((s) => s.isSpeakerOn, 'isSpeakerOn', false),
      ],
    );
  });

  group('VideoCallChatToggled', () {
    blocTest<VideoCallBloc, VideoCallState>(
      'opens chat and clears unread count',
      build: build,
      seed: () => VideoCallActive(
        consultation: _consultation,
        messages: const [],
        unreadCount: 3,
      ),
      act: (bloc) => bloc.add(const VideoCallChatToggled()),
      expect: () => [
        isA<VideoCallActive>()
            .having((s) => s.isChatOpen, 'chatOpen', true)
            .having((s) => s.unreadCount, 'unread', 0),
      ],
    );
  });

  group('VideoCallPeerLeft', () {
    blocTest<VideoCallBloc, VideoCallState>(
      'emits VideoCallEnded when peer leaves',
      build: build,
      seed: () => VideoCallActive(
        consultation: _consultation,
        messages: const [],
      ),
      act: (bloc) => bloc.add(const VideoCallPeerLeft()),
      expect: () => [const VideoCallEnded()],
    );
  });

  group('VideoCallEndRequested', () {
    blocTest<VideoCallBloc, VideoCallState>(
      'emits VideoCallEnded state',
      build: build,
      seed: () => VideoCallActive(
        consultation: _consultation,
        messages: const [],
      ),
      act: (bloc) => bloc.add(const VideoCallEndRequested()),
      expect: () => [const VideoCallEnded()],
    );
  });

  group('VideoCallBitrateUpdated', () {
    blocTest<VideoCallBloc, VideoCallState>(
      'sets lowBitrate true when below 500kbps',
      build: build,
      seed: () => VideoCallActive(
        consultation: _consultation,
        messages: const [],
      ),
      act: (bloc) => bloc.add(const VideoCallBitrateUpdated(300)),
      expect: () => [
        isA<VideoCallActive>()
            .having((s) => s.lowBitrate, 'lowBitrate', true),
      ],
    );

    blocTest<VideoCallBloc, VideoCallState>(
      'clears lowBitrate when above 500kbps',
      build: build,
      seed: () => VideoCallActive(
        consultation: _consultation,
        messages: const [],
        lowBitrate: true,
      ),
      act: (bloc) => bloc.add(const VideoCallBitrateUpdated(800)),
      expect: () => [
        isA<VideoCallActive>()
            .having((s) => s.lowBitrate, 'lowBitrate', false),
      ],
    );
  });

  group('VideoCallError', () {
    blocTest<VideoCallBloc, VideoCallState>(
      'emits VideoCallErrorState',
      build: build,
      act: (bloc) => bloc.add(const VideoCallError('WebRTC failed')),
      expect: () => [
        const VideoCallErrorState('WebRTC failed'),
      ],
    );
  });
}
