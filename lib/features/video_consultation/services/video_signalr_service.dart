import 'dart:async';
import '../../../core/services/signalr_service.dart';
import '../domain/entities/chat_message.dart';

class VideoSignalRService extends SignalRService {
  VideoSignalRService({required super.secureStorage})
      : super(hubPath: '/hubs/video');

  String? _consultationId;

  final _offerController = StreamController<Map<String, dynamic>>.broadcast();
  final _answerController = StreamController<Map<String, dynamic>>.broadcast();
  final _iceCandidateController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _chatController = StreamController<ChatMessage>.broadcast();
  final _peerLeftController = StreamController<void>.broadcast();

  Stream<Map<String, dynamic>> get onOffer => _offerController.stream;
  Stream<Map<String, dynamic>> get onAnswer => _answerController.stream;
  Stream<Map<String, dynamic>> get onIceCandidate =>
      _iceCandidateController.stream;
  Stream<ChatMessage> get onChatMessage => _chatController.stream;
  Stream<void> get onPeerLeft => _peerLeftController.stream;

  Future<void> connectVideo(String consultationId) async {
    _consultationId = consultationId;
    _registerHandlers();
    await connect();
  }

  void _registerHandlers() {
    on('ReceiveOffer', (args) {
      if (args == null || args.isEmpty) return;
      _offerController
          .add(args[0] as Map<String, dynamic>? ?? {});
    });

    on('ReceiveAnswer', (args) {
      if (args == null || args.isEmpty) return;
      _answerController
          .add(args[0] as Map<String, dynamic>? ?? {});
    });

    on('ReceiveIceCandidate', (args) {
      if (args == null || args.isEmpty) return;
      _iceCandidateController
          .add(args[0] as Map<String, dynamic>? ?? {});
    });

    on('ReceiveMessage', (args) {
      if (args == null || args.isEmpty) return;
      final data = args[0] as Map<String, dynamic>? ?? {};
      _chatController.add(ChatMessage(
        id: data['id'] as String? ?? '',
        senderName: data['senderName'] as String? ?? '',
        content: data['content'] as String? ?? '',
        sentAt: data['sentAt'] != null
            ? DateTime.parse(data['sentAt'] as String)
            : DateTime.now(),
        isFromPatient: data['isFromPatient'] as bool? ?? false,
      ));
    });

    on('PeerLeft', (_) => _peerLeftController.add(null));
  }

  Future<void> sendOffer(Map<String, dynamic> sdp) async {
    await send('SendOffer',
        args: [_consultationId ?? '', sdp]);
  }

  Future<void> sendAnswer(Map<String, dynamic> sdp) async {
    await send('SendAnswer',
        args: [_consultationId ?? '', sdp]);
  }

  Future<void> sendIceCandidate(Map<String, dynamic> candidate) async {
    await send('SendIceCandidate',
        args: [_consultationId ?? '', candidate]);
  }

  Future<void> sendChatMessage(String content) async {
    await send('SendMessage',
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
    super.dispose();
  }
}
