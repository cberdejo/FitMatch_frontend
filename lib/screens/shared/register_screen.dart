import 'package:fit_match/utils/colors.dart';
import 'package:fit_match/utils/dimensions.dart';
import 'package:fit_match/utils/utils.dart';

import 'package:fit_match/widget/date_picker.dart';
import 'package:fit_match/widget/text_field_input.dart';

import 'dart:typed_data';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:email_auth/email_auth.dart';
import 'package:image_picker/image_picker.dart';

//import 'package:fit_match/responsive/mobile_screen_layout.dart';
//import 'package:fit_match/responsive/responsive_layout_screen.dart';
//import 'package:fit_match/responsive/web_screen_layout.dart';


import 'package:fit_match/screens/shared/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pswController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  final EmailAuth emailAuth = EmailAuth(sessionName: "Fit-Match");
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  Uint8List? _image;

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _pswController.dispose();
    _usernameController.dispose();
    _dobController.dispose();
    _otpController.dispose();
  }

  void sendOTP() async {
    var res = await emailAuth.sendOtp(
        recipientMail: _emailController.text, otpLength: 6);
    if (res) {
      print("OTP sent successfully");
    } else {
      print("Failed to send OTP");
    }
  }

  void verifyOTP() async {
    var res = await emailAuth.validateOtp(
        recipientMail: _emailController.text, userOtp: _otpController.text);
    if (res) {
      signUpUser();
    } else {}
  }

  void signUpUser() async {
    // set loading to true
    setState(() {
      _isLoading = true;
    });

    // signup user using our back express

    // if string returned is sucess, user has been created
    /* if () {
      setState(() {
        _isLoading = false;
      });
      
      // navigate to the home screen
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const ResponsiveLayout(
              mobileScreenLayout: MobileScreenLayout(),
              webScreenLayout: WebScreenLayout(),
            ),
          ),
        );
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      // show the error
      if (context.mounted) {
        showSnackBar(context, res);
      }
    } */
  }

  selectImage() async {
    Uint8List? im = await pickImage(ImageSource.gallery);
    if (im != null) {
      setState(() {
        _image = im;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Container(
           padding: MediaQuery.of(context).size.width > webScreenSize
              ? EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width / 3)
              : const EdgeInsets.symmetric(horizontal: 32),
          width: double.infinity,
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                
                  const Text(
                    'Bienvenido a Fit-Match',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  Image.asset(
                    'assets/images/logo.png',
                    color: primaryColor,
                    height: 32,
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  const Text(
                    'Para empezar a usar Fit-Match, rellena los siguientes datos ',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(
                    height: 32,
                  ),
                  Stack(children: [
                    _image != null
                        ? CircleAvatar(
                            radius: 64,
                            backgroundImage: MemoryImage(_image!),
                            backgroundColor: Colors.red,
                          )
                        : CircleAvatar(
                            radius: 64,
                            backgroundImage: Image.asset(
                                    'assets/images/user_placeholder.png')
                                .image,
                            backgroundColor: Colors.red,
                          ),
                    Positioned(
                      left: 80,
                      child: IconButton(
                          onPressed: selectImage,
                          icon: const Icon(
                            Icons.add_a_photo,
                          )),
                    )
                  ]),
                  const SizedBox(
                    height: 24,
                  ),
                  TextFieldInput(
                    textEditingController: _emailController,
                    hintText: 'Escribe tu correo',
                    textInputType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingresa tu correo';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  TextFieldInput(
                    textEditingController: _pswController,
                    hintText: 'Escribe tu contraseña',
                    textInputType: TextInputType.text,
                    isPsw: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingresa tu contraseña';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  TextFieldInput(
                    textEditingController: _usernameController,
                    hintText: 'Escribe tu nombre de usuario',
                    textInputType: TextInputType.text,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingresa tu nombre de usuario';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  DatepickerWidget(
                    controller: _dobController,
                    //Validator
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  InkWell(
                    onTap: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        sendOTP();
                      }
                    },
                    child: Container(
                        width: double.infinity,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: const ShapeDecoration(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(4),
                            ),
                          ),
                          color: blueColor,
                        ),
                        child: !_isLoading
                            ? const Text(
                                'Registrarse',
                              )
                            : const CircularProgressIndicator(
                                color: primaryColor,
                              )),
                  ),
                  const SizedBox(
                    height: 12,
                  ),

                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: const Text(
                          '¿Ya tienes cuenta?',
                        ),
                      ),
                      GestureDetector(
                        onTap: () =>
                            Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        )),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: const Text(' Iniciar sesión',
                              style: TextStyle(
                                  color: blueColor,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
