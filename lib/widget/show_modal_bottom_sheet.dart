import 'package:flutter/material.dart';

class CustomShowModalBottomSheet extends StatelessWidget {
  final Widget child;

  const CustomShowModalBottomSheet({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.9, // Ajusta la altura a casi toda la pantalla
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Container(
              width: MediaQuery.of(context).size.width *
                  0.1, // Usa un porcentaje del ancho de la pantalla
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }

  static void show(BuildContext context, Widget child) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return CustomShowModalBottomSheet(child: child);
      },
    );
  }
}
