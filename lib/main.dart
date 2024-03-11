import 'package:fit_match/providers/pageState.dart';
import 'package:fit_match/providers/theme_provider.dart';

import 'package:flutter/material.dart';
import 'package:fit_match/models/user.dart';
import 'package:fit_match/providers/get_jwt_token.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:fit_match/responsive/responsive_layout_screen.dart';
import 'package:fit_match/screens/shared/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  String? token = await getToken(); // Obtener el token JWT
  await ThemeProvider.instance.changeTheme(ThemeEnum.Light);
  initializeDateFormatting('es_ES', null);
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => PageState()),
    ChangeNotifierProvider(create: (_) => ThemeProvider.instance),
  ], child: MyApp(token: token, theme: ThemeData())));
}

class MyApp extends StatelessWidget {
  final String? token;
  final ThemeData theme;

  const MyApp({Key? key, this.token, required this.theme}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    User user = User(
        user_id: 0,
        username: '',
        email: '',
        password: '',
        profile_picture: '',
        birth: DateTime.now(),
        profile_id: 0,
        public: false);

    // Verificación del token y asignación de los datos del usuario
    if (token != null && JwtDecoder.isExpired(token!) == false) {
      try {
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token!);

        if (decodedToken.containsKey('user')) {
          user = User.fromJson(decodedToken['user']);
        }
      } catch (e) {
        // Manejo de errores en caso de que la decodificación falle
        print('Error al decodificar el token: $e');
      }
    }

    return MaterialApp(
      title: 'Fit-Match',
      debugShowCheckedModeBanner: false,
      theme: Provider.of<ThemeProvider>(context).currentThemeData,
      home: token != null && JwtDecoder.isExpired(token!) == false
          ? ResponsiveLayout(user: user)
          : const LoginScreen(),
    );
  }
}
