import 'package:dio/dio.dart';
import 'package:talker_flutter/talker_flutter.dart';

class SessionErrorHandler {
  final Talker talker;

  SessionErrorHandler(this.talker);

  /// Główna metoda mapująca błąd na tekst dla UI
  String handle(Object e, String context) {
    String message = 'Wystąpił nieoczekiwany błąd';

    if (e is DioException) {
      final status = e.response?.statusCode;
      final data = e.response?.data;

      // Logowanie szczegółowe do Talkera
      talker.error('[$context] HTTP $status: $data');

      // Mapowanie statusów
      message = _mapHttpStatusCode(status, data);
    } else {
      talker.critical('[$context] Błąd krytyczny: $e');
      message = 'Błąd systemowy: $e';
    }

    return message;
  }

  String _mapHttpStatusCode(int? status, dynamic data) {
    switch (status) {
      case 400: return 'Błędne dane zapytania.';
      case 401: return 'Błąd autoryzacji. Niepoprawny PIN lub Token.';
      case 403: return 'Brak uprawnień do wykonania tej akcji.';
      case 404: return 'Nie znaleziono pracownika.';
      case 422: return 'Serwer nie może przetworzyć danych (Błąd walidacji).';
      case 500: return 'Błąd serwera. Spróbuj ponownie za chwilę.';
      default: return 'Błąd połączenia (Status: $status)';
    }
  }
}