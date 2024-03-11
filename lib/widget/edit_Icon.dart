import 'package:flutter/material.dart';

class EditIcon extends StatelessWidget {
  final Color color;
  final VoidCallback onTap;
  final IconData icon;
  const EditIcon({
    Key? key,
    required this.color,
    required this.onTap,
    this.icon = Icons.edit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: _buildEditIcon(color, icon: icon),
      ),
    );
  }
}

Widget _buildEditIcon(Color color, {IconData icon = Icons.edit}) =>
    _buildCircle(
      color: Colors.white,
      all: 3,
      child: _buildCircle(
        color: color,
        all: 8,
        child: Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
      ),
    );

Widget _buildCircle({
  required Widget child,
  required double all,
  required Color color,
}) =>
    ClipOval(
      child: Container(
        padding: EdgeInsets.all(all),
        color: color,
        child: child,
      ),
    );
