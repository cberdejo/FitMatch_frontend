import 'package:fit_match/utils/utils.dart';
import 'package:fit_match/widget/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fit_match/utils/colors.dart';
import 'package:fit_match/utils/dimensions.dart';
import 'package:fit_match/widget/text_field_input.dart';
import 'package:fit_match/services/auth_service.dart';
import 'package:fit_match/screens/shared/register_screen.dart';
import 'package:fit_match/responsive/responsive_layout_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => ResponsiveLayout(token: token),
        ));
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
                    const Spacer(),
                    _buildLogo(),
                    const Spacer(),
                    _buildEmailTextField(),
                    const Spacer(),
                    _buildPasswordTextField(),
                    const Spacer(),
                    _buildLoginButton(),
                    const Spacer(),
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

/*
  EdgeInsets _getHorizontalPadding(BuildContext context) {
    return MediaQuery.of(context).size.width > webScreenSize
        ? EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width / 3)
        : const EdgeInsets.symmetric(horizontal: 32);
  }
*/
  Widget _buildTitle() => const Text(
        'Bienvenido a Fit-Match',
        style: TextStyle(
            fontSize: 24, fontWeight: FontWeight.bold, color: primaryColor),
      );

  Widget _buildLogo() => Image.asset(
        'assets/images/logo.png',
        color: primaryColor,
        height: 128,
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
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(' Registrate aquí',
                  style:
                      TextStyle(color: blueColor, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      );
}
