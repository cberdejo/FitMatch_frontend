import 'dart:convert';
import 'package:fit_match/models/registros.dart';
import 'package:fit_match/models/sesion_entrenamiento.dart';
import 'package:http/http.dart' as http;
import 'package:fit_match/utils/backend_urls.dart';

class RegistroMethods {
  Future<List<RegistroSet>> getAllRegistersByUserIdAndDetailedExerciseId(
      int userId, int detailedExerciseId) async {
    final response = await http.get(
      Uri.parse('$registrosUrl/$userId/$detailedExerciseId'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((data) => RegistroSet.fromJson(data)).toList();
    } else {
      throw Exception(
          'Error al obtener los registros. Código de estado: ${response.statusCode}');
    }
  }

  Future<List<RegistroDeSesion>> getAllRegistersByUserIdAndSessionId(
      int userId, int sessionId) async {
    final response = await http.get(
      Uri.parse('$registrosSessionUrl/$userId/$sessionId'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      final List jsonResponse = jsonDecode(response.body);
      return jsonResponse
          .map((data) => RegistroDeSesion.fromJson(data))
          .toList();
    } else {
      throw Exception('Error al obtener los registros: ${response.statusCode}');
    }
  }

  Future<RegistroDeSesion> getLastRegisterByUserIdAndSessionId(
      int userId, int sessionId) async {
    final response = await http.get(
      Uri.parse('$registroSessionAnteriorUrl/$userId/$sessionId'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      return RegistroDeSesion.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
          'Error al obtener el último registro: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> getLastRegistersByUserIdAndTemplateId(
      int userId, int templateId) async {
    final response = await http.get(
      Uri.parse('$registrosSessionPlantillaUrl/$userId/$templateId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      final SesionEntrenamiento sesionEntrenamiento =
          SesionEntrenamiento.fromJson(responseBody['sesion']);
      final bool finished = responseBody['finished'];

      return {
        'sesion': sesionEntrenamiento,
        'finished': finished,
      };
    } else {
      throw Exception(
          'Error al obtener el último registro: ${response.statusCode}');
    }
  }

  Future<List<RegistroSet>> getAllRegisterSetFromRegisterSessionId(
      int sessionId) async {
    final response = await http.get(
      Uri.parse('$registrosUrl/$sessionId'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      final List jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((data) => RegistroSet.fromJson(data)).toList();
    } else {
      throw Exception(
          'Error al obtener los registros de sets: ${response.statusCode}');
    }
  }

  Future<RegistroDeSesion> createRegisterSession(
      int userId, int sessionId) async {
    final response = await http.post(
      Uri.parse(registrosSessionUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user_id': userId, 'session_id': sessionId}),
    );
    if (response.statusCode == 200) {
      return RegistroDeSesion.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
          'Error al crear el registro de sesión: ${response.statusCode}');
    }
  }

  Future<RegistroSet> addOrUpdateRegisterSet({
    required int userId,
    required int registerSessionId,
    required int setId,
    bool? create,
    int? registerSetId,
    int? reps,
    double? weight,
    double? time,
  }) async {
    final response = await http.post(
      Uri.parse(registrosUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'create': create,
        'user_id': userId,
        'register_session_id': registerSessionId,
        'set_id': setId,
        'register_set_id': registerSetId,
        'reps': reps,
        'weight': weight,
        'time': time,
      }),
    );
    if (response.statusCode == 200) {
      return RegistroSet.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
          'Error al añadir o actualizar el registro de set: ${response.statusCode}');
    }
  }

  Future<SesionEntrenamiento> getSessionEntrenamientoWithRegistros(
      int userId, int sessionId) async {
    final response = await http.get(
      Uri.parse('$sessionRegistrosUrl/$userId/$sessionId'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      return SesionEntrenamiento.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
          'Error al obtener el último registro: ${response.statusCode}');
    }
  }

  Future<bool> eliminarRegistroSet(int registerSetId) async {
    final response = await http.delete(
      Uri.parse('$registrosUrl/$registerSetId'),
    );
    return response.statusCode == 200;
  }

  Future<bool> eliminarRegistroSession(int registerSessionId) async {
    final response = await http.delete(
      Uri.parse('$registrosSessionUrl/$registerSessionId'),
    );
    return response.statusCode == 200;
  }

  Future<bool> terminarRegistro(int registerSessionId) async {
    final response = await http.put(
      Uri.parse('$registrosSessionUrl/$registerSessionId'),
      headers: {'Content-Type': 'application/json'},
    );
    return response.statusCode == 200;
  }

  Future<List<SesionEntrenamiento>> getSesionesWithRegisterByUserId(int userId,
      {DateTime? fecha}) async {
    String? fechaString = fecha?.toIso8601String();
    // Construir la URI. Si 'fecha' no es nulo, añade el query parameter.
    var uri = Uri.parse('$registrosSessionPlantillaUrl/$userId')
        .replace(queryParameters: fecha != null ? {'date': fechaString} : {});

    final response = await http.get(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List jsonResponse = jsonDecode(response.body);
      return jsonResponse
          .map((data) => SesionEntrenamiento.fromJson(data))
          .toList();
    } else if (response.statusCode == 204) {
      return [];
    } else {
      throw Exception('Error al obtener las sesiones: ${response.statusCode}');
    }
  }
}
