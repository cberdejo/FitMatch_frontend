import 'package:fit_match/services/auth_service.dart';
import 'package:fit_match/utils/utils.dart';
import 'package:fit_match/widget/text_field_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);
  @override
  ForgotPasswordState createState() => ForgotPasswordState();
}

class ForgotPasswordState extends State<ForgotPasswordScreen> {
  final _formKeyEmail = GlobalKey<FormState>();
  final _formKeyPSW = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _password2Controller = TextEditingController();
  int _currentStep = 0;

  Future<bool> _checkMailDoesntExist() async {
    bool res =
        await UserMethods().userWithEmailDoesntExists(_emailController.text);
    return res;
  }

  Future<bool> _verifyOTP() async {
    bool isOtpValid = await OTPMethods().checkOtp(_otpController.text);
    return isOtpValid;
  }

  Future<bool> _sendOTP() async {
    bool exito = await OTPMethods().sendOTP(_emailController.text);
    if (exito) {
      showToast(context, 'Mire en su bandeja de entrada');
      return true;
    } else {
      showToast(context, 'Ha surgido un error, intentelo mas tarde',
          exitoso: false);
      return false;
    }
  }

  _navigateBack(BuildContext context) {
    Navigator.pop(context);
  }

  Future<void> _updatePassword() async {
    if (_formKeyPSW.currentState!.validate()) {
      await UserMethods()
          .updatePassword(_emailController.text, _passwordController.text);
      showToast(context, "Contraseña Actualizada", exitoso: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cambiar contraseña'),
      ),
      body: Stepper(
        steps: buildSteps(),
        type: StepperType.vertical,
        currentStep: _currentStep,
        onStepContinue: () async {
          if (_currentStep < buildSteps().length) {
            if (_currentStep == 0) {
              if (_formKeyEmail.currentState!.validate()) {
                bool mailIsUnique = await _checkMailDoesntExist();
                if (mailIsUnique) {
                  showToast(context, 'El correo no existe, prueba con otro',
                      exitoso: false);
                  return;
                }
                await _sendOTP();

                setState(() => _currentStep += 1);
              }
            } else if (_currentStep == 1) {
              if (_otpController.text.length == 6) {
                bool res = await _verifyOTP();
                if (res) {
                  setState(() => _currentStep += 1);
                } else {
                  setState(() =>
                      showToast(context, 'código incorrecto', exitoso: false));
                }
              }
            } else if (_currentStep == 2) {
              if (_formKeyPSW.currentState!.validate()) {
                if (_passwordController.text == _password2Controller.text) {
                  _updatePassword();
                  _navigateBack(context);
                }
              }
            }
          }
        },
        onStepCancel: () async {
          if (_currentStep > 0) {
            setState(() => _currentStep -= 1);
          } else {
            _navigateBack(context);
          }
        },
        controlsBuilder: (BuildContext context, ControlsDetails details) {
          return Row(
            children: <Widget>[
              TextButton(
                onPressed: details.onStepContinue,
                child: _currentStep == 2
                    ? Text('Actualizar',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary))
                    : Text('Continuar',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary)),
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
      ),
    );
  }

  List<Step> buildSteps() {
    return [
      Step(
        title: const Text('Escribe un correo'),
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
      Step(
        title: const Text('Cambia tu contraseña'),
        content: _buildPasswordStep(),
        isActive: _currentStep >= 2,
        state: _currentStep > 2 ? StepState.complete : StepState.indexed,
      )
    ];
  }

  Widget _buildUserDataStep() {
    return Form(
      key: _formKeyEmail,
      child: SingleChildScrollView(
        child: Column(
          children: [
            TextFieldInput(
              textEditingController: _emailController,
              hintText: 'Escribe tu correo',
              textInputType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, ingresa tu correo';
                } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                    .hasMatch(value)) {
                  return 'Por favor, ingresa un correo válido';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationStep() {
    return Form(
      key: _formKeyPSW,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText:
                      'Introduce el código mandado al correo ${_emailController.text}',
                  border: const OutlineInputBorder(),
                ),
                maxLength: 6,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
            ),
            const SizedBox(height: 12),
            _buildSendOTPButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSendOTPButton() => ElevatedButton(
        onPressed: _sendOTP,
        child: const Text('No lo has recibido? Enviar de nuevo'),
      );

  Widget _buildPasswordStep() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const Text("Nueva contraseña", style: TextStyle(fontSize: 16)),
          TextFieldInput(
            textEditingController: _passwordController,
            hintText: 'Escribe una contraseña nueva',
            textInputType: TextInputType.text,
            isPsw: true,
            validator: (value) => value == null || value.isEmpty
                ? 'Por favor, ingresa nueva contraseña'
                : null,
          ),
          const SizedBox(height: 8),
          TextFieldInput(
            textEditingController: _password2Controller,
            hintText: 'Verifica tu contraseña',
            textInputType: TextInputType.text,
            isPsw: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, verifica tu contraseña';
              }
              if (value != _passwordController.text) {
                return 'Las contraseñas no coinciden';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}
