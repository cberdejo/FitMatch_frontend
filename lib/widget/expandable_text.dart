import 'package:fit_match/utils/colors.dart';
import 'package:flutter/material.dart';

class ExpandableText extends StatefulWidget {
  final String text;
  final int maxLines;
  final TextStyle? style;
  const ExpandableText(
      {Key? key, required this.text, this.maxLines = 5, this.style})
      : super(key: key);

  @override
  _ExpandableTextState createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool isExpanded = false;
  late TextPainter textPainter;
  bool shouldShowButton = false;

  @override
  void initState() {
    super.initState();
    // Inicializar textPainter aquí sin el maxWidth
    textPainter = TextPainter(
      text: TextSpan(text: widget.text),
      textDirection: TextDirection.ltr,
      maxLines: widget.maxLines,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Llamar a layout con maxWidth aquí, donde MediaQuery está disponible
    textPainter.layout(maxWidth: MediaQuery.of(context).size.width);
    shouldShowButton = textPainter.didExceedMaxLines;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.text,
          maxLines: isExpanded ? null : widget.maxLines,
          overflow: TextOverflow.fade,
          style: widget.style,
        ),
        if (shouldShowButton)
          Row(
            children: [
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => setState(() {
                  isExpanded = !isExpanded;
                }),
                child: Text(
                  isExpanded ? 'Ver menos' : 'Ver más',
                  style: const TextStyle(color: blueColor),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
