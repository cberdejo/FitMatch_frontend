import 'dart:typed_data';

import 'package:fit_match/models/user.dart';
import 'package:fit_match/providers/get_jwt_token.dart';
import 'package:fit_match/providers/theme_provider.dart';
import 'package:fit_match/screens/shared/login_screen.dart';
import 'package:fit_match/services/auth_service.dart';
import 'package:fit_match/utils/dimensions.dart';
import 'package:fit_match/utils/utils.dart';
import 'package:fit_match/widget/edit_Icon.dart';
import 'package:fit_match/widget/text_field_input.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ViewProfileScreen extends StatefulWidget {
  final User user;

  const ViewProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreen();
}

class _ViewProfileScreen extends State<ViewProfileScreen> {
  final coverHeight = 200.0;
  final mobileprofileHeight = 250;
  final webProfileHeight = 400;

  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();

  bool _isEditingUsername = false;
  bool _isEditingBio = false;
  bool _isChangingPsw = false;

  late GlobalKey<FormState> _formKeyPSW;
  final _actualPasswordController = TextEditingController();
  final _passwordController = TextEditingController();
  final _password2Controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _formKeyPSW = GlobalKey<FormState>();

    _usernameController.text = widget.user.username;
    _bioController.text = widget.user.bio ?? '';
  }

  @override
  void dispose() {
    super.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    _actualPasswordController.dispose();
    _passwordController.dispose();
    _password2Controller.dispose();
  }

  String get currentSystem => widget.user.system;

  _updateUser(User user) async {
    try {
      User updatedUser = await UserMethods().editUsuario(user, null);
      await AuthMethods().updateUserPreference(widget.user.user_id);
      return updatedUser;
    } catch (e) {
      print('Error al actualizar el usuario: $e');
    }
  }

  Future<void> updateSystem(String newSystem) async {
    User newUser = widget.user;
    newUser.system = currentSystem == 'metrico' ? 'imperial' : 'metrico';

    try {
      await _updateUser(newUser);
    } catch (e) {
      print('Error al actualizar el sistema: $e');
    }

    setState(() {
      widget.user.system = newUser.system;
    });
  }

  Future<void> _updatePassword() async {
    if (_formKeyPSW.currentState!.validate()) {
      String res = "fail";
      try {
        res = await AuthMethods().loginUser(
            email: widget.user.email,
            password: _actualPasswordController.text,
            updatePreferences: false);
      } catch (e) {
        print('Error al actualizar la contraseña: $e');
        return;
      }

      if (res != AuthMethods.successMessage) {
        showToast(context, "Contraseña Incorrecta", exitoso: false);
      } else {
        User updatedUser = widget.user;
        updatedUser.password = _passwordController.text;
        _updateUser(updatedUser);
        showToast(context, "Contraseña Actualizada", exitoso: true);
        setState(() {
          _isChangingPsw = false;
        });
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.user.birth,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != widget.user.birth) {
      User updatedUser = widget.user;
      updatedUser.birth = picked;
      _updateUser(updatedUser);

      setState(() {
        widget.user.birth = picked;
      });
    }
  }

  Future<void> _selectImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      Uint8List im = await image.readAsBytes();
      User? updatedUser;
      try {
        updatedUser = await UserMethods().editUsuario(widget.user, im);
        await AuthMethods().updateUserPreference(widget.user.user_id);
      } catch (e) {
        print('Error al actualizar la imagen: $e');
      }

      if (updatedUser != null) {
        setState(() {
          widget.user.profile_picture = updatedUser!.profile_picture;
        });
      }
    }
  }

  _logOut(BuildContext context) async {
    removeToken();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(0),
        children: <Widget>[
          buildTop(),
          buildUsername(),
          buildOpciones(),
        ],
      ),
    );
  }

  Widget buildOpciones() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 1000),
      padding: const EdgeInsets.symmetric(horizontal: 48),
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          _buildOptionItem(
            icon: Icons.person_outline_outlined,
            onTap: () {},
            isExpandable: true,
            contentExpanded: buildPersonalInfo(),
            title: 'Información personal',
          ),
          _buildOptionItem(
            icon: Icons.settings,
            onTap: () {},
            title: 'Configuraciones',
            isExpandable: true,
            contentExpanded: buildConfiguraciones(),
          ),
          _buildOptionItem(
            icon: Icons.security,
            onTap: () {},
            title: 'Seguridad',
            isExpandable: true,
            contentExpanded: buildSeguridad(),
          ),
          _buildOptionItem(
            icon: Icons.logout,
            onTap: () {
              _logOut(context);
            },
            title: "Cerrar sesión",
            iconColor: Theme.of(context).colorScheme.secondary,
            arrow: false,
          ),
        ],
      ),
    );
  }

  Widget buildUsername() {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.center, // Asegura centrar el contenido
        children: [
          Expanded(
            // Asegura que el widget ocupe el espacio disponible
            child: _isEditingUsername
                ? TextFieldInput(
                    textEditingController: _usernameController,
                    hintText: 'Nombre de Usuario',
                    textInputType: TextInputType.text,
                  )
                : Text(
                    widget.user.username,
                    style: Theme.of(context).textTheme.headlineSmall,
                    overflow:
                        TextOverflow.ellipsis, // Previene overflow de texto
                  ),
          ),
          IconButton(
            icon: Icon(_isEditingUsername ? Icons.check : Icons.edit),
            onPressed: () {
              if (_isEditingUsername) {
                User updatedUser = widget.user;
                updatedUser.username = _usernameController.text;
                _updateUser(updatedUser);
                setState(() {
                  widget.user.username = _usernameController.text;
                  _isEditingUsername = false;
                });
              } else {
                setState(() {
                  _isEditingUsername = true;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget buildTop() {
    final double width = MediaQuery.of(context).size.width;
    final profileHeight =
        width < webScreenSize ? mobileprofileHeight : webProfileHeight;
    final bottom = profileHeight / 6;
    final top = coverHeight - profileHeight / 3;
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
          margin: EdgeInsets.only(bottom: bottom),
          child: buildCover(),
        ),
        Positioned(top: top, child: buildProfileImage()),
      ],
    );
  }

  Widget buildCover() {
    Color primaryColor = Theme.of(context).colorScheme.primary;
    Color lighterColor =
        Color.lerp(primaryColor, Colors.white, 0.3) ?? primaryColor;
    Color darkerColor =
        Color.lerp(primaryColor, Colors.black, 0.2) ?? primaryColor;
    return Container(
      width: double.infinity,
      height: coverHeight,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [darkerColor, lighterColor],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          tileMode: TileMode.clamp,
        ),
      ),
    );
  }

  Widget buildProfileImage() {
    final double width = MediaQuery.of(context).size.width;
    final profileHeight =
        width < webScreenSize ? mobileprofileHeight : webProfileHeight;
    final double circleSize = profileHeight / 2;

    final double imageSize = circleSize * 0.9;
    return Stack(
      children: [
        Container(
          width: circleSize,
          height: circleSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.background,
          ),
        ),
        Positioned(
          left: (circleSize - imageSize) / 2,
          top: (circleSize - imageSize) / 2,
          child: Stack(
            children: [
              CircleAvatar(
                radius: imageSize / 2,
                backgroundImage: NetworkImage(widget.user.profile_picture),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              Positioned(
                top: 0,
                child: (EditIcon(
                  color: Theme.of(context).colorScheme.primary,
                  onTap: _selectImage,
                )),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildConfiguraciones() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final mobileWidth = MediaQuery.of(context).size.width < webScreenSize;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 20),
          child: Text(
            'Tema',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Row(
          children: [
            const Icon(Icons.lightbulb_outline, color: Colors.yellow),
            mobileWidth ? const SizedBox(width: 2) : const SizedBox(width: 8),
            !mobileWidth ? const Text('Modo Claro') : Container(),
            const SizedBox(width: 8),
            Switch(
              value: themeProvider.currentTheme == ThemeEnum.Dark,
              onChanged: (value) {
                themeProvider
                    .changeTheme(value ? ThemeEnum.Dark : ThemeEnum.Light);
              },
            ),
            mobileWidth ? const SizedBox(width: 2) : const SizedBox(width: 8),
            const Icon(Icons.nightlight_round, color: Colors.blue),
            const SizedBox(width: 8),
            !mobileWidth ? const Text('Modo Oscuro') : Container(),
          ],
        ),
        const Divider(),
        const Padding(
          padding: EdgeInsets.only(top: 20, bottom: 10),
          child: Text(
            'Preferencia de unidades de medidas',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        ListTile(
          title: Text(
            'Sistema Imperial (ft, lb,...)',
            style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
          ),
          leading: Radio(
            value: 'imperial',
            groupValue: currentSystem,
            onChanged: (value) {
              updateSystem(value.toString());
            },
          ),
        ),
        ListTile(
          title: Text(
            'Sistema Métrico (m, kg,...)',
            style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
          ),
          leading: Radio(
            value: 'metrico',
            groupValue: currentSystem,
            onChanged: (value) {
              updateSystem(value.toString());
            },
          ),
        ),
      ],
    );
  }

  Widget buildPersonalInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 20),
          child: Text(
            'Fecha de nacimiento',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(DateFormat.yMMMMd('es_ES').format(widget.user.birth),
                style: const TextStyle(fontSize: 16)),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _selectDate(context),
            ),
          ],
        ),
        const Divider(),
        const Padding(
          padding: EdgeInsets.only(bottom: 20),
          child: Text(
            'Sobre ti',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        _isEditingBio
            ? Row(
                children: [
                  Expanded(
                    child: TextFieldInput(
                      textEditingController: _bioController,
                      hintText: 'Biografía',
                      maxLine: true,
                      textInputType: TextInputType.multiline,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.check),
                    onPressed: () {
                      // lógica para guardar la biografía
                      User updatedUser = widget.user;
                      updatedUser.bio = _bioController.text;
                      _updateUser(updatedUser);
                      setState(() {
                        widget.user.bio = _bioController.text;
                        _isEditingBio = false;
                      });
                    },
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      child: Text(widget.user.bio ?? 'Sin biografía',
                          style: const TextStyle(fontSize: 16))),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => setState(() {
                      _isEditingBio = true;
                    }),
                  ),
                ],
              ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget buildSeguridad() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 20),
          child: Text(
            'Correo electrónico',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Text(widget.user.email, style: const TextStyle(fontSize: 16)),
        const Divider(),
        const Padding(
          padding: EdgeInsets.only(bottom: 20),
          child: Text(
            'Contraseña',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        _isChangingPsw
            ? Form(
                key: _formKeyPSW,
                child: Column(children: [
                  const Text("Contraseña actual",
                      style: TextStyle(fontSize: 16)),
                  TextFieldInput(
                    textEditingController: _actualPasswordController,
                    hintText: 'Escribe tu contraseña actual',
                    textInputType: TextInputType.text,
                    isPsw: true,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Por favor, ingresa tu contraseña actual'
                        : null,
                  ),
                  const Divider(),
                  const Text("Nueva contraseña",
                      style: TextStyle(fontSize: 16)),
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
                  const SizedBox(height: 8),
                  Row(children: [
                    IconButton(
                        onPressed: () => setState(() {
                              _isChangingPsw = false;
                            }),
                        icon: const Icon(Icons.close, color: Colors.red)),
                    const SizedBox(width: 8),
                    IconButton(
                        onPressed: () {
                          _updatePassword();
                        },
                        icon: const Icon(Icons.check)),
                  ])
                ]),
              )
            : GestureDetector(
                onTap: () => setState(() {
                  _isChangingPsw = true;
                }),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Row(children: [
                    Text(
                      "Cambiar contraseña",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.edit,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  ]),
                ),
              ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    Color? iconColor,
    bool arrow = true,
    bool isExpandable = false,
    Widget? contentExpanded,
  }) {
    final iconArrow = arrow ? const Icon(Icons.arrow_forward_ios) : null;
    final textStyle = TextStyle(
        fontSize: 14, color: Theme.of(context).colorScheme.onBackground);
    const contentPadding = EdgeInsets.symmetric(vertical: 0, horizontal: 16);

    final primaryContainer = Theme.of(context).colorScheme.primaryContainer;
    if (isExpandable) {
      return ExpansionTile(
        leading: Icon(icon,
            color: iconColor ?? Theme.of(context).colorScheme.onBackground),
        title: Text(title, style: textStyle),
        trailing: iconArrow,
        tilePadding: contentPadding,
        children: contentExpanded != null
            ? [
                Padding(
                  padding: const EdgeInsets.only(left: 72),
                  child: contentExpanded,
                )
              ]
            : [],
      );
    } else {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: Row(
            children: [
              const SizedBox(width: 16),
              Icon(icon,
                  color:
                      iconColor ?? Theme.of(context).colorScheme.onBackground),
              const SizedBox(width: 8),
              Text(title),
              const Spacer(),
              if (arrow) iconArrow!,
            ],
          ),
        ),
      );
    }
  }

  // Widget _buildOptionItem({
  //   required IconData icon,
  //   required String title,
  //   VoidCallback? onTap,
  //   Color? iconColor,
  //   bool arrow = true,
  //   bool isExpandable = false,
  //   Widget? contentExpanded,
  // }) {
  //   if (isExpandable) {
  //     return ExpansionTile(
  //       leading: Icon(icon, color: iconColor),
  //       title: Text(title),
  //       children: contentExpanded != null ? [contentExpanded] : [],
  //     );
  //   } else {
  //     return MouseRegion(
  //       cursor: SystemMouseCursors.click,
  //       child: GestureDetector(
  //         onTap: onTap,
  //         child: Row(
  //           children: [
  //             Icon(icon, color: iconColor),
  //             const SizedBox(width: 8), // Espacio entre el ícono y el texto
  //             Text(title),

  //             const Spacer(), // Espacio para que la flecha se alinee a la derecha
  //             if (arrow == true) const Icon(Icons.arrow_forward_ios), // Flecha
  //           ],
  //         ),
  //       ),
  //     );
  //   }
  // }
}
