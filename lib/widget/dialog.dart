import 'package:fit_match/utils/colors.dart';
import 'package:flutter/material.dart';

class CustomDialog extends StatelessWidget {
  final Widget child;
  final VoidCallback onClose;

  CustomDialog({required this.child, required this.onClose});

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    double dialogWidth = width > 600 ? 600 : width * 0.9;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topRight,
        children: [
          Container(
            width: dialogWidth,
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              // Envolver en un SingleChildScrollView
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  child,
                ],
              ),
            ),
          ),
          Positioned(
            top: -15.0,
            right: -15.0,
            child: CircleAvatar(
              backgroundColor: Colors.red,
              radius: 15,
              child: IconButton(
                icon: const Icon(Icons.close, size: 20.0, color: primaryColor),
                onPressed: onClose,
                padding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static void show(BuildContext context, Widget child, VoidCallback onClose) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomDialog(onClose: onClose, child: child);
      },
    );
  }
}
