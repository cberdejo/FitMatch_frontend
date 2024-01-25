import 'package:fit_match/models/post.dart';
import 'package:fit_match/models/user.dart';
import 'package:fit_match/utils/colors.dart';
import 'package:fit_match/utils/dimensions.dart';
import 'package:fit_match/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:fit_match/services/plantilla_posts_service.dart';
import 'package:fit_match/widget/post_card/post_card.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class ViewTrainersScreen extends StatefulWidget {
  final User user;

  const ViewTrainersScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<ViewTrainersScreen> createState() => _ViewTrainersScreenState();
}

class _ViewTrainersScreenState extends State<ViewTrainersScreen> {
  List<PlantillaPost> posts = [];
  bool isLoading = false; // Inicializar como falso para el estado inicial
  bool hasMore = true;
  int currentPage = 1;
  int pageSize = 10;

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

// CARGA PEREZOSA
  void _loadMorePostsOnScroll() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !isLoading) {
      loadMorePosts();
    }
  }

  Future<void> loadMorePosts() async {
    // Si no hay más posts o ya está cargando, retorna.
    if (!hasMore || isLoading) return;

    // Inicia la carga de posts.
    _setLoadingState(true);

    try {
      // Obtener nuevos posts.
      var newPosts = await PlantillaPostsMethods()
          .getAllPosts(page: currentPage, pageSize: pageSize);

      // Actualizar la lista de posts y el estado si el componente sigue montado.
      if (mounted) {
        _updatePostsList(newPosts);
      }
    } catch (e) {
      // En caso de error, actualiza el estado.
      _handleLoadingError(e);
    } finally {
      // Finalmente, asegura que se actualice el estado de carga.
      if (mounted) {
        _setLoadingState(false);
      }
    }
  }

  void _setLoadingState(bool loading) {
    setState(() => isLoading = loading);
  }

  Future<void> _handleRefresh() async {
    setState(() {
      currentPage = 1;
      hasMore = true;
      posts.clear();
    });
    await loadMorePosts();
  }

  void _updatePostsList(List<PlantillaPost> newPosts) {
    setState(() {
      if (newPosts.isNotEmpty) {
        currentPage++;
        posts.addAll(newPosts);
      } else {
        hasMore = false;
      }
    });
  }

  void _handleLoadingError(error) {
    setState(() {
      hasMore = false;
      showToast(context,
          "Ha surgido un error al cargar las rutinas, prueba a recargar la página",
          exitoso: false);
    });
    print(error);
  }

  //SCREEN

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor:
            width > webScreenSize ? webBackgroundColor : mobileBackgroundColor,
        title: const Text("Filtros por terminar"),
      ),
      body: Container(
        color:
            width > webScreenSize ? webBackgroundColor : mobileBackgroundColor,
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: LiquidPullToRefresh(
            onRefresh: _handleRefresh,
            backgroundColor: mobileBackgroundColor,
            color: blueColor,
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
                      post: posts[index], userId: widget.user.user_id.toInt()),
                );
              },
              controller: _scrollController,
            ),
          ),
        ),
      ),
    );
  }
}
