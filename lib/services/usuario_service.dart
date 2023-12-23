import 'package:fit_match/utils/backendUrls.dart';
import 'package:http/http.dart' as http;

Future<String> getUsernameByClientId(num clienteId) async {
  final response =
      await http.get(Uri.parse("$getUsernameByClienteIdUrl/$clienteId"));

  if (response.statusCode == 200) {
    return response.body;
  } else {
    // Si la solicitud no fue exitosa, lanza una excepción o maneja el error
    throw Exception(
        'Error al obtener los posts. Código de estado: ${response.statusCode}');
  }
}
