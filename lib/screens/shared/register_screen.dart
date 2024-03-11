import 'package:fit_match/models/user.dart';
import 'package:fit_match/responsive/responsive_layout_screen.dart';
import 'package:fit_match/widget/edit_Icon.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fit_match/utils/colors.dart';
import 'package:fit_match/services/auth_service.dart';

import 'package:fit_match/utils/utils.dart';
import 'package:fit_match/widget/date_picker.dart';
import 'package:fit_match/widget/text_field_input.dart';
import 'package:fit_match/screens/shared/login_screen.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  //form
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _pswController = TextEditingController();
  final _verifyPswController = TextEditingController();
  final _usernameController = TextEditingController();
  final _dobController = TextEditingController();
  final _otpController = TextEditingController();

  SharedPreferences? _preferences;
  bool _isLoading = false;
  Uint8List? _image;
  int _currentStep = 0; //stepper

  @override
  void dispose() {
    _emailController.dispose();
    _pswController.dispose();
    _verifyPswController.dispose();
    _usernameController.dispose();
    _dobController.dispose();
    _otpController.dispose();

    super.dispose();
  }

  //async
  Future<bool> _sendOTP() async {
    showToast(context, 'Mire en su bandeja de entrada');
    return true; //se envia el OTP no esta implementado
  }

  Future<void> _verifyOTP() async {
    bool isOtpValid = true; // no implementado
    if (!isOtpValid) {
      // Manejar el caso de OTP inválido.
      showToast(context, 'OTP inválido', exitoso: false);
      setState(() => _isLoading = false); // Asegúrate de detener la carga aquí.
      return;
    }
    // Si el OTP es válido, procede al registro.
    await _signUpUser();
  }

  Future<void> _signUpUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        // Convertir las preferencias en objetos Emparejamiento

        // Llamar al servicio de creación de usuario
        String result = await AuthMethods().createUsuario(
          username: _usernameController.text,
          email: _emailController.text,
          password: _pswController.text,
          profileId: 2, //2 es el profile del cliente
          birth: _dobController.text,
          profilePicture: _image,
        );

        // Navegar a la pantalla de inicio  mostrar un mensaje de éxito

        if (result == AuthMethods.successMessage) {
          await _autoLogin();
        } else {
          print("Error de autenticación: $result");
        }
      } catch (e) {
        print('Error al crear el usuario: $e');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _autoLogin() async {
    setState(() => _isLoading = true);
    try {
      String loginResult = await AuthMethods().loginUser(
        email: _emailController.text,
        password: _pswController.text,
      );

      if (loginResult == AuthMethods.successMessage) {
        _navigateToHome();
      } else {
        print("Error de autenticación: $loginResult");
      }
    } catch (error) {
      print("Error inesperado: $error");
    } finally {
      setState(() => _isLoading =
          false); // Detén la carga después de la operación de inicio de sesión.
    }
  }

  void _navigateToHome() {
    final token = _preferences!.getString('token');

    if (token != null) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      if (decodedToken.containsKey('user')) {
        User user = User.fromJson(decodedToken['user']);
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => ResponsiveLayout(
            user: user,
          ),
        ));
      }
    }
  }

  Future<void> _initSharedPreferences() async {
    _preferences = await SharedPreferences.getInstance();
  }

  Future<void> _selectImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      Uint8List im = await image.readAsBytes();
      setState(() {
        _image = im;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _initSharedPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Redirigir al login al presionar el botón de retroceso
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
        return false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(title: _buildLoginOption(context)),
        body: SafeArea(
          child: Theme(
            data: Theme.of(context).copyWith(
              primaryColor: Theme.of(context).colorScheme.primary,
            ),
            child: Form(
              key: _formKey,
              child: Stepper(
                type: StepperType.horizontal,
                currentStep: _currentStep,
                onStepContinue: () async {
                  if (_currentStep < _buildSteps().length) {
                    if (_currentStep == 0) {
                      if (_formKey.currentState!.validate()) {
                        await _sendOTP();

                        setState(() => _currentStep += 1);
                      }
                    } else if (_currentStep == 1) {
                      if (_otpController.text.length == 4) {
                        await _verifyOTP();
                      }
                    }
                  }
                },
                onStepCancel: _currentStep > 0
                    ? () => setState(() => _currentStep -= 1)
                    : () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const LoginScreen())),
                controlsBuilder:
                    (BuildContext context, ControlsDetails details) {
                  return Row(
                    children: <Widget>[
                      TextButton(
                        onPressed: details.onStepContinue,
                        child: _currentStep == 1
                            ? Text('Empezar en Fitmatch',
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary))
                            : Text('Continuar',
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary)),
                      ),
                      TextButton(
                        onPressed: details.onStepCancel,
                        child: Text('Atrás',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.primary)),
                      ),
                    ],
                  );
                },
                steps: _buildSteps(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Step> _buildSteps() {
    return [
      Step(
        title: const Text('Credenciales'),
        content: _buildUserDataStep(),
        isActive: _currentStep >= 0,
        state: _currentStep > 0 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text('Verificar correo'),
        content: _buildVerificationStep(),
        isActive: _currentStep >= 1,
        state: _currentStep > 1 ? StepState.complete : StepState.indexed,
      ),
    ];
  }

  Widget _buildUserDataStep() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildImageSelector(),
          const SizedBox(height: 24),
          _buildEmailTextField(),
          const SizedBox(height: 24),
          _buildPasswordTextField(),
          const SizedBox(height: 24),
          _buildVerifyPasswordTextField(),
          const SizedBox(height: 24),
          _buildUsernameTextField(),
          const SizedBox(height: 24),
          DatepickerWidget(controller: _dobController),
        ],
      ),
    );
  }

  Widget _buildVerificationStep() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Introduce el código OTP',
                border: OutlineInputBorder(),
              ),
              maxLength: 4,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
          ),
        ],
      ),
    );
  }

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
              child: EditIcon(
                icon: Icons.add_a_photo,
                color: Theme.of(context).colorScheme.primary,
                onTap: _selectImage,
              )
              // child: IconButton(
              //     onPressed: _selectImage, icon: const Icon(Icons.add_a_photo)),
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
  Widget _buildVerifyPasswordTextField() => TextFieldInput(
        textEditingController: _verifyPswController,
        hintText: 'Verifica tu contraseña',
        textInputType: TextInputType.text,
        isPsw: true,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor, verifica tu contraseña';
          }
          if (value != _pswController.text) {
            return 'Las contraseñas no coinciden';
          }
          return null;
        },
      );

  Widget _buildUsernameTextField() => TextFieldInput(
        textEditingController: _usernameController,
        hintText: 'Escribe tu nombre de usuario',
        textInputType: TextInputType.text,
        validator: (value) => value == null || value.isEmpty
            ? 'Por favor, ingresa tu nombre de usuario'
            : null,
      );

  Widget _buildLoginOption(BuildContext context) => Wrap(
        spacing: 25,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('¿Ya tienes cuenta?'),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const LoginScreen())),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(' Iniciar sesión',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      );
}
