import 'package:fit_match/models/post.dart';
import 'package:fit_match/models/user.dart';
import 'package:fit_match/screens/client/training/view_training_sessions/info_plantilla_screen.dart';
import 'package:fit_match/services/plantilla_posts_service.dart';
import 'package:fit_match/utils/utils.dart';

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

  void _publicar(PlantillaPost template) async {
    try {
      final bool exito =
          await PlantillaPostsMethods().togglePublico(template.templateId);
      if (exito) {
        setState(() {
          template.public = !template.public;
        });
        String mssg = template.public
            ? 'La plantilla de entrenamiento es ahora publica'
            : 'La plantilla de entrenamiento es ahora privada';
        showToast(context, mssg);
      } else {
        showToast(context, 'Error al publicar la plantilla');
      }
    } catch (e) {
      showToast(context, 'Error al publicar la plantilla');
    }
  }

  void _archivarTemplate(num templateId) async {
    try {
      final bool exito = await PlantillaPostsMethods()
          .archivar(templateId, widget.user.user_id);
      if (exito) {
        showToast(context, 'Plantilla archivada correctamente');
        _loadTrainingTemplates();
      }
    } catch (e) {
      showToast(context, 'Error al archivar la plantilla', exitoso: false);
    }
  }

  void _guardar_en_activados(num templateId) async {
    try {
      final bool exito = await PlantillaPostsMethods()
          .guardar(templateId, widget.user.user_id);
      if (exito) {
        showToast(context, 'La plantilla de entrenamiento está activa');
        _loadTrainingTemplates();
      }
    } catch (e) {
      showToast(context, 'Error al guardar la plantilla', exitoso: false);
    }
  }

  void _delete(num templateId, String option) async {
    try {
      final bool exito =
          await PlantillaPostsMethods().toggleHidden(templateId, option);
      if (!exito) {
        showToast(context, 'Error al borrar la plantilla');
        return;
      }
      showToast(context, 'Plantilla borrada correctamente');

      final Map<String, List<PlantillaPost>> optionsMap = {
        'creados': createdTrainingTemplates,
        'guardadas': trainingTemplates,
        'archivadas': arhivedTrainingTemplates,
      };

      setState(() {
        optionsMap[option]
            ?.removeWhere((element) => element.templateId == templateId);
      });
    } catch (e) {
      showToast(context, 'Ocurrió un error durante la eliminación',
          exitoso: false);
      print('Error al eliminar la plantilla: $e');
    }
  }

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
        itemBuilder: (BuildContext context) =>
            _buildPopupMenuItems(tipo, template),
      ),
    );
  }

  List<PopupMenuEntry<String>> _buildPopupMenuItems(
      String tipo, PlantillaPost template) {
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
        String labelPublic = template.picture == null || !template.public
            ? 'Publicar'
            : 'Hacer privado';
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
          PopupMenuItem<String>(
              value: 'publicar',
              child: Text(labelPublic,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.background)))
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
          PopupMenuItem<String>(
              value: 'activar',
              child: Text('Activar',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.background))),
        ];
    }
    return [];
  }

  void _handleMenuItemSelected(String value, PlantillaPost template) {
    switch (value) {
      case 'archivar':
        _archivarTemplate(template.templateId);
        break;
      case 'publicar':
        _publicar(template);
      case 'mas':
        // Acción para 'Ver más'
        break;
      case 'edit':
        _editTemplate(template);
        break;

      case 'activar':
        _guardar_en_activados(template.templateId);
        break;
      case 'delete_creados':
        _delete(template.templateId, 'creados');
        break;
      case 'delete_archivados':
        _delete(template.templateId, 'archivadas');
        break;

      case 'delete_guardados':
        _delete(template.templateId, 'guardadas');
        break;
    }
  }
}
