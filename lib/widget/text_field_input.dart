import 'package:flutter/material.dart';

class TextFieldInput extends StatelessWidget {
  final TextEditingController textEditingController;
  final bool isPsw;
  final String hintText;
  final TextInputType textInputType;
  final bool maxLine;
  final String? Function(String?)? validator;

  const TextFieldInput(
      {Key? key,
      required this.textEditingController,
      this.isPsw = false,
      required this.hintText,
      required this.textInputType,
      this.maxLine = false,
      this.validator})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final inputBorder = OutlineInputBorder(
      borderSide: Divider.createBorderSide(context),
    );

    return TextFormField(
      controller: textEditingController,
      decoration: InputDecoration(
        hintText: hintText,
        border: inputBorder,
        focusedBorder: inputBorder,
        enabledBorder: inputBorder,
        filled: true,
        contentPadding: const EdgeInsets.all(8),
      ),
      maxLines: maxLine ? null : 1,
      keyboardType: textInputType,
      obscureText: isPsw,
      validator: validator,
    );
  }
}
