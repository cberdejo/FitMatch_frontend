// import 'package:flutter/material.dart';

// class ExpandableText extends StatefulWidget {
//   final String text;
//   final int maxLines;
//   final TextStyle? style;

//   const ExpandableText({
//     Key? key,
//     required this.text,
//     this.maxLines = 5,
//     this.style,
//   }) : super(key: key);

//   @override
//   ExpandableTextState createState() => ExpandableTextState();
// }

// class ExpandableTextState extends State<ExpandableText> {
//   bool isExpanded = false;
//   late TextPainter textPainter;
//   bool shouldShowButton = false;

//   @override
//   void initState() {
//     super.initState();
//     textPainter = TextPainter(
//       text: TextSpan(text: widget.text, style: widget.style),
//       textDirection: TextDirection.ltr,
//       maxLines: widget.maxLines,
//     );
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     textPainter.layout(maxWidth: MediaQuery.of(context).size.width - 40);
//     shouldShowButton = textPainter.didExceedMaxLines;
//     setState(
//         () {}); // Asegura que se actualice el estado si es necesario después de calcular shouldShowButton
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           widget.text,
//           maxLines: isExpanded ? null : widget.maxLines,
//           overflow: TextOverflow.clip,
//           style: widget.style,
//         ),
//         if (shouldShowButton)
//           Align(
//             alignment: Alignment.centerLeft,
//             child: TextButton(
//               onPressed: () => setState(() {
//                 isExpanded = !isExpanded;
//               }),
//               child: Text(
//                 isExpanded ? 'Ver menos' : 'Ver más',
//                 style: TextStyle(color: Theme.of(context).colorScheme.primary),
//               ),
//             ),
//           ),
//       ],
//     );
//   }
// }
