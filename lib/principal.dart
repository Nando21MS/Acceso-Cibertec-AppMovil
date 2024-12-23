import 'package:accessqr/loginPage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:barcode_widget/barcode_widget.dart'; // Agregamos BarcodeWidget
import 'micuenta.dart';
import 'misAccesos.dart';
import 'tyc.dart';

class MainPage extends StatefulWidget {
  MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String? nombreCompleto = ''; // Para almacenar el nombre completo
  String? loginCode; // Para almacenar el código de login
  String? correo;
  String? userImageUrl; // Para almacenar la URL de la imagen del usuario

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Cargar datos del usuario
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    String nombres = prefs.getString('nombres') ?? '';
    String apellidos = prefs.getString('apellidos') ?? '';
    String login = prefs.getString('login') ?? '';
    correo = prefs.getString('correo');
    int? idUsuario = prefs.getInt('idUsuario'); // Obtener el idUsuario
    setState(() {
      nombreCompleto = '$nombres $apellidos';
      loginCode = login; // Almacenar el código de login
      userImageUrl =
          'https://sistema-de-accesos-backend-production.up.railway.app/url/usuario/$idUsuario'; // Construir la URL de la imagen
    });
  }

  // Función para cerrar sesión
  void _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Limpiar preferencias
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  // Método para manejar el botón de retroceso
  Future<bool> _onWillPop() async {
    if (_scaffoldKey.currentState!.isDrawerOpen) {
      // Si el Drawer está abierto, lo cerramos
      _scaffoldKey.currentState!.closeDrawer();
      return false; // Evita la acción predeterminada de regresar
    } else {
      // Si el Drawer está cerrado, se hace un regreso a la página de login
      _logout(context);
      return true; // Permite el regreso a la página de login
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop, // Se detecta el botón de retroceso
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: const Color(0xFF083E6C),
        appBar: AppBar(
          backgroundColor: const Color(0xFF083E6C),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Row(
                children: [
                  Text(
                    'Hola\n$nombreCompleto',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white,
                    backgroundImage: userImageUrl != null
                        ? NetworkImage(userImageUrl!)
                        : null, // Cargar imagen si la URL existe
                    child: userImageUrl == null
                        ? const Icon(Icons.person,
                            color: Color(0xFF083E6C)) // Icono por defecto
                        : null,
                  ),
                ],
              ),
            ),
          ],
        ),
        drawer: Drawer(
          child: Column(
            children: <Widget>[
              DrawerHeader(
                decoration: const BoxDecoration(
                  color: Color(0xFF083E6C),
                ),
                child: Container(
                  width: double.infinity, // Ancho completo
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      backgroundImage: userImageUrl != null
                          ? NetworkImage(userImageUrl!)
                          : null, // Cargar imagen si la URL existe
                      child: userImageUrl == null
                          ? const Icon(Icons.person,
                              size: 50, color: Color(0xFF083E6C)) // Fallback
                          : null,
                    ),
                      const SizedBox(height: 10),
                      Text(
                        nombreCompleto ?? '',
                        style: const TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      Text(
                        correo ?? '',
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: <Widget>[
                    ListTile(
                      leading: const Icon(Icons.home),
                      title: const Text('Inicio'),
                      onTap: () {
                        Navigator.pop(context); // Cierra el Drawer
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: const Text('Mi cuenta'),
                      onTap: () {
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    MiCuenta(),
                            transitionsBuilder:
                                (context, animation, secondaryAnimation, child) {
                              const begin = Offset(1.0, 0.0); // Inicia derecha
                              const end = Offset.zero; // Termina posición actual
                              const curve = Curves.easeInOut;

                              var tween = Tween(begin: begin, end: end)
                                  .chain(CurveTween(curve: curve));

                              return SlideTransition(
                                position: animation.drive(tween),
                                child: child,
                              );
                            },
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.access_time),
                      title: const Text('Mis accesos'),
                      onTap: () {
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    MisAccesos(),
                            transitionsBuilder:
                                (context, animation, secondaryAnimation, child) {
                              const begin = Offset(1.0, 0.0); // Inicia derecha
                              const end = Offset.zero; // Termina posición actual
                              const curve = Curves.easeInOut;

                              var tween = Tween(begin: begin, end: end)
                                  .chain(CurveTween(curve: curve));

                              return SlideTransition(
                                position: animation.drive(tween),
                                child: child,
                              );
                            },
                          ),
                        );
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.description),
                      title: const Text('Términos y condiciones'),
                      onTap: () {
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) => TyC(),
                            transitionsBuilder:
                                (context, animation, secondaryAnimation, child) {
                              const begin = Offset(1.0, 0.0);
                              const end = Offset.zero;
                              const curve = Curves.easeInOut;

                              var tween = Tween(begin: begin, end: end)
                                  .chain(CurveTween(curve: curve));

                              return SlideTransition(
                                position: animation.drive(tween),
                                child: child,
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 16.0, horizontal: 8.0), // Añade margen
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Color de fondo del botón
                    foregroundColor: Colors.white, // Color del texto
                    minimumSize: const Size.fromHeight(50), // Ancho completo
                  ),
                  icon: const Icon(Icons.exit_to_app, color: Colors.white),
                  label: const Text('Cerrar sesión'),
                  onPressed: () => _logout(context),
                ),
              ),
            ],
          ),
        ),
        body: Center(
          child: loginCode != null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: BarcodeWidget(
                        barcode: Barcode.code128(), // Tipo de código de barras
                        data: loginCode!, // Datos para generar el código
                        width: 300,
                        height: 100,
                        drawText: true, // Muestra el texto del código de barras
                        color: Colors.black, // Color del código de barras
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Este es tu código de barras para tu acceso. No lo compartas!',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24), // Color blanco y tamaño de fuente
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20), // Añade un espacio adicional
                  ],
                )
              : Text(
                  'No hay código de login disponible',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
        ),
      ),
    );
  }
}
