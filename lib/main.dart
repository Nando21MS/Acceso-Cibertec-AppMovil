import 'package:accessqr/HomePage.dart';
import 'package:flutter/material.dart';
import 'package:accessqr/loginPage.dart';
import 'package:accessqr/micuenta.dart';
import 'package:accessqr/misAccesos.dart';
import 'package:accessqr/principal.dart';
import 'package:accessqr/tyc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Acceso Cibertec',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',  // Establecer la ruta inicial
      routes: {
        '/': (context) => LoginPage(),  
        '/homePage': (context) => HomePage(),
        '/micuenta': (context) => MiCuenta(),
        '/misaccesos': (context) => MisAccesos(),
        '/principal': (context) => MainPage(),
        '/tyc': (context) => TyC(),
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(builder: (context) => HomePage());
      },
    );
  }
}

