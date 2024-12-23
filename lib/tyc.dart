import 'package:flutter/material.dart';
import 'package:accessqr/principal.dart';

class TyC extends StatelessWidget {
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Términos y condiciones',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF083E6C),
              ),
            ),
            const SizedBox(height: 16),
            Divider(color: Colors.grey),
            Expanded(
              child: ListView(
                children: [
                  ExpansionTile(
                    title: Text(
                      'Aceptación de los Términos',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Al utilizar este aplicativo móvil, el usuario acepta los términos y condiciones descritos en este documento.',
                        ),
                      ),
                    ],
                  ),
                  Divider(color: Colors.grey),
                  ExpansionTile(
                    title: Text(
                      'Aplicativo Móvil',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'El aplicativo móvil tiene dos secciones principales, con reglas y condiciones específicas para usuarios internos y externos.',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            ExpansionTile(
                              title: Text(
                                'a. Sección para Internos (Estudiantes, Profesores, Trabajadores)',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          '• Los usuarios internos deben iniciar sesión con sus credenciales institucionales de Cibertec.'),
                                      Text(
                                          '• Al iniciar sesión, se generará un código de barras único, válido por 6 meses. Este código no se renueva al cerrar o abrir la aplicación; el mismo código se mantendrá activo hasta la fecha de expiración.'),
                                      Text(
                                          '• El código de barras es personal e intransferible. El uso indebido del código, como compartirlo con terceros, puede resultar en la suspensión del acceso a la institución.'),
                                      Text(
                                          '• El código de barras deberá ser presentado al personal de seguridad para registrar la entrada y salida de la institución.'),
                                      Text(
                                          '• En caso de no contar con el código de barras al momento del ingreso, el personal de seguridad puede verificar el acceso manualmente mediante el DNI o código de alumno.'),
                                      Text(
                                          '• Invitación de Externos: Los estudiantes tendrán la posibilidad de invitar a personas externas a la institución a través del apartado correspondiente. Cada estudiante podrá invitar hasta un máximo de 3 personas por mes.'),
                                      Text(
                                          '• El estudiante que invite a una persona externa será responsable de cualquier daño o perjuicio causado por el invitado dentro de las instalaciones de la institución.'),
                                      Text(
                                          '• Dependiendo de la gravedad de los daños, se impondrán las siguientes sanciones:'),
                                      Text(
                                          '  • Sanción leve (por daños menores): Advertencia oficial por parte de la institución y prohibición temporal de invitar a personas externas (hasta 3 meses).'),
                                      Text(
                                          '  • Sanción moderada (daños moderados o perjuicios significativos): Suspensión de derechos de acceso durante un semestre y restricción permanente de invitar a externos.'),
                                      Text(
                                          '  • Sanción grave (por daños graves o conducta inapropiada del invitado): Suspensión inmediata de acceso a la institución por un semestre o más, con posibilidad de expulsión dependiendo de la severidad del daño o conducta.'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            ExpansionTile(
                              title: Text(
                                'b. Sección para Externos (Visitantes)',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          '• Los usuarios externos no necesitan crear una cuenta ni iniciar sesión.'),
                                      Text(
                                          '• Los externos deberán completar un formulario con sus datos personales, motivo de la visita y el área de la institución que desean visitar.'),
                                      Text(
                                          '• Tras completar el formulario, se generará un código de barras temporal, que será válido únicamente durante el tiempo de la visita. El tiempo de validez del código comenzará desde el registro de ingreso y terminará una vez que el visitante registre su salida de la institución. Después de este proceso, el código dejará de ser válido.'),
                                      Text(
                                          '• Los usuarios externos deben portar un documento de identidad oficial al momento de la visita para su validación. La institución se reserva el derecho de verificar la identidad.'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Divider(color: Colors.grey),
                  ExpansionTile(
                    title: Text('Proveedores',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                '• Los proveedores deben solicitar permiso de acceso al supervisor de la institución antes de su visita.'),
                            Text(
                                '• La aprobación de la solicitud generará un código de barras temporal, válido solo para el día de la visita.'),
                            Text(
                                '• El proveedor debe seguir el mismo proceso de escaneo de código al ingresar y salir de la institución.'),
                            Text(
                                '• Si el proveedor olvida o pierde su código, el personal de seguridad puede registrar su ingreso manualmente utilizando su DNI o RUC.'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Divider(color: Colors.grey),
                  ExpansionTile(
                    title: Text('Uso del Código de Barras',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                '• El código de barras proporcionado por el aplicativo es un identificador único para facilitar el ingreso y la salida de la institución.'),
                            Text(
                                '• Los usuarios son responsables de mantener la seguridad y confidencialidad de su código.'),
                            Text(
                                '• En caso de robo, pérdida o uso indebido del código, el usuario debe informar a la institución de inmediato.'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Divider(color: Colors.grey),
                  ExpansionTile(
                    title: Text('Restricciones de Acceso',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                '• El acceso a la institución puede ser denegado si el usuario ha tenido incidentes previos que justifiquen la suspensión temporal o permanente.'),
                            Text(
                                '• El sistema de seguridad tiene la capacidad de suspender o revocar el acceso de un usuario si se detecta un comportamiento indebido o violación de los términos.'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Divider(color: Colors.grey),
                  ExpansionTile(
                    title: Text('Responsabilidad del Usuario',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                '• Los usuarios deben utilizar la aplicación de manera responsable y conforme a las normativas de la institución.'),
                            Text(
                                '• Cibertec no será responsable por fallos técnicos, problemas de conexión u otros inconvenientes que impidan el uso correcto del aplicativo móvil.'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Divider(color: Colors.grey),
                  ExpansionTile(
                    title: Text('Modificaciones',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                            '• La institución se reserva el derecho de modificar los términos y condiciones en cualquier momento, notificando a los usuarios a través de la aplicación.'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
