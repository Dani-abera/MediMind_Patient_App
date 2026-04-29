import 'dart:async';
import 'package:signalr_netcore/signalr_client.dart';
import '../constants/api_constants.dart';
import '../storage/secure_storage.dart';

/// Base SignalR hub wrapper with auth, exponential back-off reconnect,
/// and a public connection-state stream.
class SignalRService {
  SignalRService({required this.hubPath, required this.secureStorage});

  final String hubPath;
  final SecureStorage secureStorage;

  HubConnection? _hub;
  int _failCount = 0;
  Timer? _pollFallbackTimer;
  bool _disposed = false;

  final _stateController =
      StreamController<HubConnectionState>.broadcast();

  Stream<HubConnectionState> get connectionState =>
      _stateController.stream;

  HubConnectionState get currentState =>
      _hub?.state ?? HubConnectionState.Disconnected;

  bool get isConnected => currentState == HubConnectionState.Connected;

  // Exponential back-off delays: 1s, 2s, 4s, 8s, 16s, 30s cap
  static const _backoffMs = [1000, 2000, 4000, 8000, 16000, 30000];

  Future<void> connect() async {
    if (_disposed) return;
    _hub = HubConnectionBuilder()
        .withUrl(
          '${ApiConstants.signalRBaseUrl}$hubPath',
          options: HttpConnectionOptions(
            accessTokenFactory: () async =>
                await secureStorage.getAccessToken() ?? '',
            skipNegotiation: false,
          ),
        )
        .withAutomaticReconnect(
            retryDelays: [1000, 2000, 4000, 8000, 16000, 30000])
        .build();

    _hub!.onreconnecting(({error}) {
      _stateController.add(HubConnectionState.Reconnecting);
    });

    _hub!.onreconnected(({connectionId}) {
      _failCount = 0;
      _stateController.add(HubConnectionState.Connected);
      onReconnected();
    });

    _hub!.onclose(({error}) {
      _stateController.add(HubConnectionState.Disconnected);
      onDisconnected();
    });

    try {
      await _hub!.start();
      _failCount = 0;
      _stateController.add(HubConnectionState.Connected);
    } catch (_) {
      _failCount++;
      _stateController.add(HubConnectionState.Disconnected);
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (_disposed) return;
    final idx = (_failCount - 1).clamp(0, _backoffMs.length - 1);
    final delay = Duration(milliseconds: _backoffMs[idx]);
    Timer(delay, () async {
      if (!_disposed) await connect();
    });
  }

  Future<void> disconnect() async {
    _disposed = true;
    _pollFallbackTimer?.cancel();
    await _hub?.stop();
    _hub = null;
    _stateController.add(HubConnectionState.Disconnected);
  }

  void on(String method, MethodInvocationFunc handler) =>
      _hub?.on(method, handler);

  Future<void> send(String method, {List<Object>? args}) async {
    if (!isConnected) return;
    await _hub?.send(method, args: args);
  }

  Future<Object?> invoke(String method, {List<Object>? args}) async {
    if (!isConnected) return null;
    return _hub?.invoke(method, args: args);
  }

  void startPollingFallback(Duration interval, void Function() onTick) {
    _pollFallbackTimer?.cancel();
    _pollFallbackTimer = Timer.periodic(interval, (_) => onTick());
  }

  void stopPollingFallback() {
    _pollFallbackTimer?.cancel();
    _pollFallbackTimer = null;
  }

  /// Override in subclasses to re-join groups after reconnect
  void onReconnected() {}

  /// Override to react to disconnection
  void onDisconnected() {}

  void dispose() {
    _disposed = true;
    _pollFallbackTimer?.cancel();
    _stateController.close();
  }
}
