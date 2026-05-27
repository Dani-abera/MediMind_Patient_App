import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/storage/secure_storage.dart';
import '../../../../core/di/service_locator.dart';
import '../../domain/repositories/video_consultation_repository.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/usecases/get_consultation_usecase.dart';
import '../../domain/usecases/join_consultation_usecase.dart';
import '../../domain/usecases/send_chat_message_usecase.dart';
import '../../services/agora_chat_service.dart';
import 'video_call_event.dart';
import 'video_call_state.dart';

class VideoCallBloc extends Bloc<VideoCallEvent, VideoCallState> {
  VideoCallBloc({
    required this.getConsultation,
    required this.joinConsultation,
    required this.sendChatMessage,
    required this.chatService,
    required this.secureStorage,
  }) : super(const VideoCallInitializing()) {
    on<VideoCallStarted>(_onStarted, transformer: droppable());
    on<VideoCallMicToggled>(_onMicToggled);
    on<VideoCallCameraToggled>(_onCameraToggled);
    on<VideoCallSpeakerToggled>(_onSpeakerToggled);
    on<VideoCallCameraSwitched>(_onCameraSwitched);
    on<VideoCallChatToggled>(_onChatToggled);
    on<VideoCallMessageSent>(_onMessageSent);
    on<VideoCallChatMessageReceived>(_onChatMessageReceived);
    on<VideoCallPeerLeft>(_onPeerLeft);
    on<VideoCallEndRequested>(_onEnded);
    on<VideoCallError>(_onError);
    on<VideoCallBitrateUpdated>(_onBitrateUpdated);
  }

  final GetConsultationUsecase getConsultation;
  final JoinConsultationUsecase joinConsultation;
  final SendChatMessageUsecase sendChatMessage;
  final AgoraChatService chatService;
  final SecureStorage secureStorage;

  RtcEngine? _engine;
  String? _channelId; // Agora channel == roomId from backend
  String? _consultationId; // backend consultationId (GUID) — separate from
  // the Agora channel name; used for REST chat
  // persistence endpoint which expects a GUID.
  String _userType = 'patient';
  int? _remoteUid; // Track separately so a uid arriving before VideoCallActive
  // is emitted isn't dropped by the state-class race check.
  StreamSubscription<ChatMessage>? _chatSub;
  Timer? _pollingTimer;

  RtcEngine? get engine => _engine;
  String? get channelId => _channelId;

  Future<void> _onStarted(
    VideoCallStarted event,
    Emitter<VideoCallState> emit,
  ) async {
    final camStatus = await Permission.camera.request();
    final micStatus = await Permission.microphone.request();
    if (camStatus.isDenied || micStatus.isDenied) {
      emit(const VideoCallPermissionDenied());
      return;
    }

    // Join first to get Agora token + roomId from the backend.
    final joinResult = await joinConsultation(event.consultationId);
    if (joinResult.isLeft()) {
      emit(
        VideoCallErrorState(
          joinResult.fold((f) => f.message, (_) => 'Unknown error'),
        ),
      );
      return;
    }
    final (:token, :roomId, :appId, :userType, :rtmToken, :rtmUserId) =
        joinResult.fold((_) => throw StateError('unreachable'), (r) => r);
    _userType = userType;

    final result = await getConsultation(event.consultationId);
    if (result.isLeft()) {
      emit(
        VideoCallErrorState(
          result.fold((f) => f.message, (_) => 'Unknown error'),
        ),
      );
      return;
    }
    final consultation = result.fold((_) => null, (c) => c)!;
    emit(VideoCallConnecting(consultation));

    // Use appId from backend; fall back to .env if not yet configured.
    final resolvedAppId = appId.isNotEmpty
        ? appId
        : (dotenv.env['AGORA_APP_ID'] ?? '');
    _channelId = roomId;
    _consultationId = event.consultationId;
    _remoteUid = null;

    final tokenPrefix = token.isEmpty ? '(empty)' : token.substring(0, 8);
    debugPrint(
      '[VideoCall] joining channel="$_channelId" appId="${resolvedAppId.isEmpty ? "(empty)" : resolvedAppId.substring(0, 8)}..." token="$tokenPrefix..." userType=$_userType',
    );

    try {
      _engine = createAgoraRtcEngine();
      await _engine!.initialize(RtcEngineContext(appId: resolvedAppId));
      await _engine!.enableVideo();
      await _engine!.enableAudio();

      _engine!.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (connection, elapsed) {
            debugPrint(
              '[VideoCall] joinChannelSuccess channel="${connection.channelId}" localUid=${connection.localUid} elapsedMs=$elapsed',
            );
          },
          onUserJoined: (connection, uid, elapsed) {
            debugPrint(
              '[VideoCall] onUserJoined remoteUid=$uid channel="${connection.channelId}" elapsedMs=$elapsed',
            );
            _remoteUid = uid;
            final current = state;
            if (current is VideoCallActive) {
              emit(current.copyWith(remoteUid: () => uid));
            }
          },
          onUserOffline: (connection, uid, reason) {
            debugPrint('[VideoCall] onUserOffline uid=$uid reason=$reason');
            _remoteUid = null;
            add(const VideoCallPeerLeft());
          },
          onError: (err, msg) {
            debugPrint('[VideoCall] onError code=$err msg="$msg"');
          },
          onConnectionStateChanged: (conn, connState, reason) {
            debugPrint(
              '[VideoCall] connectionState=$connState reason=$reason channel="${conn.channelId}"',
            );
          },
          onTokenPrivilegeWillExpire: (conn, _) {
            debugPrint('[VideoCall] tokenPrivilegeWillExpire');
          },
          onRtcStats: (connection, stats) {
            add(
              VideoCallBitrateUpdated(
                (stats.txKBitRate ?? 0) + (stats.rxKBitRate ?? 0),
              ),
            );
          },
        ),
      );

