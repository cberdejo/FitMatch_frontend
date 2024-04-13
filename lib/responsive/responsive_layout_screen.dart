import 'package:fit_match/models/user.dart';
import 'package:flutter/material.dart';
import 'package:fit_match/responsive/web_layout.dart';
import 'package:fit_match/utils/dimensions.dart';

import 'mobile_layout.dart';

class ResponsiveLayout extends StatefulWidget {
  final int initialPage;
  final User user;

  const ResponsiveLayout({Key? key, this.initialPage = 0, required this.user})
      : super(key: key);

  @override
  State<ResponsiveLayout> createState() => _ResponsiveLayoutState();
}

class _ResponsiveLayoutState extends State<ResponsiveLayout> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > webScreenSize) {
        return WebLayout(user: widget.user, initialPage: widget.initialPage);
      }

      return MobileLayout(user: widget.user, initialPage: widget.initialPage);
    });
  }
}
