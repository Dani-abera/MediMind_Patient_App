import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/usecases/get_consultation_usecase.dart';
import '../../domain/usecases/join_consultation_usecase.dart';
import '../../services/video_signalr_service.dart';
import 'video_call_event.dart';
import 'video_call_state.dart';

class VideoCallBloc extends Bloc<VideoCallEvent, VideoCallState> {
  VideoCallBloc({
    required this.getConsultation,
    required this.joinConsultation,
    required this.videoSignalR,
  }) : super(const VideoCallInitializing()) {
    on<VideoCallStarted>(_onStarted);
    on<VideoCallMicToggled>(_onMicToggled);
    on<VideoCallCameraToggled>(_onCameraToggled);
    on<VideoCallSpeakerToggled>(_onSpeakerToggled);
    on<VideoCallCameraSwitched>(_onCameraSwitched);
    on<VideoCallChatToggled>(_onChatToggled);
    on<VideoCallMessageSent>(_onMessageSent);
    on<VideoCallPeerLeft>(_onPeerLeft);
    on<VideoCallEndRequested>(_onEnded);
    on<VideoCallError>(_onError);
    on<VideoCallBitrateUpdated>(_onBitrateUpdated);
    on<VideoCallPeerJoined>(_onPeerJoined);
  }

  final GetConsultationUsecase getConsultation;
  final JoinConsultationUsecase joinConsultation;
  final VideoSignalRService videoSignalR;

  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  RTCVideoRenderer? _localRenderer;
  RTCVideoRenderer? _remoteRenderer;

  StreamSubscription<dynamic>? _offerSub;
  StreamSubscription<dynamic>? _answerSub;
  StreamSubscription<dynamic>? _iceSub;
  StreamSubscription<dynamic>? _chatSub;
  StreamSubscription<dynamic>? _peerLeftSub;
  StreamSubscription<dynamic>? _userJoinedSub;

  bool _offerSent = false;

  RTCVideoRenderer? get localRenderer => _localRenderer;
  RTCVideoRenderer? get remoteRenderer => _remoteRenderer;

