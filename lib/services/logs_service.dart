import 'dart:convert';
import 'package:fit_match/models/logs.dart';
import 'package:http/http.dart' as http;
import 'package:fit_match/utils/backend_urls.dart';
import 'dart:async';

class LogsMethods {
  Future<List<Log>> getLogs(int userId, {String? ip}) async {
    try {
      String url = "$logsUrl/$userId ";
      if (ip != null) {
        url += "?ip=$ip";
      }
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body) as List;
        return jsonData.map((jsonItem) => Log.fromJson(jsonItem)).toList();
      } else {
        throw Exception(
            'Error al obtener los logs. Código de estado: ${response.statusCode}');
      }
    } catch (e) {
      print(e);

      rethrow;
    }
  }

  Future<List<Bloqueo>> getBloqueos(int userId, {String? ip}) async {
    try {
      String url = "$bloqueosUrl/$userId ";
      if (ip != null) {
        url += "?ip=$ip";
      }
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body) as List;
        return jsonData.map((jsonItem) => Bloqueo.fromJson(jsonItem)).toList();
      } else {
        throw Exception(
            'Error al obtener los bloqueos. Código de estado: ${response.statusCode}');
      }
    } catch (e) {
      print(e);

      rethrow;
    }
  }
}
