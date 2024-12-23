import 'package:flutter/material.dart';
import 'package:accessqr/principal.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MiCuenta extends StatefulWidget {
  @override
  _PerfilUsuarioPageState createState() => _PerfilUsuarioPageState();
}

class _PerfilUsuarioPageState extends State<MiCuenta> {
  Map<String, dynamic>? usuario;
  String? userImageUrl;

  @override
  void initState() {
    super.initState();
    _cargarUsuario();
  }

  Future<void> _cargarUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      usuario = {
        'idUsuario': prefs.getInt('idUsuario'),
        'nombres': prefs.getString('nombres'),
        'apellidos': prefs.getString('apellidos'),
        'numDoc': prefs.getString('numDoc'),
        'correo': prefs.getString('correo'),
      };
      int? idUsuario = prefs.getInt('idUsuario');
      userImageUrl =
          'https://sistema-de-accesos-backend-production.up.railway.app/url/usuario/$idUsuario';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf0f0f5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF083E6C),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) => MainPage(),
                transitionsBuilder: (context, animation1, animation2, child) {
                  const begin =
                      Offset(-1.0, 0.0); // Deslizar desde la izquierda
                  const end = Offset.zero;
                  const curve = Curves.easeInOut;

                  var tween = Tween(begin: begin, end: end)
                      .chain(CurveTween(curve: curve));

                  return SlideTransition(
                    position: animation1.drive(tween),
                    child: child,
                  );
                },
              ),
            );
          },
        ),
      ),
      body: usuario == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  // Título centrado con color personalizado
                  Text(
                    'Mi Cuenta',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF083E6C), // Color del título
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  // Círculo con ícono de usuario
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white,
                    backgroundImage: userImageUrl != null
                        ? NetworkImage(userImageUrl!)
                        : null, // Cargar imagen si la URL existe
                    child: userImageUrl == null
                        ? const Icon(Icons.person,
                            color: Color(0xFF083E6C)) // Icono por defecto
                        : null,
                  ),
                  SizedBox(height: 24),
                  // Campos de texto para nombres y apellidos
                  _crearCampoTexto(
                      'Nombres', usuario!['nombres'], Icons.person),
                  SizedBox(height: 16),
                  _crearCampoTexto(
                      'Apellidos', usuario!['apellidos'], Icons.person),
                  SizedBox(height: 16),
                  _crearCampoTexto(
                      'DNI', usuario!['numDoc'], Icons.perm_identity),
                  SizedBox(height: 16),
                  _crearCampoTexto('Correo', usuario!['correo'], Icons.email),
                ],
              ),
            ),
    );
  }

  Widget _crearCampoTexto(String titulo, String? valor, IconData icono) {
    return TextField(
      controller:
          TextEditingController(text: valor), // Aquí se establece el texto
      decoration: InputDecoration(
        labelText: titulo,
        prefixIcon: Icon(icono, color: Color(0xFF083E6C)), // Color del ícono
        labelStyle:
            TextStyle(color: Color(0xFF083E6C)), // Color del texto del label
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      enabled: false, // Desactiva la edición para que solo muestre el texto
    );
  }
}
