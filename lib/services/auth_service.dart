import 'dart:typed_data';

import 'package:fit_match/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fit_match/utils/backend_urls.dart';
import 'dart:async';
import 'dart:convert';

class AuthMethods {
  SharedPreferences? preferences;
  static const successMessage = "success";
  void initPrefrences() async {
    preferences = await SharedPreferences.getInstance();
  }

  Future<String> loginUser(
      {required String email,
      required String password,
      bool updatePreferences = true}) async {
    String res = "Ha ocurrido algún error";
    try {
      // Initialize preferences
      initPrefrences();

      if (email.isNotEmpty && password.isNotEmpty) {
        // Create a map containing user credentials
        Map<String, dynamic> userCredentials = {
          'email': email,
          'plainPassword': password,
        };

        // Convert the map to a JSON string
        String jsonData = json.encode(userCredentials);

        // Send a POST request for login
        final response = await http.post(
          Uri.parse(loginUrl), // Replace with your login API endpoint
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonData,
        );

        print('Response status: ${response.statusCode}');

        // Check the response status
        if (response.statusCode == 200) {
          // Parse the response JSON if needed
          // Update 'res' based on the response from your backend
          res = successMessage;
          if (updatePreferences) {
            await preferences!
                .setString('token', json.decode(response.body)['token']);
          }
        } else {
          res = "Error, comprueba tus credenciales.";
        }
      } else {
        res = "Por favor escribe tu correo y contraseña.";
      }
    } catch (err) {
      return err.toString();
    }
    return res;
  }

  Future<bool> updateUserPreference(num user_id) async {
    try {
      initPrefrences();
      final response = await http.get(
        Uri.parse('$usuarioTokenUrl/$user_id'),
      );
      if (response.statusCode == 200) {
        await preferences!
            .setString('token', json.decode(response.body)['token']);
        return true;
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> createUsuario({
    required String username,
    required String email,
    required String password,
    required int profileId,
    required String birth,
    required Uint8List? profilePicture,
  }) async {
    String res = "Ha ocurrido algún error";
    try {
      var request = http.MultipartRequest('POST', Uri.parse(usuariosUrl));

      request.fields['username'] = username;
      request.fields['email'] = email;
      request.fields['password'] = password;
      request.fields['profile_id'] = profileId.toString();
      request.fields['birth'] = birth;

      // Adjuntar la imagen de perfil si está presente
      if (profilePicture != null) {
        var pictureStream = http.ByteStream(Stream.value(profilePicture));
        var pictureLength = profilePicture.length;
        var multipartFile = http.MultipartFile(
            'profile_picture', pictureStream, pictureLength,
            filename: 'profile_picture.jpg');
        request.files.add(multipartFile);
      }

      var response = await request.send();

      if (response.statusCode == 201) {
        res = successMessage;
      } else {
        res =
            "Error al crear el usuario. Código de estado: ${response.statusCode}";
      }
    } catch (e) {
      res = "Ha ocurrido un error al crear el usuario: $e";
    }
    return res;
  }
}

class UserMethods {
  Future<User> editUsuario(User user, Uint8List? picture) async {
    try {
      var request = http.MultipartRequest(
          'PUT', Uri.parse('$usuariosUrl/${user.user_id}'));

      // Convierte el objeto user a un mapa JSON
      Map<String, String> userData = {
        'username': user.username,
        'email': user.email,
        'birth': user.birth.toString(),
        'system': user.system,
        'bio': user.bio ?? '',
        'password': user.password ?? "",
        'isPublic': user.public.toString(),
      };

      request.fields.addAll(userData);

      // Si se proporciona una imagen, inclúyela en el request
      if (picture != null) {
        var pictureStream = http.ByteStream.fromBytes(picture);
        var pictureLength = picture.length;
        var multipartFile = http.MultipartFile(
          'profile_picture',
          pictureStream,
          pictureLength,
          filename: 'profile_picture.jpg',
        );
        request.files.add(multipartFile);
      }

      // Envía la solicitud multipart al servidor
      var response = await request.send();

      // Verifica si la solicitud fue exitosa (código de estado 201)
      if (response.statusCode == 200 || response.statusCode == 201) {
        return User.fromJson(jsonDecode(await response.stream.bytesToString()));
      } else {
        throw Exception(
          'Error al editar usuario. Código de estado: ${response.statusCode}',
        );
      }
    } catch (e) {
      // Maneja cualquier error que pueda ocurrir durante la llamada
      print('Error al editar usuario: $e');
      rethrow;
    }
  }

  Future<bool> updatePassword(String email, String password) async {
    User user = await getUserByEmail(email);
    user.password = password;
    return editUsuario(user, null)
        .then((value) => true)
        .catchError((_) => false);
  }

  Future<User> getUserByEmail(String email) async {
    try {
      final response = await http.get(Uri.parse('$usuariosUrl/email/$email'));

      if (response.statusCode == 404) {
        //usuario no encontrado
        throw Exception('Usuario no encontrado');
      } else {
        //usuario encontrado
        return User.fromJson(jsonDecode(response.body));
      }
    } catch (err) {
      rethrow;
    }
  }

  Future<bool> UserWithEmailDoesntExists(String email) async {
    try {
      final response = await http.get(Uri.parse('$usuariosUrl/email/$email'));

      if (response.statusCode == 404) {
        //usuario no encontrado
        return true;
      } else {
        //usuario encontrado
        return false;
      }
    } catch (err) {
      rethrow;
    }
  }
}

class OTPMethods {
  Future<bool> sendOTP(String email) async {
    try {
      final response = await http.post(
        Uri.parse(sendOtpUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'mail': email}),
      );
      if (response.statusCode == 200) {
        return true; // OTP enviado correctamente
      } else {
        return false;
      }
    } catch (err) {
      rethrow;
    }
  }

  Future<bool> checkOtp(String otp) async {
    try {
      final response = await http.post(
        Uri.parse(checkOtpUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'otp': otp}),
      );
      if (response.statusCode == 200) {
        return true; // OTP verificado correctamente
      } else {
        return false;
      }
    } catch (err) {
      rethrow;
    }
  }
}
