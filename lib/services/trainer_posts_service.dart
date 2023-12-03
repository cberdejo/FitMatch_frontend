import 'dart:convert';
import 'package:fit_match/utils/backendUrls.dart';
import 'package:http/http.dart' as http;
import 'package:fit_match/models/post.dart'; // Asegúrate de importar tu clase Post

Future<List<Post>> getAllPosts(num userId) async {
  final response = await http.get(Uri.parse("$trainerPostsUrl/$userId"));

  if (response.statusCode == 200) {
    // Si la solicitud fue exitosa, decodifica el JSON
    final List<dynamic> jsonData = json.decode(response.body) as List;

    // Convierte cada elemento del JSON en un objeto Post
    List<Post> posts =
        jsonData.map((jsonItem) => Post.fromJson(jsonItem)).toList();

    return posts;
  } else {
    // Si la solicitud no fue exitosa, lanza una excepción o maneja el error
    throw Exception(
        'Error al obtener los posts. Código de estado: ${response.statusCode}');
  }
}