      await _engine!.startPreview();
      await _engine!.joinChannel(
        token: token,
        channelId: _channelId!,
        uid: 0,
        options: const ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          channelProfile: ChannelProfileType.channelProfileCommunication,
          publishCameraTrack: true,
          publishMicrophoneTrack: true,
          autoSubscribeAudio: true,
          autoSubscribeVideo: true,
        ),
      );

      // RTM token is bound to the userId the backend used when signing it.
      // Fall back to a synthesised id only if the backend hasn't been deployed yet.
      final rtmUid = rtmUserId.isNotEmpty
          ? rtmUserId
          : (await secureStorage.getUserId() ??
                'p_${event.consultationId.substring(0, 8)}');
      await chatService.connect(
        appId: resolvedAppId,
        userId: rtmUid,
        rtmToken: rtmToken,
        consultationId: event.consultationId,
      );
      _chatSub = chatService.onMessage.listen((msg) {
        add(VideoCallChatMessageReceived(msg));
      });

      _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
        final current = state;
        if (current is VideoCallActive && current.isChatOpen) {
          final result = await sl<VideoConsultationRepository>().getChatHistory(event.consultationId);
          result.fold(
            (_) => null,
            (history) {
              if (isClosed) return;
              final existingIds = current.messages.map((m) => m.id).toSet();
              final newMessages = history
                  .map((m) => ChatMessage(
                        id: m['id']?.toString() ?? '',
                        senderName: m['senderName']?.toString() ?? 'Unknown',
                        content: m['content']?.toString() ?? '',
                        sentAt: m['createdAt'] != null
                            ? DateTime.parse(m['createdAt'])
                            : DateTime.now(),
                        isFromPatient: (m['senderType']?.toString() ?? '').toLowerCase() == 'patient',
                      ))
                  .where((m) => !existingIds.contains(m.id))
                  .toList();

              if (newMessages.isNotEmpty) {
                for (final m in newMessages) {
                  add(VideoCallChatMessageReceived(m));
                }
              }
            },
          );
        }
      });

      emit(
        VideoCallActive(
          consultation: consultation,
          messages: const [],
          remoteUid: _remoteUid, // pick up uid if onUserJoined already fired
        ),
      );
    } catch (e) {
      debugPrint('[VideoCall] Error initializing Agora engine: $e');
      emit(VideoCallErrorState('Failed to initialize video call: $e'));
      _cleanup();
    }
  }

  Future<void> _onMicToggled(
    VideoCallMicToggled event,
    Emitter<VideoCallState> emit,
  ) async {
    final current = state;
    if (current is! VideoCallActive) return;
    final muted = !current.isMuted;
    await _engine?.enableLocalAudio(!muted);
    emit(current.copyWith(isMuted: muted));
  }

  Future<void> _onCameraToggled(
    VideoCallCameraToggled event,
    Emitter<VideoCallState> emit,
  ) async {
    final current = state;
    if (current is! VideoCallActive) return;
    final off = !current.isCameraOff;
    await _engine?.enableLocalVideo(!off);
    emit(current.copyWith(isCameraOff: off));
  }

  Future<void> _onSpeakerToggled(
    VideoCallSpeakerToggled event,
    Emitter<VideoCallState> emit,
  ) async {
    final current = state;
    if (current is! VideoCallActive) return;
    final speakerOn = !current.isSpeakerOn;
    await _engine?.setEnableSpeakerphone(speakerOn);
    emit(current.copyWith(isSpeakerOn: speakerOn));
  }

  Future<void> _onCameraSwitched(
    VideoCallCameraSwitched event,
    Emitter<VideoCallState> emit,
  ) async {
    await _engine?.switchCamera();
  }

  void _onChatToggled(
    VideoCallChatToggled event,
    Emitter<VideoCallState> emit,
  ) {
    final current = state;
    if (current is! VideoCallActive) return;
    final open = !current.isChatOpen;
    emit(
      current.copyWith(
        isChatOpen: open,
        unreadCount: open ? 0 : current.unreadCount,
      ),
    );
  }

  Future<void> _onMessageSent(
    VideoCallMessageSent event,
    Emitter<VideoCallState> emit,
  ) async {
    final current = state;
    if (current is! VideoCallActive || _channelId == null) return;

    await chatService.sendMessage(
      content: event.content,
      senderName: 'You',
      senderType: _userType,
    );

    // Persist via REST. The endpoint expects a consultation GUID, NOT the
    // Agora channel name (`room_<hex>`) — using _channelId here causes a 404.
    final consultationIdForRest = _consultationId;
    if (consultationIdForRest != null) {
      sendChatMessage(consultationIdForRest, event.content).ignore();
    }

    final msg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderName: 'You',
      content: event.content,
      sentAt: DateTime.now(),
      isFromPatient: true,
    );
    emit(current.copyWith(messages: [...current.messages, msg]));
  }

  void _onChatMessageReceived(
    VideoCallChatMessageReceived event,
    Emitter<VideoCallState> emit,
  ) {
    final current = state;
    if (current is VideoCallActive) {
      final isOpen = current.isChatOpen;
      emit(
        current.copyWith(
          messages: [...current.messages, event.message],
          unreadCount: isOpen ? 0 : current.unreadCount + 1,
        ),
      );
    }
  }

  void _onPeerLeft(VideoCallPeerLeft event, Emitter<VideoCallState> emit) {
    emit(const VideoCallEnded());
    _cleanup();
  }

  Future<void> _onEnded(
    VideoCallEndRequested event,
    Emitter<VideoCallState> emit,
  ) async {
    emit(const VideoCallEnded());
    _cleanup();
  }

  void _onError(VideoCallError event, Emitter<VideoCallState> emit) {
    emit(VideoCallErrorState(event.message));
  }

  void _onBitrateUpdated(
    VideoCallBitrateUpdated event,
    Emitter<VideoCallState> emit,
  ) {
    final current = state;
    if (current is VideoCallActive) {
      emit(current.copyWith(lowBitrate: event.kbps < 500));
    }
  }

  void _cleanup() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _chatSub?.cancel();
    _chatSub = null;
    if (_channelId != null) {
      chatService.disconnect().ignore();
    }
    _engine?.leaveChannel();
    _engine?.release();
    _engine = null;
    _channelId = null;
    _consultationId = null;
    _remoteUid = null;
  }

  @override
  Future<void> close() async {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _chatSub?.cancel();
    _chatSub = null;
    if (_channelId != null) {
      await chatService.disconnect();
    }
    chatService.dispose();
    _engine?.leaveChannel();
    _engine?.release();
    _engine = null;
    _channelId = null;
    _consultationId = null;
    _remoteUid = null;
    return super.close();
  }
}
