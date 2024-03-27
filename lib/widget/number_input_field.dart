import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DoubleInputField extends StatelessWidget {
  final Function(String)? onFieldSubmitted;
  final String? hintText;
  final String? label;
  final TextEditingController? controller;

  const DoubleInputField({
    Key? key,
    this.onFieldSubmitted,
    this.hintText,
    this.controller,
    this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Estilo personalizado para el borde del campo de texto
    OutlineInputBorder borderStyle = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8), // Bordes redondeados
      borderSide: BorderSide(
        color: Colors.grey.shade300, // Color del borde
      ),
    );

    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      decoration: InputDecoration(
        border: borderStyle,
        labelText: label,
        enabledBorder: borderStyle,
        focusedBorder: borderStyle.copyWith(
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 2,
          ),
        ),
        errorBorder: borderStyle.copyWith(
          borderSide: const BorderSide(
            color: Colors.red,
          ),
        ),
        hintText: hintText,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
        filled: true,
        fillColor: Theme.of(context).colorScheme.background,
      ),
      textAlign: TextAlign.center,
      onChanged: onFieldSubmitted,
    );
  }
}

class IntInputField extends StatelessWidget {
  final Function(String) onFieldSubmitted;
  final String? hintText;
  final TextEditingController? controller;

  const IntInputField({
    Key? key,
    required this.onFieldSubmitted,
    this.hintText,
    this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Estilo personalizado para el borde del campo de texto
    OutlineInputBorder borderStyle = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8), // Bordes redondeados
      borderSide: BorderSide(
        color: Colors.grey.shade300, // Color del borde
      ),
    );

    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        border: borderStyle,
        enabledBorder: borderStyle,
        focusedBorder: borderStyle.copyWith(
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 2,
          ),
        ),
        errorBorder: borderStyle.copyWith(
          borderSide: const BorderSide(
            color: Colors.red,
          ),
        ),
        hintText: hintText,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
        filled: true,
        fillColor: Theme.of(context).colorScheme.background,
      ),
      textAlign: TextAlign.center,
      onChanged: onFieldSubmitted,
    );
  }
}
