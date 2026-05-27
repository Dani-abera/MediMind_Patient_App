import 'dart:async';
import 'dart:convert';
import 'package:agora_rtm/agora_rtm.dart';
import 'package:flutter/foundation.dart';
import '../domain/entities/chat_message.dart';

class AgoraChatService {
  RtmClient? _client;
  String? _channelName;
  String? _userId;
  final _messageController = StreamController<ChatMessage>.broadcast();

  Stream<ChatMessage> get onMessage => _messageController.stream;

  Future<void> connect({
    required String appId,
    required String userId,
    required String rtmToken,
    required String consultationId,
  }) async {
    _channelName = 'consultation_$consultationId';
    _userId = userId;
    final tokenPrefix = rtmToken.isEmpty ? '(empty)' : '${rtmToken.substring(0, 8)}...';
    debugPrint(
        '[Chat] connecting RTM appId="${appId.isEmpty ? "(empty)" : "${appId.substring(0, 8)}..."}" userId="$userId" token="$tokenPrefix" channel="$_channelName"');

    try {
      final (initStatus, client) = await RTM(appId, userId);
      debugPrint(
          '[Chat] RTM init → errorCode=${initStatus.errorCode} reason=${initStatus.reason}');
      _client = client;

      _client!.addListener(
        message: (MessageEvent event) {
          debugPrint(
              '[Chat] inbound message channel="${event.channelName}" from="${event.publisher}"');
          if (event.channelName != _channelName) return;
          if (event.publisher == _userId) {
            debugPrint('[Chat] filtering out self-published message echo');
            return;
          }
          try {
            final raw = event.message;
            final text = raw != null ? utf8.decode(raw) : '';
            final decoded = jsonDecode(text) as Map<String, dynamic>;
            _messageController.add(ChatMessage(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              senderName: decoded['senderName'] as String? ?? 'Doctor',
              content: decoded['content'] as String? ?? '',
              sentAt: DateTime.now(),
              isFromPatient:
                  (decoded['senderType'] as String?)?.toLowerCase() ==
                      'patient',
            ));
          } catch (e) {
            debugPrint('[Chat] failed to decode inbound message: $e');
          }
        },
      );

      try {
        final (loginStatus, _) = await _client!.login(rtmToken);
        debugPrint(
            '[Chat] RTM login → error=${loginStatus.error} errorCode=${loginStatus.errorCode} reason=${loginStatus.reason}');
        if (loginStatus.error) {
          // login rejected — skip subscribe so we don't get a noisy
          // "RTM service is not connected" error too.
          _client = null;
          return;
        }
      } catch (e) {
        debugPrint('[Chat] RTM login threw: $e — chat disabled for this call.');
        _client = null;
        return;
      }

      try {
        final (subStatus, _) = await _client!
            .subscribe(_channelName!, withMessage: true, withPresence: false);
        debugPrint(
            '[Chat] RTM subscribe("$_channelName") → errorCode=${subStatus.errorCode} reason=${subStatus.reason}');
      } catch (e) {
        debugPrint('[Chat] RTM subscribe threw: $e');
      }
    } catch (e) {
      debugPrint('[Chat] RTM init failed: $e — chat disabled for this call.');
      _client = null;
    }
  }

  Future<void> sendMessage({
    required String content,
    required String senderName,
    required String senderType,
  }) async {
    if (_client == null || _channelName == null) {
      debugPrint(
          '[Chat] sendMessage skipped — RTM client not connected (channel=$_channelName)');
      return;
    }
    try {
      final (status, _) = await _client!.publish(
        _channelName!,
        jsonEncode({
          'content': content,
          'senderName': senderName,
          'senderType': senderType,
        }),
      );
      debugPrint(
          '[Chat] publish → errorCode=${status.errorCode} reason=${status.reason}');
    } catch (e) {
      debugPrint('[Chat] publish threw: $e');
    }
  }

  Future<void> disconnect() async {
    final channel = _channelName;
    _channelName = null;
    if (channel != null) {
      await _client?.unsubscribe(channel);
    }
    await _client?.logout();
    await _client?.release();
    _client = null;
  }

  void dispose() {
    _messageController.close();
  }
}
