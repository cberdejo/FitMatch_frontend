import 'package:flutter/material.dart';

class StarDisplay extends StatelessWidget {
  final num value;
  final double size;

  const StarDisplay({Key? key, required this.value, required this.size})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        // Determinar el tipo de icono para cada estrella
        if (index < value.floor()) {
          // Estrella completa
          return Icon(Icons.star, size: size, color: Colors.amber);
        } else if (index < value) {
          // Media estrella
          return Icon(Icons.star_half, size: size, color: Colors.amber);
        } else {
          // Estrella vacía
          return Icon(Icons.star_border, size: size, color: Colors.amber);
        }
      }),
    );
  }
}
