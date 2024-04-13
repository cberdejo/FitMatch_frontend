import 'dart:convert';
import 'dart:typed_data';
import 'package:fit_match/models/medidas.dart';
import 'package:fit_match/utils/backend_urls.dart';
import 'package:http/http.dart' as http;

class MedidasMethods {
  Future<void> createMedidas({
    required Medidas medidas,
    List<Uint8List>? pictures,
  }) async {
    var uri = Uri.parse(medidasUrl);
    var request = http.MultipartRequest('POST', uri);

    // Función auxiliar para añadir campos si no están vacíos
    void addFieldIfNotEmpty(String fieldName, String? value) {
      if (value?.isNotEmpty ?? false) {
        request.fields[fieldName] = value!;
      }
    }

    // Añadir campos condicionalmente
    addFieldIfNotEmpty('user_id', medidas.userId?.toString());
    addFieldIfNotEmpty('left_arm', medidas.leftArm?.toString());
    addFieldIfNotEmpty('right_arm', medidas.rightArm?.toString());
    addFieldIfNotEmpty('shoulders', medidas.shoulders?.toString());
    addFieldIfNotEmpty('neck', medidas.neck?.toString());
    addFieldIfNotEmpty('chest', medidas.chest?.toString());
    addFieldIfNotEmpty('waist', medidas.waist?.toString());
    addFieldIfNotEmpty('upper_left_leg', medidas.upperLeftLeg?.toString());
    addFieldIfNotEmpty('upper_right_leg', medidas.upperRightLeg?.toString());
    addFieldIfNotEmpty('left_calve', medidas.leftCalve?.toString());
    addFieldIfNotEmpty('right_calve', medidas.rightCalve?.toString());
    addFieldIfNotEmpty('weight', medidas.weight?.toString());
    addFieldIfNotEmpty('left_forearm', medidas.leftForearm?.toString());
    addFieldIfNotEmpty('right_forearm', medidas.rightForearm?.toString());
    addFieldIfNotEmpty('timestamp', medidas.timestamp?.toIso8601String());

    // Añade las imágenes si existen
    if (pictures != null && pictures.isNotEmpty) {
      for (var i = 0; i < pictures.length; i++) {
        var picture = pictures[i];
        var pictureStream = http.ByteStream(Stream.value(picture));
        var pictureLength = picture.length;
        var multipartFile = http.MultipartFile(
          'pictures', // Usar 'picture[]' para indicar un arreglo
          pictureStream,
          pictureLength,
          filename: 'medida_picture_$i.jpg',
        );
        request.files.add(multipartFile);
      }
    }

    // Enviar el request
    var response = await request.send();

    if (response.statusCode != 201) {
      throw Exception('Error al crear medidas: ${response.statusCode}');
    }
  }

  Future<bool> deleteMedidas(int medidaId) async {
    var uri = Uri.parse('$medidasUrl/$medidaId');
    var response = await http.delete(uri);

    if (response.statusCode != 200) {
      throw Exception('Error al eliminar medidas: ${response.statusCode}');
    } else {
      return true;
    }
  }

  Future<List<Medidas>> getAllMedidas(int userId) async {
    var uri = Uri.parse('$medidasUrl/$userId');
    var response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body) as List;
      return jsonData.map((e) => Medidas.fromJson(e)).toList();
    } else if (response.statusCode == 204) {
      return [];
    } else {
      throw Exception('Error al obtener medidas: ${response.statusCode}');
    }
  }

  Future<void> updateMedidas({
    required Medidas medidas,
    List<Uint8List>? pictures,
  }) async {
    var uri = Uri.parse('$medidasUrl/${medidas.measurementId}');
    var request = http.MultipartRequest('PUT', uri);

    // Función auxiliar para añadir campos si no están vacíos
    void addFieldIfNotEmpty(String fieldName, String? value) {
      if (value?.isNotEmpty ?? false) {
        request.fields[fieldName] = value!;
      }
    }

    // Añadir campos condicionalmente
    addFieldIfNotEmpty('user_id', medidas.userId.toString());
    addFieldIfNotEmpty('left_arm', medidas.leftArm?.toString());
    addFieldIfNotEmpty('right_arm', medidas.rightArm?.toString());
    addFieldIfNotEmpty('left_forearm', medidas.leftForearm?.toString());
    addFieldIfNotEmpty('right_forearm', medidas.rightForearm?.toString());
    addFieldIfNotEmpty('shoulders', medidas.shoulders?.toString());
    addFieldIfNotEmpty('neck', medidas.neck?.toString());
    addFieldIfNotEmpty('chest', medidas.chest?.toString());
    addFieldIfNotEmpty('waist', medidas.waist?.toString());
    addFieldIfNotEmpty('upper_left_leg', medidas.upperLeftLeg?.toString());
    addFieldIfNotEmpty('upper_right_leg', medidas.upperRightLeg?.toString());
    addFieldIfNotEmpty('left_calve', medidas.leftCalve?.toString());
    addFieldIfNotEmpty('right_calve', medidas.rightCalve?.toString());
    addFieldIfNotEmpty('weight', medidas.weight?.toString());
    addFieldIfNotEmpty('timestamp', medidas.timestamp?.toIso8601String());

    // Añade las imágenes si existen
    if (pictures != null && pictures.isNotEmpty) {
      for (var i = 0; i < pictures.length; i++) {
        var picture = pictures[i];
        var pictureStream = http.ByteStream(Stream.value(picture));
        var pictureLength = picture.length;
        var multipartFile = http.MultipartFile(
          'pictures',
          pictureStream,
          pictureLength,
          filename: 'medida_update_picture_$i.jpg',
        );
        request.files.add(multipartFile);
      }
    }

    // Enviar el request
    var response = await request.send();

    if (response.statusCode != 200) {
      throw Exception('Error al actualizar medidas: ${response.statusCode}');
    }
  }
}
