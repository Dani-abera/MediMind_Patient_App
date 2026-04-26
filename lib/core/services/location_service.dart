import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

/// Default Addis Ababa coordinates used when location is unavailable.
const _defaultLat = 9.0320;
const _defaultLng = 38.7469;

class LocationService {
  Position? _cached;
  DateTime? _cachedAt;
  static const _ttl = Duration(minutes: 5);

  Future<Position> getCurrentLocation() async {
    if (_cached != null &&
        _cachedAt != null &&
        DateTime.now().difference(_cachedAt!) < _ttl) {
      return _cached!;
    }

    final status = await Permission.location.request();
    if (!status.isGranted) return _defaultPosition();

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return _defaultPosition();

    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );
      _cached = pos;
      _cachedAt = DateTime.now();
      return pos;
    } catch (_) {
      return _cached ?? _defaultPosition();
    }
  }

  Position _defaultPosition() => Position(
        latitude: _defaultLat,
        longitude: _defaultLng,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      );
}
