import 'package:fit_match/models/user.dart';
import 'package:fit_match/screens/shared/change_password.dart';
import 'package:fit_match/utils/utils.dart';
import 'package:fit_match/widget/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fit_match/widget/text_field_input.dart';
import 'package:fit_match/services/auth_service.dart';
import 'package:fit_match/screens/shared/register_screen.dart';
import 'package:fit_match/responsive/responsive_layout_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _pswController = TextEditingController();
  bool _isLoading = false;
  SharedPreferences? _preferences;

  @override
  void initState() {
    super.initState();
    _initSharedPreference();
  }

  Future<void> _initSharedPreference() async {
    _preferences = await SharedPreferences.getInstance();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _pswController.dispose();
    super.dispose();
  }

  Future<void> _loginUser() async {
    setState(() => _isLoading = true);

    try {
      String result = await AuthMethods().loginUser(
        email: _emailController.text,
        password: _pswController.text,
      );

      if (result == AuthMethods.successMessage) {
        _navigateToHome();
      } else {
        print("Error de autenticación: $result");
        showToast(context, result, exitoso: false);
      }
    } catch (error) {
      print("Error inesperado: $error");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _navigateToHome() {
    if (_preferences != null) {
      final token = _preferences!.getString('token');
      if (token != null) {
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        if (decodedToken.containsKey('user')) {
          User user = User.fromJson(decodedToken['user']);

          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => ResponsiveLayout(
              user: user,
              initialPage: 0,
            ),
          ));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: getHorizontalPadding(context),
            width: double.infinity,
            child: ConstrainedBox(
              // Agregado para asegurar el tamaño mínimo
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              child: IntrinsicHeight(
                // Agregado para mantener el diseño vertical
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(flex: 2, child: Container()),
                    _buildTitle(),
                    const Spacer(flex: 1),
                    _buildLogo(),
                    const Spacer(flex: 1),
                    _buildEmailTextField(),
                    const Spacer(flex: 1),
                    _buildPasswordTextField(),
                    const Spacer(flex: 1),
                    _buildLoginButton(),
                    _buildForgottenPassword(),
                    const Spacer(flex: 1),
                    _buildRegisterOption(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForgottenPassword() {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => const ForgotPasswordScreen())),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            '¿Olvidaste la contraseña?',
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() => const Text(
        'Bienvenido a Fit-Match',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      );

  Widget _buildLogo() => Image.asset(
        'assets/images/logo.png',
        height: 128,
        color: Theme.of(context).colorScheme.primary,
      );

  Widget _buildEmailTextField() => TextFieldInput(
        textEditingController: _emailController,
        hintText: 'Escribe tu correo',
        textInputType: TextInputType.emailAddress,
      );

  Widget _buildPasswordTextField() => TextFieldInput(
        textEditingController: _pswController,
        hintText: 'Escribe tu contraseña',
        textInputType: TextInputType.text,
        isPsw: true,
      );

  Widget _buildLoginButton() {
    return CustomButton(
        onTap: _loginUser, text: "Iniciar sesión", isLoading: _isLoading);
  }

  Widget _buildRegisterOption(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('¿No tienes cuenta?'),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const RegisterScreen())),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(' Registrate aquí',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary)),
              ),
            ),
          ),
        ],
      );
}