  Future<void> _onStarted(
      VideoCallStarted event, Emitter<VideoCallState> emit) async {
    // Check permissions
    final camStatus = await Permission.camera.request();
    final micStatus = await Permission.microphone.request();
    if (camStatus.isDenied || micStatus.isDenied) {
      emit(const VideoCallPermissionDenied());
      return;
    }

    // Fetch consultation metadata
    final result = await getConsultation(event.consultationId);
    if (result.isLeft()) {
      emit(VideoCallErrorState(
          result.fold((f) => f.message, (_) => 'Unknown error')));
      return;
    }
    final consultation = result.fold((f) => null, (c) => c)!;
    emit(VideoCallConnecting(consultation));

    // Init renderers
    _localRenderer = RTCVideoRenderer();
    _remoteRenderer = RTCVideoRenderer();
    await _localRenderer!.initialize();
    await _remoteRenderer!.initialize();

    // Get local stream
    _localStream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': {'facingMode': 'user'},
    });
    _localRenderer!.srcObject = _localStream;

    // Create peer connection
    _peerConnection = await createPeerConnection({
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
      ],
    });

    _localStream!.getTracks().forEach((track) {
      _peerConnection!.addTrack(track, _localStream!);
    });

    _peerConnection!.onIceCandidate = (candidate) {
      if (candidate.candidate != null) {
        videoSignalR.sendIceCandidate(candidate.toMap());
      }
    };

    _peerConnection!.onTrack = (event) {
      if (event.streams.isNotEmpty) {
        _remoteRenderer!.srcObject = event.streams[0];
      }
    };

    // Register SignalR offer/answer/ICE handlers before connecting
    _offerSub = videoSignalR.onOffer.listen((sdp) async {
      await _peerConnection!
          .setRemoteDescription(RTCSessionDescription(sdp['sdp'], sdp['type']));
      final answer = await _peerConnection!.createAnswer();
      await _peerConnection!.setLocalDescription(answer);
      await videoSignalR.sendAnswer({'sdp': answer.sdp, 'type': answer.type});
    });

    _answerSub = videoSignalR.onAnswer.listen((sdp) async {
      await _peerConnection!
          .setRemoteDescription(RTCSessionDescription(sdp['sdp'], sdp['type']));
    });

    _iceSub = videoSignalR.onIceCandidate.listen((c) async {
      await _peerConnection!.addCandidate(RTCIceCandidate(
          c['candidate'], c['sdpMid'], c['sdpMLineIndex']));
    });

    _peerLeftSub = videoSignalR.onPeerLeft.listen((_) {
      add(const VideoCallPeerLeft());
    });

    // Connect to SignalR and join the room
    await videoSignalR.connectVideo(event.consultationId);

    // Call the REST join endpoint to register participation and get peer list
    final joinResult = await joinConsultation(event.consultationId);
    joinResult.fold(
      (failure) {
        // Non-fatal: SignalR join still works; log but continue
      },
      (myConnectionId) {
        // myConnectionId is our own SignalR connectionId (not peer's)
      },
    );

    // Listen for a peer joining and send the offer to them
    _userJoinedSub = videoSignalR.onUserJoined.listen((data) async {
      if (!_offerSent) {
        _offerSent = true;
        final offer = await _peerConnection!.createOffer();
        await _peerConnection!.setLocalDescription(offer);
        await videoSignalR.sendOffer({'sdp': offer.sdp, 'type': offer.type});
      }
    });

    emit(VideoCallActive(
      consultation: consultation,
      messages: const [],
    ));

    // Listen for incoming chat messages
    _chatSub = videoSignalR.onChatMessage.listen((msg) {
      final current = state;
      if (current is VideoCallActive) {
        final isOpen = current.isChatOpen;
        emit(current.copyWith(
          messages: [...current.messages, msg],
          unreadCount: isOpen ? 0 : current.unreadCount + 1,
        ));
      }
    });
  }

  Future<void> _onPeerJoined(
      VideoCallPeerJoined event, Emitter<VideoCallState> emit) async {
    // Peer joined — if we haven't sent an offer yet, send one now
    if (!_offerSent && _peerConnection != null) {
      _offerSent = true;
      final offer = await _peerConnection!.createOffer();
      await _peerConnection!.setLocalDescription(offer);
      await videoSignalR.sendOffer({'sdp': offer.sdp, 'type': offer.type});
    }
  }

  void _onMicToggled(
      VideoCallMicToggled event, Emitter<VideoCallState> emit) {
    final current = state;
    if (current is! VideoCallActive) return;
    final muted = !current.isMuted;
    _localStream?.getAudioTracks().forEach((t) => t.enabled = !muted);
    emit(current.copyWith(isMuted: muted));
  }

  void _onCameraToggled(
      VideoCallCameraToggled event, Emitter<VideoCallState> emit) {
    final current = state;
    if (current is! VideoCallActive) return;
    final off = !current.isCameraOff;
    _localStream?.getVideoTracks().forEach((t) => t.enabled = !off);
    emit(current.copyWith(isCameraOff: off));
  }

  void _onSpeakerToggled(
      VideoCallSpeakerToggled event, Emitter<VideoCallState> emit) {
    final current = state;
    if (current is! VideoCallActive) return;
    emit(current.copyWith(isSpeakerOn: !current.isSpeakerOn));
  }

  Future<void> _onCameraSwitched(
      VideoCallCameraSwitched event, Emitter<VideoCallState> emit) async {
    final videoTrack = _localStream?.getVideoTracks().firstOrNull;
    if (videoTrack != null) {
      await Helper.switchCamera(videoTrack);
    }
  }

  void _onChatToggled(
      VideoCallChatToggled event, Emitter<VideoCallState> emit) {
    final current = state;
    if (current is! VideoCallActive) return;
    final open = !current.isChatOpen;
    emit(current.copyWith(isChatOpen: open, unreadCount: open ? 0 : current.unreadCount));
  }

  Future<void> _onMessageSent(
      VideoCallMessageSent event, Emitter<VideoCallState> emit) async {
    final current = state;
    if (current is! VideoCallActive) return;
    await videoSignalR.sendChatMessage(event.content);
    final msg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderName: 'You',
      content: event.content,
      sentAt: DateTime.now(),
      isFromPatient: true,
    );
    emit(current.copyWith(messages: [...current.messages, msg]));
  }

  void _onPeerLeft(VideoCallPeerLeft event, Emitter<VideoCallState> emit) {
    emit(const VideoCallEnded());
    _cleanup();
  }

  Future<void> _onEnded(
      VideoCallEndRequested event, Emitter<VideoCallState> emit) async {
    emit(const VideoCallEnded());
    _cleanup();
  }

  void _onError(VideoCallError event, Emitter<VideoCallState> emit) {
    emit(VideoCallErrorState(event.message));
  }

  void _onBitrateUpdated(
      VideoCallBitrateUpdated event, Emitter<VideoCallState> emit) {
    final current = state;
    if (current is VideoCallActive) {
      emit(current.copyWith(lowBitrate: event.kbps < 500));
    }
  }

  void _cleanup() {
    _offerSub?.cancel();
    _answerSub?.cancel();
    _iceSub?.cancel();
    _chatSub?.cancel();
    _peerLeftSub?.cancel();
    _userJoinedSub?.cancel();
    _localStream?.dispose();
    _peerConnection?.close();
    _localRenderer?.dispose();
    _remoteRenderer?.dispose();
    videoSignalR.disconnect();
  }

  @override
  Future<void> close() {
    _cleanup();
    return super.close();
  }
}
