import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:fit_match/models/post.dart';
import 'package:fit_match/utils/backend_urls.dart';

class PlantillaPostsMethods {
  Future<PlantillaPost> getPlantillaById(int templateId) async {
    final response =
        await http.get(Uri.parse('$plantillaPostsUrl/$templateId'));
    if (response.statusCode == 200) {
      return PlantillaPost.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
          'Error al obtener el post. Código de estado: ${response.statusCode}');
    }
  }

  Future<List<PlantillaPost>> getAllPosts({
    num? userId,
    int? page = 1,
    int? pageSize = 10,
    bool? isPublic,
    bool? isHidden,
    String? name,
    List<String>? experiences,
    List<String>? objectives,
    List<String>? interests,
    List<String>? equipment,
    List<String>? duration,
  }) async {
    // Construye la URL base con parámetros existentes
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
    if (name != null) {
      url += "&name=$name";
    }

    // Añade filtros de etiquetas como parámetros de consulta
    if (experiences != null && experiences.isNotEmpty) {
      url += "&experience=${experiences.join(',')}";
    }
    if (objectives != null && objectives.isNotEmpty) {
      url += "&objective=${objectives.join(',')}";
    }
    if (interests != null && interests.isNotEmpty) {
      url += "&interests=${interests.join(',')}";
    }
    if (equipment != null && equipment.isNotEmpty) {
      url += "&equipment=${equipment.join(',')}";
    }
    if (duration != null && duration.isNotEmpty) {
      url += "&duration=${duration.join(',')}";
    }

    // Realiza la solicitud GET
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body) as List;
      return jsonData
          .map((jsonItem) => PlantillaPost.fromJson(jsonItem))
          .toList();
    } else if (response.statusCode == 204) {
      return [];
    } else {
      throw Exception(
          'Error al obtener los posts. Código de estado: ${response.statusCode}');
    }
  }

  Future<int> postPlantilla({
    required num userId,
    required String templateName,
    required String description,
    Uint8List? picture,
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
      request.fields['etiquetas[$i][duration]'] = etiquetas[i].duration ?? '';
    }
  }

  Future<int> updatePlantilla(
      PlantillaPost plantilla, Uint8List? picture) async {
    // Crear un MultipartRequest
    var request = http.MultipartRequest(
        'PUT', Uri.parse('$plantillaPostsUrl/${plantilla.templateId}'));

    // Agregar campos de texto
    request.fields['template_name'] = plantilla.templateName;
    if (plantilla.description != null) {
      request.fields['description'] = plantilla.description!;
    }
    request.fields['user_id'] = plantilla.userId.toString();
    addEtiquetasToRequest(request, plantilla.etiquetas);

    // Si se proporciona una imagen, inclúyela en el request
    if (picture != null) {
      var pictureStream = http.ByteStream(Stream.value(picture));
      var pictureLength = picture.length;
      var multipartFile = http.MultipartFile(
          'picture', pictureStream, pictureLength,
          filename: 'template_picture.jpg');
      request.files.add(multipartFile);
    }

    // Enviar el request
    var response = await request.send();
    if (response.statusCode == 200) {
      var responseBody = await response.stream.bytesToString();
      var decodedResponse = jsonDecode(responseBody);
      return decodedResponse['template_id'];
    } else {
      throw Exception(
          'Error al actualizar la plantilla. Código de estado: ${response.statusCode}');
    }
  }

  Future<bool> toggleHidden(num templateId, String option,
      {num? userId}) async {
    String url;

    switch (option) {
      case 'creados':
        url = '$plantillaHiddenCreadaUrl/$templateId';
        break;
      case 'guardadas':
        if (userId != null) {
          url = '$plantillaHiddenGuardadaUrl/$templateId/$userId';
        } else {
          return false;
        }
        break;
      case 'archivadas':
        if (userId != null) {
          url = '$plantillaHiddenArchivadaUrl/$templateId/$userId';
        } else {
          return false;
        }
        break;
      default:
        return false;
    }
    final response = await http.put(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 200) {
      throw Exception(
          'Error al ocultar la plantilla. Código de estado: ${response.statusCode}');
    } else {
      return true;
    }
  }

  Future<bool> togglePublico(num templateId) async {
    final response = await http.put(
      Uri.parse('$plantillaPublicoUrl/$templateId'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 200) {
      throw Exception(
          'Error al mostrar la plantilla. Código de estado: ${response.statusCode}');
    } else {
      return true;
    }
  }

  Future<bool> archivar(num templateId, num userId) async {
    final response = await http.post(Uri.parse(archivarPlantillaUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'template_id': templateId, 'user_id': userId}));
    if (response.statusCode != 200) {
      throw Exception(
          'Error al archivar la plantilla. Código de estado: ${response.statusCode}');
    } else {
      return true;
    }
  }

  Future<bool> guardar(num templateId, num userId) async {
    final response = await http.post(Uri.parse(guardarPlantillaUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'template_id': templateId, 'user_id': userId}));
    if (response.statusCode != 200) {
      throw Exception(
          'Error al guardar la plantilla. Código de estado: ${response.statusCode}');
    } else {
      return true;
    }
  }
}

class RutinaGuardadaMethods {
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

  Future<List<PlantillaPost>> getPlantillas(num userId) async {
    final response = await http.get(
      Uri.parse('$rutinasGuardadasUrl/$userId'),
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

class RutinasArchivadaMethods {
  Future<void> createRutinaArchivada(int userId, int templateId) async {
    final response = await http.post(
      Uri.parse(rutinasArchivadasUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'template_id': templateId,
      }),
    );
    if (response.statusCode != 201) {
      throw Exception(
          'Error al archivar la rutina. Código de estado: ${response.statusCode}');
    }
  }

  Future<void> deleteRutinaGuardada(int archivedId) async {
    final response =
        await http.delete(Uri.parse('$rutinasArchivadasUrl/$archivedId'));
    if (response.statusCode != 200) {
      throw Exception(
          'Error al archivar la rutina. Código de estado: ${response.statusCode}');
    }
  }

  Future<List<PlantillaPost>> getPlantillas(num userId) async {
    final response = await http.get(
      Uri.parse('$rutinasArchivadasUrl/$userId'),
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
