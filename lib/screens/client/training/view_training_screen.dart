import 'package:fit_match/models/post.dart';
import 'package:fit_match/models/user.dart';
import 'package:fit_match/screens/client/training/info_plantilla_screen.dart';
import 'package:fit_match/services/plantilla_posts_service.dart';
import 'package:fit_match/utils/colors.dart';
import 'package:flutter/material.dart';

class ViewTrainingScreen extends StatefulWidget {
  final User user;
  const ViewTrainingScreen({super.key, required this.user});

  @override
  _ViewTrainingScreen createState() => _ViewTrainingScreen();
}

class _ViewTrainingScreen extends State<ViewTrainingScreen> {
  List<PlantillaPost> trainingTemplates = [];
  bool isLoading = false;
  bool hasMore = true;
  int currentPage = 1;
  int pageSize = 10;

  Future<void> loadTrainingTemplates() async {
    if (!hasMore || isLoading) return;

    setState(() => isLoading = true);

    try {
      var newTemplates = await RutinaMethods()
          .getPlantillas(widget.user.user_id, currentPage, pageSize);
      setState(() {
        if (newTemplates.isNotEmpty) {
          currentPage++;
          trainingTemplates.addAll(newTemplates);
          print(trainingTemplates.length);
        } else {
          hasMore = false;
        }
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        hasMore = false;
      });
      print('Error al cargar plantillas: $e');
    }
  }

  void _editTemplate(String templateName) {
    // Lógica para editar la plantilla
    print('Editar $templateName');
  }

  void _deleteTemplate(String templateName) async {}

  void _createNewTemplate() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
          builder: (context) => CreateProgramScreen(user: widget.user)),
    );
  }

  @override
  void initState() {
    super.initState();
    loadTrainingTemplates();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Plantillas'),
      ),
      body: ListView.builder(
        itemCount: trainingTemplates.length,
        itemBuilder: (context, index) {
          PlantillaPost template = trainingTemplates[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(template.templateName),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      _editTemplate(template as String);
                      break;
                    case 'delete':
                      _deleteTemplate(template as String);
                      break;
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'edit',
                    child: Text('Editar'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: Text('Eliminar'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewTemplate,
        backgroundColor: blueColor,
        child: const Icon(Icons.add),
      ),
    );
  }
}
