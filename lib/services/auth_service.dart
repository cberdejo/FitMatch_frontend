import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fit_match/utils/backendUrls.dart';
import 'dart:async';
import 'dart:typed_data';
import 'dart:convert';

class AuthMethods {
  SharedPreferences? preferences;
  static const successMessage = "success";
  void initPrefrences() async {
    preferences = await SharedPreferences.getInstance();
  }

  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
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

          await preferences!
              .setString('token', json.decode(response.body)['token']);
          print(preferences!.getString('token'));
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

  Future<String> registerUser({
    required String email,
    required String password,
    required String username,
    required DateTime birth,
    required Uint8List pic,
    required num id,
  }) async {
    String res = "Some error Occurred";
    try {
      if (email.isNotEmpty ||
          password.isNotEmpty ||
          username.isNotEmpty ||
          id != null ||
          birth != null ||
          pic != null) {
        // Create a map containing user data
        Map<String, dynamic> userData = {
          'email': email,
          'password': password,
          'username': username,
          'birth': birth,
          'profile_pictre': pic,
          'profile_id': id
        };

        // Convert the map to a JSON string
        String jsonData = json.encode(userData);

        // Send a POST
        final response = await http.post(
          Uri.parse(usuariosUrl),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonData,
        );

        // Check the response status
        if (response.statusCode == 200) {
          // Parse the response JSON if needed
          res = "success";
        } else {
          res = "Failed to register. Please try again.";
        }
      } else {
        res = "Please enter all the fields";
      }
    } catch (err) {
      return err.toString();
    }
    return res;
  }
}
