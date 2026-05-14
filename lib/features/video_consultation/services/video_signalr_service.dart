import 'dart:async';
import 'dart:convert';
import '../../../core/services/signalr_service.dart';
import '../domain/entities/chat_message.dart';

class VideoSignalRService extends SignalRService {
  VideoSignalRService({required super.secureStorage})
      : super(hubPath: '/hubs/video');

  String? _consultationId;
  String? _peerConnectionId;

  final _offerController = StreamController<Map<String, dynamic>>.broadcast();
  final _answerController = StreamController<Map<String, dynamic>>.broadcast();
  final _iceCandidateController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _chatController = StreamController<ChatMessage>.broadcast();
  final _peerLeftController = StreamController<void>.broadcast();
  final _userJoinedController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get onOffer => _offerController.stream;
  Stream<Map<String, dynamic>> get onAnswer => _answerController.stream;
  Stream<Map<String, dynamic>> get onIceCandidate =>
      _iceCandidateController.stream;
  Stream<ChatMessage> get onChatMessage => _chatController.stream;
  Stream<void> get onPeerLeft => _peerLeftController.stream;
  Stream<Map<String, dynamic>> get onUserJoined => _userJoinedController.stream;

  void setPeerConnectionId(String connectionId) {
    _peerConnectionId = connectionId;
  }

  Future<void> connectVideo(String consultationId) async {
    _consultationId = consultationId;
    _registerHandlers();
    await connect();
    // Join the SignalR group for this consultation room
    await send('JoinConsultationRoom', args: [consultationId]);
  }

  void _registerHandlers() {
    on('ReceiveOffer', (args) {
      if (args == null || args.isEmpty) return;
      // args: [senderConnectionId, sdpOffer]
      if (args.length >= 2) {
        final senderConnectionId = args[0] as String? ?? '';
        _peerConnectionId ??= senderConnectionId;
        final sdp = args[1];
        final sdpMap = sdp is Map<String, dynamic>
            ? sdp
            : <String, dynamic>{'raw': sdp.toString()};
        _offerController.add(sdpMap);
      }
    });

    on('ReceiveAnswer', (args) {
      if (args == null || args.isEmpty) return;
      if (args.length >= 2) {
        final sdp = args[1];
        final sdpMap = sdp is Map<String, dynamic>
            ? sdp
            : <String, dynamic>{'raw': sdp.toString()};
        _answerController.add(sdpMap);
      }
    });

    on('ReceiveIceCandidate', (args) {
      if (args == null || args.isEmpty) return;
      if (args.length >= 2) {
        final raw = args[1];
        Map<String, dynamic> candidateMap;
        if (raw is Map<String, dynamic>) {
          candidateMap = raw;
        } else if (raw is String) {
          candidateMap =
              jsonDecode(raw) as Map<String, dynamic>? ?? {};
        } else {
          return;
        }
        _iceCandidateController.add(candidateMap);
      }
    });

    on('ReceiveChatMessage', (args) {
      if (args == null || args.isEmpty) return;
      final data = args[0] as Map<String, dynamic>? ?? {};
      _chatController.add(ChatMessage(
        id: data['messageId'] as String? ?? '',
        senderName: data['senderName'] as String? ?? '',
        content: data['content'] as String? ?? '',
        sentAt: data['sentAt'] != null
            ? DateTime.parse(data['sentAt'] as String)
            : DateTime.now(),
        isFromPatient: (data['senderType'] as String?)?.toLowerCase() == 'patient',
      ));
    });

    on('UserJoined', (args) {
      if (args == null || args.isEmpty) return;
      final data = args[0] as Map<String, dynamic>? ?? {};
      final connectionId = data['connectionId'] as String? ?? '';
      if (connectionId.isNotEmpty) {
        _peerConnectionId = connectionId;
      }
      _userJoinedController.add(data);
    });

    on('UserLeft', (_) => _peerLeftController.add(null));

    on('ConsultationEnded', (_) => _peerLeftController.add(null));
  }

  Future<void> sendOffer(Map<String, dynamic> sdp) async {
    await send('SendOffer',
        args: [_consultationId ?? '', _peerConnectionId ?? '', jsonEncode(sdp)]);
  }

  Future<void> sendAnswer(Map<String, dynamic> sdp) async {
    await send('SendAnswer',
        args: [_consultationId ?? '', _peerConnectionId ?? '', jsonEncode(sdp)]);
  }

  Future<void> sendIceCandidate(Map<String, dynamic> candidate) async {
    await send('SendIceCandidate',
        args: [_consultationId ?? '', _peerConnectionId ?? '', jsonEncode(candidate)]);
  }

  Future<void> sendChatMessage(String content) async {
    await send('SendChatMessage',
        args: [_consultationId ?? '', content]);
  }

  @override
  void onReconnected() {
    if (_consultationId != null) {
      send('RejoinConsultation', args: [_consultationId!]);
    }
  }

  @override
  void dispose() {
    _offerController.close();
    _answerController.close();
    _iceCandidateController.close();
    _chatController.close();
    _peerLeftController.close();
    _userJoinedController.close();
    super.dispose();
  }
}
