import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:email_auth/email_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fit_match/utils/colors.dart';
import 'package:fit_match/utils/dimensions.dart';
import 'package:fit_match/utils/utils.dart';
import 'package:fit_match/widget/date_picker.dart';
import 'package:fit_match/widget/text_field_input.dart';
import 'package:fit_match/screens/shared/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _pswController = TextEditingController();
  final _usernameController = TextEditingController();
  final _dobController = TextEditingController();
  final _otpController = TextEditingController();

  final _emailAuth = EmailAuth(sessionName: "Fit-Match");
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  Uint8List? _image;

  @override
  void dispose() {
    _emailController.dispose();
    _pswController.dispose();
    _usernameController.dispose();
    _dobController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendOTP() async {
    bool result = await _emailAuth.sendOtp(
        recipientMail: _emailController.text, otpLength: 6);
    print(result ? "OTP sent successfully" : "Failed to send OTP");
  }

  Future<void> _verifyOTP() async {
    bool result = await _emailAuth.validateOtp(
        recipientMail: _emailController.text, userOtp: _otpController.text);
    if (result) {
      _signUpUser();
    }
  }

  Future<void> _signUpUser() async {
    setState(() => _isLoading = true);

    // Implement signup logic here

    setState(() => _isLoading = false);
  }

  Future<void> _selectImage() async {
    Uint8List? im = await pickImage(ImageSource.gallery);
    if (im != null) {
      setState(() => _image = im);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Container(
          padding: _getHorizontalPadding(context),
          width: double.infinity,
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildTitle(),
                  const SizedBox(height: 24),
                  _buildLogo(),
                  const SizedBox(height: 24),
                  _buildDescription(),
                  const SizedBox(height: 32),
                  _buildImageSelector(),
                  const SizedBox(height: 24),
                  _buildEmailTextField(),
                  const SizedBox(height: 24),
                  _buildPasswordTextField(),
                  const SizedBox(height: 24),
                  _buildUsernameTextField(),
                  const SizedBox(height: 24),
                  DatepickerWidget(controller: _dobController),
                  const SizedBox(height: 24),
                  _buildRegisterButton(),
                  const SizedBox(height: 12),
                  _buildLoginOption(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  EdgeInsets _getHorizontalPadding(BuildContext context) =>
      MediaQuery.of(context).size.width > webScreenSize
          ? EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width / 3)
          : const EdgeInsets.symmetric(horizontal: 32);

  Widget _buildTitle() => const Text(
        'Bienvenido a Fit-Match',
        style: TextStyle(
            fontSize: 24, fontWeight: FontWeight.bold, color: primaryColor),
      );

  Widget _buildLogo() => Image.asset(
        'assets/images/logo.png',
        color: primaryColor,
        height: 32,
      );

  Widget _buildDescription() => const Text(
        'Para empezar a usar Fit-Match, rellena los siguientes datos ',
        style: TextStyle(
            fontSize: 12, fontWeight: FontWeight.bold, color: primaryColor),
      );

  Widget _buildImageSelector() => Stack(
        children: [
          CircleAvatar(
            radius: 64,
            backgroundImage: _image != null
                ? MemoryImage(_image!)
                : Image.asset('assets/images/user_placeholder.png').image,
            backgroundColor: Colors.red,
          ),
          Positioned(
            left: 80,
            child: IconButton(
                onPressed: _selectImage, icon: const Icon(Icons.add_a_photo)),
          ),
        ],
      );

  Widget _buildEmailTextField() => TextFieldInput(
        textEditingController: _emailController,
        hintText: 'Escribe tu correo',
        textInputType: TextInputType.emailAddress,
        validator: (value) => value == null || value.isEmpty
            ? 'Por favor, ingresa tu correo'
            : null,
      );

  Widget _buildPasswordTextField() => TextFieldInput(
        textEditingController: _pswController,
        hintText: 'Escribe tu contraseña',
        textInputType: TextInputType.text,
        isPsw: true,
        validator: (value) => value == null || value.isEmpty
            ? 'Por favor, ingresa tu contraseña'
            : null,
      );

  Widget _buildUsernameTextField() => TextFieldInput(
        textEditingController: _usernameController,
        hintText: 'Escribe tu nombre de usuario',
        textInputType: TextInputType.text,
        validator: (value) => value == null || value.isEmpty
            ? 'Por favor, ingresa tu nombre de usuario'
            : null,
      );

  Widget _buildRegisterButton() => InkWell(
        onTap: _sendOTP,
        child: Container(
          width: double.infinity,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: const ShapeDecoration(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(4))),
            color: blueColor,
          ),
          child: _isLoading
              ? const CircularProgressIndicator(color: primaryColor)
              : const Text('Registrarse'),
        ),
      );

  Widget _buildLoginOption(BuildContext context) => Wrap(
        spacing: 100,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('¿Ya tienes cuenta?'),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const LoginScreen())),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(' Iniciar sesión',
                  style:
                      TextStyle(color: blueColor, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      );
}
