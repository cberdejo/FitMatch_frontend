import 'dart:convert';
import 'package:fit_match/utils/backendUrls.dart';
import 'package:http/http.dart' as http;
import 'package:fit_match/models/post.dart'; // Asegúrate de importar tu clase Post

Future<List<Post>> getAllPosts(num userId,
    {int page = 1, int pageSize = 10}) async {
  final String url = "$trainerPostsUrl/$userId?page=$page&pageSize=$pageSize";

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final List<dynamic> jsonData = json.decode(response.body) as List;

    List<Post> posts =
        jsonData.map((jsonItem) => Post.fromJson(jsonItem)).toList();

    return posts;
  } else {
    throw Exception(
        'Error al obtener los posts. Código de estado: ${response.statusCode}');
  }
}
