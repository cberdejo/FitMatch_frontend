import 'package:fit_match/models/user.dart';
import 'package:fit_match/responsive/mobile_layout.dart';
import 'package:fit_match/responsive/web_layout.dart';
import 'package:fit_match/utils/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class ResponsiveLayout extends StatefulWidget {
  final String token;

  const ResponsiveLayout({
    Key? key,
    required this.token,
  }) : super(key: key);

  @override
  State<ResponsiveLayout> createState() => _ResponsiveLayoutState();
}

class _ResponsiveLayoutState extends State<ResponsiveLayout> {
  late User user;
  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  // Método asincrónico para inicializar el usuario
  Future<void> _initializeUser() async {
    try {
      Map<String, dynamic> userData = JwtDecoder.decode(widget.token)['user'];
      user = User.fromJson(userData);
    } catch (e) {
      print("Error al inicializar el usuario: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > webScreenSize) {
        return user != null
            ? WebLayout(user: user)
            : _buildLoadingOrErrorWidget();
      }
      return mobileLayout(user: user);
    });
  }

  Widget _buildLoadingOrErrorWidget() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }
}
