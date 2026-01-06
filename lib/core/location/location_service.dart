import 'package:geolocator/geolocator.dart';

class LocationService {
  static Future<Position> getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Usługi lokalizacji są wyłączone.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw Exception('Brak zgody na lokalizację.');
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Lokalizacja zablokowana na stałe (ustawienia systemu).');
    }

    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.low, // do pogody wystarczy
    );
  }
}
