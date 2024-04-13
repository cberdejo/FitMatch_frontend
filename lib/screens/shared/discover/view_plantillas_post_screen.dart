import 'dart:async';

import 'package:fit_match/models/post.dart';
import 'package:fit_match/models/user.dart';
import 'package:fit_match/screens/shared/discover/filtro_screen.dart';
import 'package:fit_match/utils/utils.dart';
import 'package:fit_match/widget/post_card/preview_post_card.dart';
import 'package:fit_match/widget/search_widget.dart';
import 'package:flutter/foundation.dart';
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

  //FILTROS
  Timer? _debounce;
  String filtroBusqueda = '';
  List<String> selectedObjectives = [];
  List<String> selectedInterests = [];
  List<String> selectedExperiences = [];
  List<String> selectedEquipments = [];
  List<String> selectedDurations = [];

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

  Future<void> loadMorePosts({bool isRefresh = false}) async {
    if (!hasMore || isLoading && !isRefresh) return;

    if (isRefresh) {
      setState(() {
        currentPage = 1;
        posts.clear();
      });
    }

    _setLoadingState(true);

    try {
      var newPosts = await PlantillaPostsMethods().getAllPosts(
        page: currentPage,
        pageSize: pageSize,
        name: filtroBusqueda,
        experiences: selectedExperiences,
        objectives: selectedObjectives,
        interests: selectedInterests,
        equipment: selectedEquipments,
        duration: selectedDurations,
        isPublic: true,
        isHidden: false,
      );

      if (mounted) {
        _updatePostsList(newPosts);
      }
    } catch (e) {
      if (mounted) _handleLoadingError(e);
    } finally {
      if (mounted) _setLoadingState(false);
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

  void _showPost(PlantillaPost post) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => PostCard(post: post, user: widget.user)));
  }

  //FILTROS

  void _onFilterApplied() {
    loadMorePosts(isRefresh: true);
  }

  int _countActiveFilters() {
    return selectedObjectives.length +
        selectedInterests.length +
        selectedExperiences.length +
        selectedEquipments.length +
        selectedDurations.length;
  }

  void _clearFilters() {
    setState(() {
      selectedObjectives.clear();
      selectedInterests.clear();
      selectedExperiences.clear();
      selectedEquipments.clear();
      selectedDurations.clear();
    });
    _onFilterApplied();

    // Opcional: Recargar los posts sin filtros aquí
  }

  void _onSearchChanged(String text) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          filtroBusqueda = text;
        });
        loadMorePosts(
            isRefresh: true); // Carga posts con el filtro actualizado.
      }
    });
  }

  void _showFilters() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => FiltroScreen()),
    );

    if (result != null) {
      setState(() {
        selectedObjectives = result['selectedObjectives'];
        selectedInterests = result['selectedInterests'];
        selectedExperiences = result['selectedExperiences'];
        selectedEquipments = result['selectedEquipments'];
        selectedDurations = result['selectedDurations'];
      });

      // Actualizar los posts con los filtros seleccionados
      _onFilterApplied();
    }
  }

  //SCREEN

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    Widget postList = ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: posts.length + (hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == posts.length) {
          return hasMore
              ? const Center(child: CircularProgressIndicator())
              : const Text("Estás al día");
        }
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 15.0),
          child: PreviewPostItem(
            post: posts[index],
            showPost: () => _showPost(posts[index]),
          ),
        );
      },
      controller: _scrollController,
    );
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Container(
          padding: const EdgeInsets.only(top: 10),
          child: Row(
            children: [
              Expanded(
                child: SearchWidget(
                  text: filtroBusqueda,
                  hintText: 'Buscar plantillas de ejercicio',
                  onChanged: (text) => _onSearchChanged(text),
                ),
              ),
              if (_countActiveFilters() <= 0)
                ElevatedButton(
                  onPressed: _showFilters,
                  child: const Text('Filtrar'),
                ),
              if (_countActiveFilters() > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: Theme.of(context).colorScheme.primaryContainer,
                  ),
                  child: Text(
                    'Filtros: ${_countActiveFilters() > 0 ? _countActiveFilters() : ''}',
                  ),
                ),
              if (_countActiveFilters() > 0)
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _clearFilters,
                ),
            ],
          ),
        ),
      ),
      body: kIsWeb
          ? postList
          : LiquidPullToRefresh(
              onRefresh: _handleRefresh, color: primary, child: postList),
    );
  }
}
