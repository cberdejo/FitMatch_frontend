import 'package:fit_match/models/post.dart';
import 'package:fit_match/models/user.dart';
import 'package:fit_match/screens/client/training/info_plantilla_screen.dart';
import 'package:fit_match/services/plantilla_posts_service.dart';
import 'package:fit_match/utils/colors.dart';

import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class ViewTrainingScreen extends StatefulWidget {
  final User user;
  const ViewTrainingScreen({super.key, required this.user});

  @override
  _ViewTrainingScreen createState() => _ViewTrainingScreen();
}

class _ViewTrainingScreen extends State<ViewTrainingScreen> {
  List<PlantillaPost> trainingTemplates = [];
  List<PlantillaPost> createdTrainingTemplates = [];
  List<PlantillaPost> arhivedTrainingTemplates = [];
  bool isLoading = false;

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
              user: widget.user, editingTemplate: template)),
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

  void _verMas() {}
  void _createNewTemplate() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
          builder: (context) => CreateProgramScreen(user: widget.user)),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadTrainingTemplates();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Plantillas de entrenamiento'),
          bottom: const TabBar(
            indicatorColor: blueColor,
            labelColor: blueColor,
            unselectedLabelColor: primaryColor,
            tabs: [
              Tab(text: 'Activas'),
              Tab(text: 'Creadas'),
              Tab(text: 'Archivadas'),
            ],
          ),
        ),
        body: SafeArea(
          child: TabBarView(children: [
            _buildProgramList(context, 'Activos'),
            _buildProgramList(context, 'Creados'),
            _buildProgramList(context, 'Archivados'),
          ]),
        ),
      ),
    );
  }

  Widget _buildProgramList(
    BuildContext context,
    String tipo,
  ) {
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
      backgroundColor: mobileBackgroundColor,
      color: blueColor,
      child: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
            child: Text(tipo,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: primaryColor)),
          ),
          ...lista.map((template) => _buildListItem(template, tipo)).toList(),
          if (tipo == 'Creados')
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: FloatingActionButton(
                  onPressed: _createNewTemplate,
                  backgroundColor: blueColor,
                  child: const Icon(Icons.add),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildListItem(PlantillaPost template, String tipo) {
    return GestureDetector(
      onTap: () {
        if (tipo == "Creados" || tipo == "Archivados") {
          _verMas();
        }
      },
      child: Card(
        margin: const EdgeInsets.all(8.0),
        child: ListTile(
          title: Text(template.templateName,
              style: const TextStyle(color: primaryColor)),
          trailing: PopupMenuButton<String>(
            iconColor: primaryColor,
            color: mobileSearchColor,
            onSelected: (value) => _handleMenuItemSelected(value, template),
            itemBuilder: (BuildContext context) => _buildPopupMenuItems(tipo),
          ),
        ),
      ),
    );
  }

  List<PopupMenuEntry<String>> _buildPopupMenuItems(String tipo) {
    switch (tipo) {
      case "Activos":
        return [
          const PopupMenuItem<String>(
              value: 'archivar',
              child: Text('Archivar', style: TextStyle(color: primaryColor))),
          const PopupMenuItem<String>(
              value: 'mas',
              child: Text('Ver más', style: TextStyle(color: primaryColor))),
          const PopupMenuItem<String>(
              value: 'delete_guardados',
              child: Text('Eliminar', style: TextStyle(color: primaryColor))),
        ];
      case "Creados":
        return [
          const PopupMenuItem<String>(
              value: 'edit',
              child: Text('Editar', style: TextStyle(color: primaryColor))),
          const PopupMenuItem<String>(
              value: 'delete_creados',
              child: Text('Eliminar', style: TextStyle(color: primaryColor))),
        ];
      case "Archivados":
        return [
          const PopupMenuItem<String>(
              value: 'mas',
              child: Text('Ver más', style: TextStyle(color: primaryColor))),
          const PopupMenuItem<String>(
              value: 'delete_archivados',
              child: Text('Eliminar', style: TextStyle(color: primaryColor))),
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
