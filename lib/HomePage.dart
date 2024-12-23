import 'package:flutter/material.dart';
import 'visitorformpage.dart';
import 'RegisterVisitPage.dart';
import 'loginpage.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Navegar a la pantalla de Login con animación de desvanecimiento
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => LoginPage(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = 0.0; // Comienza desde totalmente transparente
              const end = 1.0; // Termina completamente opaco
              const curve = Curves.easeInOut;

              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              var opacityAnimation = animation.drive(tween);

              return FadeTransition(
                opacity: opacityAnimation,
                child: child,
              );
            },
          ),
        );
        return false; // Evita el pop por defecto
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icono relacionado con programar visitas (calendario)
                  Icon(
                    Icons.calendar_today_outlined, // Calendario
                    size: 120, // Aumenté el tamaño del ícono
                    color: Colors.blueAccent,
                  ),
                  SizedBox(height: 30),

                  // Título
                  Text(
                    'Registro de Mi Visita',
                    style: TextStyle(
                      fontSize: 32, // Aumenté el tamaño de la fuente
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                      letterSpacing:
                          2, // Espaciado de las letras para un mejor efecto visual
                    ),
                  ),
                  SizedBox(height: 40),

                  // Botón para usuarios de Cibertec
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: EdgeInsets.symmetric(
                          horizontal: 70, vertical: 15), // Botón más grande
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(25), // Bordes más redondeados
                      ),
                      elevation: 5, // Añadí sombra para que se vea más destacado
                    ),
                    onPressed: () {
                      // Redirige al VisitorFormPage con la animación
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) =>
                              VisitorFormPage(),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            const begin =
                                Offset(1.0, 0.0); // Inicia desde la derecha
                            const end =
                                Offset.zero; // Termina en la posición actual
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
                    child: Text(
                      'Mi primera Visita',
                      style: TextStyle(
                        fontSize: 22, // Aumenté el tamaño del texto
                        color: Colors.white,
                        fontWeight: FontWeight.bold, // Hice el texto en negrita
                      ),
                    ),
                  ),
                  SizedBox(height: 30), // Aumenté el espacio entre botones

                  // Botón para visitantes o externos
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(horizontal: 70, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 5,
                    ),
                    onPressed: () {
                      // Redirige a RegisterVisitPage con la animación
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) =>
                              RegisterVisitPage(),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            const begin =
                                Offset(1.0, 0.0); // Inicia desde la derecha
                            const end =
                                Offset.zero; // Termina en la posición actual
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
                    child: Text(
                      'Ya he visitado antes',
                      style: TextStyle(
                        fontSize: 22, // Aumenté el tamaño del texto
                        color: Colors.white,
                        fontWeight: FontWeight.bold, // Hice el texto en negrita
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
