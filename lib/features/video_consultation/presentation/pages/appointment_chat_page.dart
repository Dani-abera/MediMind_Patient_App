import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../domain/entities/chat_message.dart';
import '../../services/video_signalr_service.dart';

class AppointmentChatPage extends StatefulWidget {
  final String consultationId;
  const AppointmentChatPage({super.key, required this.consultationId});

  @override
  State<AppointmentChatPage> createState() => _AppointmentChatPageState();
}

class _AppointmentChatPageState extends State<AppointmentChatPage> {
  late final VideoSignalRService _signalR;
  final List<ChatMessage> _messages = [];
  final TextEditingController _input = TextEditingController();
  final ScrollController _scroll = ScrollController();
  bool _connected = false;

  @override
  void initState() {
    super.initState();
    _signalR = VideoSignalRService(secureStorage: sl<SecureStorage>());
    _signalR.onChatMessage.listen((msg) {
      if (mounted) {
        setState(() => _messages.add(msg));
        _scrollToBottom();
      }
    });
    _connect();
  }

  Future<void> _connect() async {
    await _signalR.connectVideo(widget.consultationId);
    if (mounted) setState(() => _connected = true);
  }

  @override
  void dispose() {
    _signalR.dispose();
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send() async {
    final text = _input.text.trim();
    if (text.isEmpty || !_connected) return;
    _input.clear();
    await _signalR.sendChatMessage(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: Row(
              children: [
                Icon(
                  Icons.circle,
                  size: 10.r,
                  color: _connected ? AppColors.success : AppColors.neutral500,
                ),
                SizedBox(width: 6.w),
                Text(
                  _connected ? 'Connected' : 'Connecting…',
                  style: AppTypography.caption,
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Text(
                      _connected
                          ? 'No messages yet. Say hello!'
                          : 'Connecting to chat…',
                      style: AppTypography.body
                          .copyWith(color: AppColors.neutral500),
                    ),
                  )
                : ListView.builder(
                    controller: _scroll,
                    padding: EdgeInsets.all(16.w),
                    itemCount: _messages.length,
                    itemBuilder: (_, i) =>
                        _MessageBubble(msg: _messages[i]),
                  ),
          ),
          _ChatInput(
            controller: _input,
            enabled: _connected,
            onSend: _send,
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage msg;
  const _MessageBubble({required this.msg});

  @override
  Widget build(BuildContext context) {
    final isPatient = msg.isFromPatient;
    return Align(
      alignment: isPatient ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4.h),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.72),
        decoration: BoxDecoration(
          color: isPatient ? AppColors.primary : AppColors.neutral300,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppRadius.md),
            topRight: Radius.circular(AppRadius.md),
            bottomLeft: Radius.circular(isPatient ? AppRadius.md : 2),
            bottomRight: Radius.circular(isPatient ? 2 : AppRadius.md),
          ),
        ),
        child: Column(
          crossAxisAlignment: isPatient
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              msg.senderName,
              style: AppTypography.caption.copyWith(
                fontWeight: FontWeight.w600,
                color: isPatient
                    ? Colors.white.withAlpha(180)
                    : AppColors.neutral700,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              msg.content,
              style: AppTypography.body.copyWith(
                color: isPatient ? Colors.white : AppColors.neutral900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;
  final VoidCallback onSend;

  const _ChatInput({
    required this.controller,
    required this.enabled,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.neutral300)),
        color: AppColors.white,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: enabled,
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
              style: AppTypography.body,
              decoration: InputDecoration(
                hintText: enabled ? 'Type a message…' : 'Connecting…',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24.r),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.neutral100,
                contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w, vertical: 10.h),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          FilledButton(
            onPressed: enabled ? onSend : null,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: const CircleBorder(),
              padding: EdgeInsets.all(12.r),
            ),
            child: const Icon(Icons.send, color: Colors.white, size: 18),
          ),
        ],
      ),
    );
  }
}
