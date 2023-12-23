import 'package:fit_match/utils/colors.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isLoading;
  final String text;
  final Color backgroundColor;
  final Color progressIndicatorColor;

  const CustomButton({
    Key? key,
    required this.onTap,
    this.isLoading = false,
    required this.text,
    this.backgroundColor = blueColor,
    this.progressIndicatorColor = primaryColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: double.infinity,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: ShapeDecoration(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(4))),
          color: backgroundColor,
        ),
        child: isLoading
            ? CircularProgressIndicator(color: progressIndicatorColor)
            : Text(text),
      ),
    );
  }
}
