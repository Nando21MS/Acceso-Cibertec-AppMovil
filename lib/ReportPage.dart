import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'LoginPage.dart';

class ReportPage extends StatelessWidget {
  final String fullName;
  final String documentNumber;

  ReportPage({required this.fullName, required this.documentNumber});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf8f9fa),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0056A1),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) => LoginPage(),
                transitionsBuilder: (context, animation1, animation2, child) {
                  const begin = Offset(-1.0, 0.0);
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
        title: const Text(
          'Confirmación de Visita',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                // Ícono decorativo superior
                Icon(
                  Icons.verified_user,
                  size: 100,
                  color: const Color(0xFF0056A1),
                ),
                const SizedBox(height: 16),
                Text(
                  'Gracias, $fullName',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF343a40),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Tu visita ha sido registrada exitosamente.',
                  style: TextStyle(
                    fontSize: 18,
                    color: const Color(0xFF6c757d),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        'Tu Código de Visita',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF495057),
                        ),
                      ),
                      const SizedBox(height: 16),
                      BarcodeWidget(
                        barcode: Barcode.code128(),
                        data: documentNumber,
                        width: 250,
                        height: 100,
                        drawText: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Recuerda presentar tu Documento de Identidad o este codigo de barras para ingresar a la Institución.',
                  style: TextStyle(
                    fontSize: 18,
                    color: const Color(0xFF6c757d),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0056A1),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 5,
                  ),
                  child: const Text(
                    "Volver al Inicio",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
