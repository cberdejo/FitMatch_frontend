import 'package:fit_match/providers/get_jwt_token.dart';
import 'package:fit_match/responsive/responsive_layout_screen.dart';

import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import 'package:fit_match/screens/shared/login_screen.dart';

import 'package:fit_match/utils/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  String? token = await getToken(); // Usa la función getToken()
  runApp(MyApp(token: token));
}

class MyApp extends StatelessWidget {
  final String? token; // Asegúrate de especificar el tipo

  const MyApp({Key? key, required this.token}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fit-Match',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark()
          .copyWith(scaffoldBackgroundColor: mobileBackgroundColor),
      home: (token != null && !JwtDecoder.isExpired(token!))
          ? ResponsiveLayout(
              token: token!,
            )
          : const LoginScreen(),
    );
  }
}
