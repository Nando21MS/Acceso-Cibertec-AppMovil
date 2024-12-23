import 'dart:convert';
import 'package:http/http.dart' as http;

class UsuarioService {
  final String baseUrl;

  UsuarioService(this.baseUrl);

  Future<Map<String, dynamic>?> obtenerUsuarioAutenticado() async {
    final url = Uri.parse('$baseUrl/url/usuario/buscarPorId');

    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Error al obtener usuario: ${response.statusCode}');
      return null; // Puedes manejar el error como desees
    }
  }
}
