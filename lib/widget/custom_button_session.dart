import 'package:flutter/material.dart';

class CustomButtonSession extends StatefulWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;

  const CustomButtonSession({
    Key? key,
    required this.onTap,
    required this.text,
    required this.icon,
  }) : super(key: key);

  @override
  CustomButtonSessionState createState() => CustomButtonSessionState();
}

class CustomButtonSessionState extends State<CustomButtonSession> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (event) => setState(() => _isHovering = true),
      onExit: (event) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => widget.onTap(),
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            constraints: const BoxConstraints(maxWidth: 1000),
            width: _isHovering ? 320 : 300,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: ShapeDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: const StadiumBorder(),
            ),
            child: Wrap(children: [
              Icon(
                widget.icon,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              const SizedBox(width: 8),
              Text(
                widget.text,
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onPrimary),
              )
            ]),
          ),
        ),
      ),
    );
  }
}
