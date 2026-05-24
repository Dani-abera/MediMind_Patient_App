import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../bloc/video_call_bloc.dart';
import '../bloc/video_call_event.dart';
import '../bloc/video_call_state.dart';

class VideoCallPage extends StatefulWidget {
  const VideoCallPage({super.key, required this.consultationId});
  final String consultationId;

  @override
  State<VideoCallPage> createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage> {
  bool _controlsVisible = false;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    context.read<VideoCallBloc>().add(VideoCallStarted(widget.consultationId));
  }

  void _scheduleControlsHide() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) setState(() => _controlsVisible = false);
    });
  }

  void _showControls() {
    setState(() => _controlsVisible = true);
    _scheduleControlsHide();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  Future<bool> _onWillPop(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('End Call?'),
        content: const Text('Are you sure you want to leave the consultation?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Stay')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('End', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VideoCallBloc, VideoCallState>(
      listener: (context, state) {
        if (state is VideoCallActive) {
          _showControls();
        }
        if (state is VideoCallEnded) {
          context.pop();
        }
      },
      builder: (context, state) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop) return;
            final leave = await _onWillPop(context);
            if (leave && context.mounted) {
              context.read<VideoCallBloc>().add(const VideoCallEndRequested());
            }
          },
          child: switch (state) {
            VideoCallInitializing() => _loadingScaffold('Initializing…'),
            VideoCallConnecting() =>
              _loadingScaffold('Connecting to doctor…'),
            VideoCallPermissionDenied() => _permissionDeniedScaffold(),
            VideoCallActive() =>
              _activeCallScaffold(context, state),
            VideoCallEnded() => _loadingScaffold('Call ended'),
            VideoCallErrorState(:final message) =>
              _errorScaffold(message),
            _ => _loadingScaffold('Please wait…'),
          },
        );
      },
    );
  }

  Widget _loadingScaffold(String msg) => Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16.h),
            Text(msg,
                style: AppTypography.body.copyWith(color: Colors.white)),
          ]),
        ),
      );

  Widget _permissionDeniedScaffold() => Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24.r),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.videocam_off, color: Colors.white70, size: 56.r),
              SizedBox(height: 16.h),
              Text(
                'Camera and microphone access required',
                style: AppTypography.body.copyWith(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),
              FilledButton(
                onPressed: () => context.pop(),
                style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary),
                child: const Text('Go Back'),
              ),
            ]),
          ),
        ),
      );

  Widget _errorScaffold(String message) => Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24.r),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.error_outline, color: AppColors.danger, size: 56.r),
              SizedBox(height: 16.h),
              Text(message,
                  style: AppTypography.body.copyWith(color: Colors.white),
                  textAlign: TextAlign.center),
              SizedBox(height: 24.h),
              FilledButton(
                onPressed: () => context.pop(),
                style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary),
                child: const Text('Go Back'),
              ),
            ]),
          ),
        ),
      );

  Widget _activeCallScaffold(BuildContext context, VideoCallActive state) {
    final bloc = context.read<VideoCallBloc>();
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _showControls,
        child: Stack(
          children: [
            // Remote video — full screen
            Positioned.fill(
              child: bloc.remoteRenderer != null
                  ? RTCVideoView(bloc.remoteRenderer!,
                      objectFit:
                          RTCVideoViewObjectFit.RTCVideoViewObjectFitCover)
                  : Container(color: Colors.black87),
            ),

            // Low bitrate warning
            if (state.lowBitrate)
              Positioned(
                top: MediaQuery.of(context).padding.top + 8.h,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 12.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text('Poor connection',
                        style: AppTypography.caption
                            .copyWith(color: Colors.white)),
                  ),
                ),
              ),

            // Top bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AnimatedOpacity(
                opacity: _controlsVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  padding: EdgeInsets.fromLTRB(
                      16.w,
                      MediaQuery.of(context).padding.top + 8.h,
                      16.w,
                      12.h),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.7),
                        Colors.transparent
                      ],
                    ),
                  ),
                  child: Row(children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.consultation.doctorName,
                            style: AppTypography.body
                                .copyWith(color: Colors.white),
                          ),
                          Text(
                            state.consultation.doctorSpecialty,
                            style: AppTypography.caption.copyWith(
                                color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    // Chat button with unread badge
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chat_bubble_outline,
                              color: Colors.white),
                          onPressed: () =>
                              bloc.add(const VideoCallChatToggled()),
                        ),
                        if (state.unreadCount > 0)
                          Positioned(
                            right: 8.r,
                            top: 8.r,
                            child: Container(
                              width: 16.r,
                              height: 16.r,
                              decoration: BoxDecoration(
                                color: AppColors.danger,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${state.unreadCount}',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10.sp),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ]),
                ),
              ),
            ),

            // Local video — PiP in top-right corner
            Positioned(
              top: MediaQuery.of(context).padding.top + 60.h,
              right: 16.w,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: SizedBox(
                  width: 80.w,
                  height: 120.h,
                  child: bloc.localRenderer != null
                      ? RTCVideoView(bloc.localRenderer!,
                          mirror: true,
                          objectFit: RTCVideoViewObjectFit
                              .RTCVideoViewObjectFitCover)
                      : Container(color: Colors.black54),
                ),
              ),
            ),

            // Bottom controls
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: AnimatedOpacity(
                opacity: _controlsVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  padding: EdgeInsets.fromLTRB(
                      16.w,
                      16.h,
                      16.w,
                      MediaQuery.of(context).padding.bottom + 24.h),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.7),
                        Colors.transparent
                      ],
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _ControlBtn(
                        icon: state.isMuted
                            ? Icons.mic_off
                            : Icons.mic,
                        label: state.isMuted ? 'Unmute' : 'Mute',
                        active: !state.isMuted,
                        onTap: () =>
                            bloc.add(const VideoCallMicToggled()),
                      ),
                      _ControlBtn(
                        icon: state.isCameraOff
                            ? Icons.videocam_off
                            : Icons.videocam,
                        label: state.isCameraOff ? 'Camera On' : 'Camera Off',
                        active: !state.isCameraOff,
                        onTap: () =>
                            bloc.add(const VideoCallCameraToggled()),
                      ),
                      _EndCallBtn(
                        onTap: () =>
                            bloc.add(const VideoCallEndRequested()),
                      ),
                      _ControlBtn(
                        icon: state.isSpeakerOn
                            ? Icons.volume_up
                            : Icons.volume_off,
                        label: 'Speaker',
                        active: state.isSpeakerOn,
                        onTap: () =>
                            bloc.add(const VideoCallSpeakerToggled()),
                      ),
                      _ControlBtn(
                        icon: Icons.flip_camera_ios,
                        label: 'Flip',
                        active: true,
                        onTap: () =>
                            bloc.add(const VideoCallCameraSwitched()),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Chat drawer
            if (state.isChatOpen)
              _ChatDrawer(
                messages: state.messages,
                onClose: () => bloc.add(const VideoCallChatToggled()),
                onSend: (text) =>
                    bloc.add(VideoCallMessageSent(text)),
              ),
          ],
        ),
      ),
    );
  }
}

