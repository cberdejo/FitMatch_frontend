import 'package:fit_match/models/post.dart';
import 'package:fit_match/providers/get_jwt_token.dart';
import 'package:fit_match/utils/colors.dart';
import 'package:fit_match/utils/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:fit_match/services/trainer_posts_service.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class ViewTrainersScreen extends StatefulWidget {
  const ViewTrainersScreen({Key? key}) : super(key: key);

  @override
  State<ViewTrainersScreen> createState() => _ViewTrainersScreenState();
}

class _ViewTrainersScreenState extends State<ViewTrainersScreen> {
  List<Post> posts = [];
  @override
  void initState() {
    super.initState();

    initializePosts();
  }

  void initializePosts() async {
    try {
      String? token = await getToken(); // Obtén el token
      if (token != null) {
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);

        var newPosts = await getAllPosts(decodedToken['user']['user_id']);
        setState(() {
          posts = newPosts;
        });
      } else {
        // Manejar el caso de que no haya token
        print('No se encontró el token');
      }
    } catch (e) {
      // Manejar el error
      print('Error al cargar los posts: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor:
          width > webScreenSize ? webBackgroundColor : mobileBackgroundColor,
    );
  }
}
