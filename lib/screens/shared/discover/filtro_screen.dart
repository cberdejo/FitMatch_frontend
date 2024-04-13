import 'package:fit_match/utils/utils.dart';
import 'package:flutter/material.dart';

class FiltroScreen extends StatefulWidget {
  const FiltroScreen({super.key});

  @override
  FiltroScreenState createState() => FiltroScreenState();
}

class FiltroScreenState extends State<FiltroScreen> {
  List<String> selectedObjectives = [];
  List<String> selectedInterests = [];
  List<String> selectedExperiences = [];
  List<String> selectedEquipments = [];
  List<String> selectedDurations = [];

  _navigateBack(BuildContext context) {
    Navigator.pop(context, {
      'selectedObjectives': selectedObjectives,
      'selectedInterests': selectedInterests,
      'selectedExperiences': selectedExperiences,
      'selectedEquipments': selectedEquipments,
      'selectedDurations': selectedDurations,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Filtrar"),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              // Limpiar todos los filtros
              setState(() {
                selectedObjectives.clear();
                selectedInterests.clear();
                selectedExperiences.clear();
                selectedEquipments.clear();
                selectedDurations.clear();
              });
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          _buildCheckboxSection(
              "Objetivos", objetivosOptions, selectedObjectives),
          _buildCheckboxSection(
              "Intereses", interesesOptions, selectedInterests),
          _buildCheckboxSection(
              "Experiencia", experienciaCheckBox, selectedExperiences),
          _buildCheckboxSection(
              "Equipamiento", equipmentCheckBox, selectedEquipments),
          _buildCheckboxSection(
              "Duración", durationCheckBox, selectedDurations),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateBack(context),
        child: const Icon(Icons.check),
      ),
    );
  }

  Widget _buildCheckboxSection(
      String title, List<dynamic> options, List<String> selectedOptions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        ),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: options.map((option) {
            return ChoiceChip(
              label: Text(option.title),
              selected: selectedOptions.contains(option.title),
              onSelected: (bool selected) {
                setState(() {
                  if (selected) {
                    selectedOptions.add(option.title);
                  } else {
                    selectedOptions.remove(option.title);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
