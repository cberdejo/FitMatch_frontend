import 'package:fit_match/models/post.dart';
import 'package:fit_match/models/user.dart';
import 'package:fit_match/screens/client/training/view_training_sessions/info_plantilla_screen.dart';
import 'package:fit_match/services/plantilla_posts_service.dart';

import 'package:fit_match/widget/post_card/preview_post_card.dart';

import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class ViewTrainingScreen extends StatefulWidget {
  final User user;
  const ViewTrainingScreen({super.key, required this.user});

  @override
  _ViewTrainingScreen createState() => _ViewTrainingScreen();
}

class _ViewTrainingScreen extends State<ViewTrainingScreen>
    with SingleTickerProviderStateMixin {
  List<PlantillaPost> trainingTemplates = [];
  List<PlantillaPost> createdTrainingTemplates = [];
  List<PlantillaPost> arhivedTrainingTemplates = [];
  bool isLoading = false;
  late TabController _tabController;

  Future<void> _loadTrainingTemplates() async {
    if (isLoading) return;

    setState(() => isLoading = true);

    try {
      var resultados = await Future.wait([
        RutinaGuardadaMethods().getPlantillas(widget.user.user_id),
        PlantillaPostsMethods().getAllPosts(userId: widget.user.user_id),
        RutinasArchivadaMethods().getPlantillas(widget.user.user_id),
      ]);

      var newTemplates = resultados[0];
      var newCreatedTemplates = resultados[1];
      var newArchivedTemplates = resultados[2];

      if (mounted) {
        setState(() {
          trainingTemplates = newTemplates;
          createdTrainingTemplates = newCreatedTemplates;
          arhivedTrainingTemplates = newArchivedTemplates;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error al cargar plantillas: $e');
    }
  }

  void _editTemplate(PlantillaPost template) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
          builder: (context) => CreateProgramScreen(
              user: widget.user, templateId: template.templateId)),
    );
  }

  void _archivarTemplate(String templateName) {
    // Lógica para archivar la plantilla
    print('Archivar $templateName');
  }

  void _quitar_de_archivado(String templateName) {
    // Lógica para quitar de archivado la plantilla
    print('Quitar de archivado $templateName');
  }

  void _eliminar_de_archivados(String templateName) {}

  void _deleteTemplate(String templateName) async {}

  void _verMas(PlantillaPost template) {}
  void _createNewTemplate() {
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (context) => CreateProgramScreen(user: widget.user)),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadTrainingTemplates();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Plantillas de entrenamiento'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Activas'),
              Tab(text: 'Creadas'),
              Tab(text: 'Archivadas'),
            ],
          ),
        ),
        body: SafeArea(
          child: TabBarView(controller: _tabController, children: [
            _buildProgramList(context, 'Activos'),
            _buildProgramList(context, 'Creados'),
            _buildProgramList(context, 'Archivados'),
          ]),
        ),
        floatingActionButton: _tabController.index == 1
            ? FloatingActionButton(
                onPressed: _createNewTemplate,
                child: const Icon(Icons.add),
              )
            : null,
      ),
    );
  }

  Widget _buildProgramList(
    BuildContext context,
    String tipo,
  ) {
    final width = MediaQuery.of(context).size.width;
    List<PlantillaPost> lista = [];
    switch (tipo) {
      case "Activos":
        lista = trainingTemplates;
        break;
      case "Creados":
        lista = createdTrainingTemplates;
        break;
      case "Archivados":
        lista = arhivedTrainingTemplates;
        break;
    }

    return LiquidPullToRefresh(
      onRefresh: _loadTrainingTemplates,
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: ListView(
        children: [
          ...lista
              .map((template) => _buildListItem(width, template, tipo))
              .toList(),
          if (tipo == 'Creados')
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: FloatingActionButton(
                  onPressed: _createNewTemplate,
                  child: const Icon(Icons.add),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildListItem(double width, PlantillaPost template, String tipo) {
    return buildPostItem(
      template,
      width,
      showPost: () => tipo == 'Activos'
          ? _verMas(template)
          : (tipo == 'Creados' ? _editTemplate(template) : null),
      trailing: PopupMenuButton<String>(
        color: Theme.of(context).colorScheme.primary,
        onSelected: (value) => _handleMenuItemSelected(value, template),
        itemBuilder: (BuildContext context) => _buildPopupMenuItems(tipo),
      ),
    );
  }

  List<PopupMenuEntry<String>> _buildPopupMenuItems(String tipo) {
    switch (tipo) {
      case "Activos":
        return [
          PopupMenuItem<String>(
              value: 'archivar',
              child: Text('Archivar',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.background))),
          PopupMenuItem<String>(
              value: 'mas',
              child: Text('Ver más',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.background))),
          PopupMenuItem<String>(
              value: 'delete_guardados',
              child: Text('Eliminar',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.background))),
        ];
      case "Creados":
        return [
          PopupMenuItem<String>(
              value: 'edit',
              child: Text('Editar',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.background))),
          PopupMenuItem<String>(
              value: 'delete_creados',
              child: Text('Eliminar',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.background))),
        ];
      case "Archivados":
        return [
          PopupMenuItem<String>(
              value: 'mas',
              child: Text('Ver más',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.background))),
          PopupMenuItem<String>(
              value: 'delete_archivados',
              child: Text('Eliminar',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.background))),
        ];
    }
    return [];
  }

  void _handleMenuItemSelected(String value, PlantillaPost template) {
    switch (value) {
      case 'archivar':
        _archivarTemplate(template.templateName);
        break;
      case 'mas':
        // Acción para 'Ver más'
        break;
      case 'edit':
        _editTemplate(template);
        break;
      case 'delete':
        _deleteTemplate(template.templateName);
        break;
      // Agregar más casos según sea necesario...
    }
  }
}
