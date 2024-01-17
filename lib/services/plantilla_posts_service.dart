import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:fit_match/models/post.dart'; // Asegúrate de importar tu clase Post
import 'package:fit_match/utils/backend_urls.dart';

class PlantillaPostsMethods {
  Future<List<PlantillaPost>> getAllPosts(
      {num? userId,
      int? page = 1,
      int? pageSize = 10,
      bool? isPublic = true,
      bool? isHidden = false}) async {
    String url = "$plantillaPostsUrl?page=$page&pageSize=$pageSize";
    if (userId != null) {
      url += "&userId=$userId";
    }
    if (isPublic != null) {
      url += "&isPublic=$isPublic";
    }
    if (isHidden != null) {
      url += "&isHidden=$isHidden";
    }

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body) as List;
      return jsonData
          .map((jsonItem) => PlantillaPost.fromJson(jsonItem))
          .toList();
    } else {
      throw Exception(
          'Error al obtener los posts. Código de estado: ${response.statusCode}');
    }
  }

  Future<int> postPlantilla({
    required num userId,
    required String templateName,
    required String description,
    required Uint8List? picture,
    required List<Etiqueta> etiquetas,
  }) async {
    var request = http.MultipartRequest('POST', Uri.parse(plantillaPostsUrl));
    if (picture != null) {
      var pictureStream = http.ByteStream(Stream.value(picture));
      var pictureLength = picture.length;
      var multipartFile = http.MultipartFile(
          'picture', pictureStream, pictureLength,
          filename: 'template_picture.jpg');
      request.files.add(multipartFile);
    }
    request.fields['template_name'] = templateName;
    request.fields['description'] = description;
    request.fields['user_id'] = userId.toString();
    addEtiquetasToRequest(request, etiquetas);
    var response = await request.send();
    if (response.statusCode == 200) {
      var responseBody = await response.stream.bytesToString();
      var decodedResponse = jsonDecode(responseBody);
      return decodedResponse['template_id'];
    } else {
      var responseBody = await response.stream.bytesToString();
      throw Exception(
          'Error al crear la plantilla. Código de estado: ${response.statusCode}, Respuesta: $responseBody');
    }
  }

  void addEtiquetasToRequest(
      http.MultipartRequest request, List<Etiqueta> etiquetas) {
    for (int i = 0; i < etiquetas.length; i++) {
      request.fields['etiquetas[$i][objectives]'] =
          etiquetas[i].objectives ?? '';
      request.fields['etiquetas[$i][experience]'] =
          etiquetas[i].experience ?? '';
      request.fields['etiquetas[$i][interests]'] = etiquetas[i].interests ?? '';
      request.fields['etiquetas[$i][equipment]'] = etiquetas[i].equipment ?? '';
    }
  }

  Future<void> putPlantilla(PlantillaPost plantilla) async {
    final response = await http.put(
      Uri.parse('$plantillaPostsUrl/${plantilla.templateId}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(plantilla.toJson()),
    );
    if (response.statusCode == 200) {
      print('Plantilla actualizada con éxito');
    } else {
      throw Exception(
          'Error al actualizar la plantilla. Código de estado: ${response.statusCode}');
    }
  }
}

class SesionEntrenamientoMethods {
  Future<void> createSesionEntrenamiento({
    required int templateId,
    required List<Map<String, dynamic>> ejercicios,
  }) async {
    final response = await http.post(
      Uri.parse('$sesionEntrenamientoUrl'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'template_id': templateId,
        'ejercicios': ejercicios,
      }),
    );
    if (response.statusCode != 201) {
      throw Exception(
          'Error al crear la sesión de entrenamiento. Código de estado: ${response.statusCode}');
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

  Future<void> editSesionEntrenamiento(
      int sessionId, Map<String, dynamic> sessionData) async {
    final response = await http.put(
      Uri.parse('$sesionEntrenamientoUrl/$sessionId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(sessionData),
    );
    if (response.statusCode != 200) {
      throw Exception(
          'Error al editar la sesión de entrenamiento. Código de estado: ${response.statusCode}');
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
}

class RutinaMethods {
  Future<void> createRutinaGuardada(int userId, int templateId) async {
    final response = await http.post(
      Uri.parse(rutinasGuardadasUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'template_id': templateId,
      }),
    );
    if (response.statusCode != 201) {
      throw Exception(
          'Error al guardar la rutina. Código de estado: ${response.statusCode}');
    }
  }

  Future<void> deleteRutinaGuardada(int savedId) async {
    final response =
        await http.delete(Uri.parse('$rutinasGuardadasUrl/$savedId'));
    if (response.statusCode != 200) {
      throw Exception(
          'Error al eliminar la rutina guardada. Código de estado: ${response.statusCode}');
    }
  }

  Future<List<PlantillaPost>> getPlantillas(
      num userId, int page, int pageSize) async {
    final response = await http.get(
      Uri.parse(
          '$rutinasGuardadasUrl?user_id=$userId&page=$page&pageSize=$pageSize'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((json) => PlantillaPost.fromJson(json)).toList();
    } else {
      throw Exception(
          'Error al obtener las plantillas. Código de estado: ${response.statusCode}');
    }
  }
}
