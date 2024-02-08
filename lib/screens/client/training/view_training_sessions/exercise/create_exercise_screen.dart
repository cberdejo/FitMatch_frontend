import 'package:flutter/material.dart';

class MiWidgetStateful extends StatefulWidget {
  @override
  _MiWidgetState createState() => _MiWidgetState();
}

class _MiWidgetState extends State<MiWidgetStateful> {
  // Aquí puedes declarar variables y propiedades específicas de tu widget

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Widget Stateful'),
      ),
      body: const Center(
        // Aquí va el contenido de tu widget
        child: Text('Hola, este es mi widget stateful'),
      ),
    );
  }
}
