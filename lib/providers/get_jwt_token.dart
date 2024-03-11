import 'package:shared_preferences/shared_preferences.dart';

Future<String?> getToken() async {
  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  } catch (e) {
    print('Error al obtener el token: $e');
    return null;
  }
}

Future<void> removeToken() async {
  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  } catch (e) {
    print('Error al eliminar el token: $e');
  }
}
