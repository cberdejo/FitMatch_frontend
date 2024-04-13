import 'package:fit_match/models/notificaciones.dart';
import 'package:http/http.dart' as http;
import 'package:fit_match/utils/backend_urls.dart';
import 'dart:async';
import 'dart:convert';

class NotificacionesMethods {
  Future<List<Notificacion>> getNotificationes(
    num userId,
  ) async {
    String url = "$notificacionUrl/$userId";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body) as List;
      return jsonData
          .map((jsonItem) => Notificacion.fromJson(jsonItem))
          .toList();
    } else {
      throw Exception(
          'Error al obtener las notificaciones. Código de estado: ${response.statusCode}');
    }
  }

  Future<void> readNotificationes(num userId) async {
    String url = "$notificacionUrl/$userId";

    final response = await http.put(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception(
          'Error al marcar la notificacion. Código de estado: ${response.statusCode}');
    }
  }
}