class _ControlBtn extends StatelessWidget {
  const _ControlBtn({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48.r,
            height: 48.r,
            decoration: BoxDecoration(
              color: active
                  ? Colors.white.withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 22.r),
          ),
          SizedBox(height: 4.h),
          Text(label,
              style: TextStyle(
                  color: Colors.white70, fontSize: 10.sp)),
        ],
      ),
    );
  }
}

class _EndCallBtn extends StatelessWidget {
  const _EndCallBtn({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56.r,
            height: 56.r,
            decoration: BoxDecoration(
              color: AppColors.danger,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.call_end, color: Colors.white, size: 26.r),
          ),
          SizedBox(height: 4.h),
          Text('End',
              style: TextStyle(
                  color: Colors.white70, fontSize: 10.sp)),
        ],
      ),
    );
  }
}

class _ChatDrawer extends StatefulWidget {
  const _ChatDrawer({
    required this.messages,
    required this.onClose,
    required this.onSend,
  });

  final List<dynamic> messages;
  final VoidCallback onClose;
  final void Function(String) onSend;

  @override
  State<_ChatDrawer> createState() => _ChatDrawerState();
}

class _ChatDrawerState extends State<_ChatDrawer> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void didUpdateWidget(_ChatDrawer old) {
    super.didUpdateWidget(old);
    if (widget.messages.length != old.messages.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      height: MediaQuery.of(context).size.height * 0.5,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.88),
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
        ),
        child: Column(
          children: [
            // Handle + header
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Row(
                children: [
                  SizedBox(width: 16.w),
                  Text('Chat',
                      style:
                          AppTypography.body.copyWith(color: Colors.white)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: widget.onClose,
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white24, height: 1),
            // Messages
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.all(12.r),
                itemCount: widget.messages.length,
                itemBuilder: (_, i) {
                  final msg = widget.messages[i];
                  final isPatient = msg.isFromPatient as bool;
                  return Align(
                    alignment: isPatient
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: EdgeInsets.only(bottom: 8.h),
                      padding: EdgeInsets.symmetric(
                          horizontal: 12.w, vertical: 8.h),
                      constraints:
                          BoxConstraints(maxWidth: 240.w),
                      decoration: BoxDecoration(
                        color: isPatient
                            ? AppColors.primary.withValues(alpha: 0.8)
                            : Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        msg.content as String,
                        style: AppTypography.caption
                            .copyWith(color: Colors.white),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Input
            Container(
              padding: EdgeInsets.fromLTRB(
                  12.w,
                  8.h,
                  12.w,
                  MediaQuery.of(context).viewInsets.bottom + 12.h),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Type a message…',
                        hintStyle:
                            const TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24.r),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 10.h),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  IconButton(
                    icon: Icon(Icons.send,
                        color: AppColors.primary, size: 22.r),
                    onPressed: () {
                      final text = _controller.text.trim();
                      if (text.isNotEmpty) {
                        widget.onSend(text);
                        _controller.clear();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
