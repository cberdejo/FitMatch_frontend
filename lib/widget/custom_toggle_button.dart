import 'package:flutter/material.dart';

class CustomToggleButtons extends StatefulWidget {
  final List<String> titles;
  final Function(int) onToggle;
  final List<bool> initialSelection;

  const CustomToggleButtons({
    Key? key,
    required this.titles,
    required this.onToggle,
    required this.initialSelection,
  }) : super(key: key);

  @override
  CustomToggleButtonsState createState() => CustomToggleButtonsState();
}

class CustomToggleButtonsState extends State<CustomToggleButtons> {
  late List<bool> _selection;

  @override
  void initState() {
    super.initState();
    _selection = List.from(widget.initialSelection);
  }

  @override
  Widget build(BuildContext context) {
    return ToggleButtons(
      borderColor: Theme.of(context).colorScheme.onBackground,
      fillColor: Theme.of(context).colorScheme.primary,
      selectedBorderColor: Theme.of(context).colorScheme.onBackground,
      selectedColor: Theme.of(context).colorScheme.onPrimary,
      color: Theme.of(context).colorScheme.onBackground,
      borderRadius: BorderRadius.circular(8),
      //spacing: 4,
      isSelected: _selection,
      children: widget.titles
          .map((title) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(title),
              ))
          .toList(),
      onPressed: (int index) {
        setState(() {
          for (int i = 0; i < _selection.length; i++) {
            _selection[i] = i == index;
          }
        });
        widget.onToggle(index);
      },
    );
  }
}
