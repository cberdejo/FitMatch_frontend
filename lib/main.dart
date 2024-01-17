import 'package:fit_match/providers/pageState.dart';
import 'package:flutter/material.dart';
import 'package:fit_match/models/user.dart';
import 'package:fit_match/providers/get_jwt_token.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:fit_match/responsive/responsive_layout_screen.dart';
import 'package:fit_match/screens/shared/login_screen.dart';
import 'package:fit_match/utils/colors.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  String? token = await getToken(); // Obtener el token JWT

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => PageState()),
  ], child: MyApp(token: token)));
}

class MyApp extends StatelessWidget {
  final String? token;

  const MyApp({Key? key, this.token}) : super(key: key);
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
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: mobileBackgroundColor,
      ),
      home: token != null && JwtDecoder.isExpired(token!) == false
          ? ResponsiveLayout(user: user)
          : LoginScreen(),
    );
  }
}
