import 'package:fit_match/models/post.dart';
import 'package:fit_match/providers/get_jwt_token.dart';
import 'package:fit_match/utils/colors.dart';
import 'package:fit_match/utils/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:fit_match/services/trainer_posts_service.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:fit_match/widget/post_card/post_card.dart';

class ViewTrainersScreen extends StatefulWidget {
  const ViewTrainersScreen({Key? key}) : super(key: key);

  @override
  State<ViewTrainersScreen> createState() => _ViewTrainersScreenState();
}

class _ViewTrainersScreenState extends State<ViewTrainersScreen> {
  List<Post> posts = [];
  bool isLoading = false; // Inicializar como falso para el estado inicial
  bool hasMore = true;
  int currentPage = 1;
  int pageSize = 10;
  int userId = 0;
  int clientId = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_loadMorePostsOnScroll);
    loadMorePosts();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadMorePostsOnScroll() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !isLoading) {
      loadMorePosts();
    }
  }

  Future<void> loadMorePosts() async {
    if (!hasMore || isLoading) return;

    setState(() => isLoading = true);

    try {
      String? token = await getToken();
      if (token != null) {
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        userId = decodedToken['user']['user_id'];
        clientId = decodedToken['user']['client_id'];
        var newPosts =
            await getAllPosts(userId, page: currentPage, pageSize: pageSize);
        if (mounted) {
          setState(() {
            if (newPosts.isNotEmpty) {
              currentPage++;
              posts.addAll(newPosts);
            } else {
              hasMore = false;
            }
            isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() => isLoading = false);
        }
        print('No se encontró el token');
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
      }
      print('Error al cargar los posts: $e');
      setState(() {
        hasMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            width > webScreenSize ? webBackgroundColor : mobileBackgroundColor,
        title: const Text("Filtros por terminar"),
      ),
      body: Container(
        color:
            width > webScreenSize ? webBackgroundColor : mobileBackgroundColor,
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: ListView.builder(
            itemCount: posts.length + (hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == posts.length) {
                return hasMore
                    ? const Center(child: CircularProgressIndicator())
                    : const Text("Estás al día");
              }
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                child: PostCard(
                    post: posts[index], userId: userId, clientId: clientId),
              );
            },
            controller: _scrollController,
          ),
        ),
      ),
    );
  }
}
