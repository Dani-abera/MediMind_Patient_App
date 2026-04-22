import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class NetworkInfo {
  NetworkInfo(this._checker);
  final InternetConnection _checker;

  Future<bool> get isConnected => _checker.hasInternetAccess;

  Stream<bool> get onStatusChange =>
      _checker.onStatusChange.map(
        (status) => status == InternetStatus.connected,
      );
}
