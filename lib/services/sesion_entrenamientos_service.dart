import 'dart:convert';
import 'package:fit_match/models/ejercicios.dart';
import 'package:fit_match/models/sesion_entrenamiento.dart';
import 'package:http/http.dart' as http;
import 'package:fit_match/utils/backend_urls.dart';

class SesionEntrenamientoMethods {
  Future<SesionEntrenamiento> createSesionEntrenamiento(
      {required int templateId,
      required num order,
      sessionName = 'Sesión de Entrenamiento',
      num? notes}) async {
    final response = await http.post(
      Uri.parse(sesionEntrenamientoUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'template_id': templateId,
        'order': order,
        'session_name': sessionName,
        'notes': notes
      }),
    );
    if (response.statusCode != 201) {
      throw Exception(
          'Error al crear la sesión de entrenamiento. Código de estado: ${response.statusCode}');
    } else {
      return SesionEntrenamiento.fromJson(jsonDecode(response.body));
    }
  }

  Future<void> deleteSesionEntrenamiento(int sessionId) async {
    final response =
        await http.delete(Uri.parse('$sesionEntrenamientoUrl/$sessionId'));
    if (response.statusCode != 200) {
      throw Exception(
          'Error al eliminar la sesión de entrenamiento. Código de estado: ${response.statusCode}');
    }
  }

  Future<int> editSesionEntrenamiento(SesionEntrenamiento sessionData) async {
    final response = await http.put(
      Uri.parse('$sesionEntrenamientoUrl/${sessionData.sessionId}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(sessionData.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception(
          'Error al editar la sesión de entrenamiento. Código de estado: ${response.statusCode}');
    } else {
      return response.statusCode;
    }
  }

  Future<List<SesionEntrenamiento>> getSesionesEntrenamientoByTemplateId(
      templateId) async {
    final response = await http.get(
      Uri.parse('$sesionEntrenamientoTemplateUrl/$templateId'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body) as List;
      return jsonData
          .map((jsonItem) => SesionEntrenamiento.fromJson(jsonItem))
          .toList();
    } else {
      throw Exception(
          'Error al obtener las sesiones de entrenamiento. Código de estado: ${response.statusCode}');
    }
  }

  Future<SesionEntrenamiento> getSesionesEntrenamientoBySessionId(
      int sessionId) async {
    final response =
        await http.get(Uri.parse('$sesionEntrenamientoUrl/$sessionId'));
    if (response.statusCode == 200) {
      return SesionEntrenamiento.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
          'Error al obtener los posts. Código de estado: ${response.statusCode}');
    }
  }
}

class EjerciciosMethods {
  Future<void> createEjercicio(String name, String description) async {
    final response = await http.post(
      Uri.parse(ejerciciosUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'description': description,
      }),
    );
    if (response.statusCode != 201) {
      throw Exception(
          'Error al crear el ejercicio. Código de estado: ${response.statusCode}');
    }
  }

  Future<List<Ejercicios>> getAllEjercicios({
    num? userId,
    String? name,
    int? idGrupoMuscular,
    int? idMaterial,
    int page = 1,
    int pageSize = 20,
  }) async {
    // Comienza con la URL base y los parámetros de paginación.
    String url = "$ejerciciosUrl?page=$page&pageSize=$pageSize";

    // Añade los parámetros adicionales si están presentes.
    if (userId != null) url += "&userId=$userId";
    if (name != null) {
      url +=
          "&name=${Uri.encodeComponent(name)}"; // Codifica el nombre para URL.
    }
    if (idGrupoMuscular != null) url += "&idGrupoMuscular=$idGrupoMuscular";
    if (idMaterial != null) url += "&idMaterial=$idMaterial";

    // Realiza la solicitud HTTP.
    final response = await http.get(Uri.parse(url));

    // Procesa la respuesta.
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body) as List;
      return jsonData.map((jsonItem) => Ejercicios.fromJson(jsonItem)).toList();
    } else {
      throw Exception(
          'Error al obtener los ejercicios. Código de estado: ${response.statusCode}');
    }
  }

  Future<List<GrupoMuscular>> getGruposMusculares() async {
    final response = await http.get(Uri.parse(grupoMuscularesUrl));
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body) as List;
      return jsonData
          .map((jsonItem) => GrupoMuscular.fromJson(jsonItem))
          .toList();
    } else {
      throw Exception('Error al obtener los grupos musculares');
    }
  }

  Future<List<Equipment>> getMaterial() async {
    final response = await http.get(Uri.parse(materialUrl));
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body) as List;
      return jsonData
          .map((jsoinItem) => Equipment.fromJson(jsoinItem))
          .toList();
    } else {
      throw Exception('Error al obtener los materiales');
    }
  }

  Future<List<Ejercicios>> getEjerciciosByGrupoMuscular({
    required int grupoMuscularId,
    int? page = 1,
    int? pageSize = 20,
  }) async {
    String url =
        "$ejerciciosUrl/grupoMuscular/$grupoMuscularId?page=$page&pageSize=$pageSize";

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body) as List;
      return jsonData.map((jsonItem) => Ejercicios.fromJson(jsonItem)).toList();
    } else {
      throw Exception(
          'Error al obtener los ejercicios por grupo muscular. Código de estado: ${response.statusCode}');
    }
  }

  Future<List<TipoDeRegistro>> getTiposDeRegistro() async {
    final response = await http.get(Uri.parse(tipoRegistroUrl));
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body) as List;
      return jsonData
          .map((jsonItem) => TipoDeRegistro.fromJson(jsonItem))
          .toList();
    } else {
      throw Exception('Error al obtener los tipos de registro');
    }
  }
}

class EjercicioDetalladosAgrupadoMethods {
  Future<List<EjerciciosDetalladosAgrupados>>
      getEjerciciosDetalladosAgrupadosBySesionId(
    int sessionId,
  ) async {
    final response =
        await http.get(Uri.parse('$groupedExercisesUrl/$sessionId'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body) as List;
      return jsonData
          .map((jsonItem) => EjerciciosDetalladosAgrupados.fromJson(jsonItem))
          .toList();
    } else {
      throw Exception(
          'Error al obtener los ejercicios detallados agrupados. Código de estado: ${response.statusCode}');
    }
  }

  Future<void> createGroupedDetailedExercises({
    required int sessionId,
    required int order,
    required List<Map<String, dynamic>> exercises,
  }) async {
    final response = await http.post(
      Uri.parse(groupedExercisesUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'sessionId': sessionId,
        'order': order,
        'exercises': exercises,
      }),
    );
    if (response.statusCode != 201) {
      throw Exception(
          'Error al crear ejercicios detallados agrupados. Código de estado: ${response.statusCode}');
    }
  }
}
