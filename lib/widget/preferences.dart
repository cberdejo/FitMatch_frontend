import 'package:flutter/material.dart';

// Base class for preferences
abstract class PreferenceOption<T> {
  Widget buildWidget(
      BuildContext context, T? currentValue, void Function(T?) onChanged);
}

// Specific class for checkbox behavior
class CheckboxPreference extends PreferenceOption<bool> {
  final String title;
  final bool value;

  CheckboxPreference({required this.title, this.value = false});

  @override
  Widget buildWidget(BuildContext context, bool? currentValue,
      void Function(bool?) onChanged) {
    return CheckboxListTile(
      title: Text(title),
      value:
          currentValue ?? false, // asegurándose de que currentValue no sea nulo
      onChanged: onChanged,
    );
  }
}

// Specific class for radio button behavior
class RadioPreference<T> extends PreferenceOption<T> {
  final String title;
  final T value;

  RadioPreference({required this.title, required this.value});

  @override
  Widget buildWidget(
      BuildContext context, T? currentValue, void Function(T?) onChanged) {
    return RadioListTile<T>(
      title: Text(title),
      value: value,
      groupValue: currentValue,
      onChanged: onChanged,
    );
  }
}

//CLASE USANDO CHECK BOX
class PreferencesCheckboxesWidget extends StatefulWidget {
  final List<CheckboxPreference> options;
  final Function(Map<String, bool>) onSelectionChanged;

  const PreferencesCheckboxesWidget({
    Key? key,
    required this.options,
    required this.onSelectionChanged,
  }) : super(key: key);

  @override
  _PreferencesCheckboxesWidgetState createState() =>
      _PreferencesCheckboxesWidgetState();
}

class _PreferencesCheckboxesWidgetState
    extends State<PreferencesCheckboxesWidget> {
  late Map<String, bool> _checkboxStates;

  @override
  void initState() {
    super.initState();
    _checkboxStates = {
      for (var option in widget.options) option.title: option.value
    };
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: widget.options.map((option) {
        return CheckboxListTile(
          title: Text(option.title),
          value: _checkboxStates[option.title],
          onChanged: (bool? newValue) {
            setState(() {
              _checkboxStates[option.title] = newValue!;
              widget.onSelectionChanged(_checkboxStates);
            });
          },
        );
      }).toList(),
    );
  }
}

//CLASE USANDO RADIO BUTTONS
class PreferencesRadioButtonsWidget<T> extends StatefulWidget {
  final List<RadioPreference<T>> options;
  final T initialValue;
  final Function(T) onSelectionChanged;

  const PreferencesRadioButtonsWidget({
    Key? key,
    required this.options,
    required this.initialValue,
    required this.onSelectionChanged,
  }) : super(key: key);

  @override
  _PreferencesRadioButtonsWidgetState<T> createState() =>
      _PreferencesRadioButtonsWidgetState<T>();
}

class _PreferencesRadioButtonsWidgetState<T>
    extends State<PreferencesRadioButtonsWidget<T>> {
  late T _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: widget.options.map((option) {
        return RadioListTile<T>(
          title: Text(option.title),
          value: option.value,
          groupValue: _currentValue,
          onChanged: (T? newValue) {
            setState(() {
              _currentValue = newValue as T;
              widget.onSelectionChanged(_currentValue);
            });
          },
        );
      }).toList(),
    );
  }
}
