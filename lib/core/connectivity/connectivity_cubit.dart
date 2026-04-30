import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../network/network_info.dart';

enum ConnectivityStatus { connected, disconnected }

class ConnectivityCubit extends Cubit<ConnectivityStatus> {
  ConnectivityCubit(NetworkInfo networkInfo)
      : super(ConnectivityStatus.connected) {
    _sub = networkInfo.onStatusChange.listen((isConnected) {
      emit(isConnected
          ? ConnectivityStatus.connected
          : ConnectivityStatus.disconnected);
    });
    // Check immediately
    networkInfo.isConnected.then((ok) {
      if (!isClosed) {
        emit(ok
            ? ConnectivityStatus.connected
            : ConnectivityStatus.disconnected);
      }
    });
  }

  late final StreamSubscription<bool> _sub;

  @override
  Future<void> close() {
    _sub.cancel();
    return super.close();
  }
}
