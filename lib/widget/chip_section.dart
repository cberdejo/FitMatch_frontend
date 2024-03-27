import 'package:flutter/material.dart';

Widget buildChipsSection(String? title, List<dynamic> chipsContent) {
  List<Widget> chips = [];

  // Itera sobre la lista dinámica y agrega un Chip solo para los elementos que son String
  for (var content in chipsContent) {
    if (content is String) {
      chips.add(Chip(
        label: Text(content),
      ));
    }
  }

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        title != null ? buildSectionTitle(title) : Container(),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: chips,
        ),
      ],
    ),
  );
}

Widget buildSectionTitle(String title) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
    ),
  );
}
