import 'package:flutter/material.dart';

class CardOption extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final double iconSize;
  final Color iconColor;
  final Function()? onTap;

  const CardOption({
    Key? key,
    required this.title,
    required this.description,
    required this.icon,
    this.iconSize = 24.0,
    this.iconColor = Colors.white,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color primaryColor = Theme.of(context).colorScheme.primaryContainer;
    Color lighterColor =
        Color.lerp(primaryColor, Colors.white, 0.3) ?? primaryColor;
    Color darkerColor =
        Color.lerp(primaryColor, Colors.black, 0.2) ?? primaryColor;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 150.0,
          margin: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(10.0)),
              gradient: LinearGradient(
                  colors: [lighterColor, darkerColor],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  tileMode: TileMode.clamp)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                child: CircleAvatar(
                  radius: 35.0,
                  backgroundColor: Theme.of(context).colorScheme.background,
                  child: Icon(
                    icon,
                    size: iconSize,
                    color: iconColor,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: TextStyle(
                          fontSize: 20.0,
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      description,
                      style: TextStyle(
                          fontSize: 12.0,
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
