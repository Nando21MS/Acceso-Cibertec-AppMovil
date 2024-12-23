import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'principal.dart';
import 'homepage.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  int _failedAttempts = 0;
  bool _isBlocked = false;
  int _remainingTime = 0;
  Timer? _blockTimer;

  @override
  void initState() {
    super.initState();
    _loadBlockState();
    _loadFailedAttempts();
  }

  Future<void> _loadBlockState() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _isBlocked = prefs.getBool('isBlocked') ?? false;
      _remainingTime = prefs.getInt('remainingTime') ?? 0;
    });

    if (_isBlocked) {
      _blockTimer = Timer.periodic(Duration(seconds: 1), (timer) async {
        setState(() {
          if (_remainingTime > 0) {
            _remainingTime--;
            prefs.setInt('remainingTime', _remainingTime);
          } else {
            _unblockUser();
          }
        });
      });
    }
  }

  Future<void> _loadFailedAttempts() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _failedAttempts = prefs.getInt('failedAttempts') ?? 0;
    });
  }

  void _incrementFailedAttempts() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _failedAttempts++;
    });

    await prefs.setInt('failedAttempts', _failedAttempts);

    if (_failedAttempts < 3) {
      // Verificar si no hay un SnackBar mostrado antes
      ScaffoldMessenger.of(context)
          .clearSnackBars(); // Limpiar cualquier SnackBar pendiente
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Intento fallido. Te quedan ${3 - _failedAttempts} intento(s).'),
          backgroundColor: Colors.orange,
        ),
      );
    } else {
      // Bloquear al usuario si llega a 3 intentos fallidos
      _blockUser();
    }
  }

  Future<void> _login() async {
    if (_isBlocked) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse(
        'https://sistema-de-accesos-backend-production.up.railway.app/url/mobile/auth/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'login': _usernameController.text,
          'password': _passwordController.text,
        }),
      );

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        final responseData = json.decode(utf8.decode(response.bodyBytes));
        final prefs = await SharedPreferences.getInstance();

        await prefs.setString('login', responseData['login']);
        await prefs.setInt('idUsuario', responseData['idUsuario']);
        await prefs.setString('nombres', responseData['nombres']);
        await prefs.setString('apellidos', responseData['apellidos']);
        await prefs.setString('numDoc', responseData['numDoc']);
        await prefs.setString('correo', responseData['correo']);

        setState(() {
          _failedAttempts = 0; // Reiniciar intentos en caso de éxito
        });
        await prefs.setInt('failedAttempts', 0);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainPage()),
        );
      } else {
        _incrementFailedAttempts();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Credenciales incorrectas, por favor intente de nuevo.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });

      // Aquí se maneja cualquier error que ocurra en la solicitud HTTP
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error de conexión. Por favor, intente nuevamente.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Método para bloquear al usuario
  void _blockUser() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _isBlocked = true;
      _remainingTime = 60; // 1 minuto de bloqueo
    });

    await prefs.setBool('isBlocked', true);
    await prefs.setInt('remainingTime', _remainingTime);

    _blockTimer = Timer.periodic(Duration(seconds: 1), (timer) async {
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
          prefs.setInt('remainingTime', _remainingTime);
        } else {
          _unblockUser();
        }
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Demasiados intentos fallidos. Intenta de nuevo en $_remainingTime segundos.'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _unblockUser() async {
    final prefs = await SharedPreferences.getInstance();

    _blockTimer?.cancel();
    await prefs.setBool('isBlocked', false);
    await prefs.remove('remainingTime');

    setState(() {
      _isBlocked = false;
      _failedAttempts = 0;
      _remainingTime = 0;
    });
  }

  @override
  void dispose() {
    _blockTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await SystemNavigator.pop();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 100,
                    color: Colors.blueAccent,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Iniciar Sesión',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  SizedBox(height: 30),
                  if (_isBlocked)
                    Column(
                      children: [
                        Text(
                          'Demasiados intentos fallidos. Intente de nuevo en:',
                          style: TextStyle(color: Colors.red, fontSize: 16),
                        ),
                        SizedBox(height: 10),
                        Text(
                          '${_remainingTime}s',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  if (!_isBlocked) ...[
                    TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.person_outline),
                        labelText: 'Usuario',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(
                            color: Colors.blueAccent,
                          ),
                        ),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-Z0-9]')),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor, ingrese su usuario';
                        }
                        if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value)) {
                          return 'Solo se permiten letras y números';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.lock_outline),
                        labelText: 'Contraseña',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(
                            color: Colors.blueAccent,
                          ),
                        ),
                      ),
                      obscureText: true,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-Z0-9]')),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor, ingrese su contraseña';
                        }
                        if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value)) {
                          return 'Solo se permiten letras y números';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    _isLoading
                        ? CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.lightGreen,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 100),
                            ),
                            child: Text(
                              'Iniciar sesión',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 68, 138, 255),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 40),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => HomePage()),
                        );
                      },
                      child: Text(
                        'Registra tus datos para tu visita',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}