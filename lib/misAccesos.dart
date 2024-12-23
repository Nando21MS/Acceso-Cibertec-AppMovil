import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:accessqr/principal.dart';

class MisAccesos extends StatefulWidget {
  @override
  _MisAccesosState createState() => _MisAccesosState();
}

class _MisAccesosState extends State<MisAccesos> {
  final TextEditingController _fechaController = TextEditingController();
  List<Map<String, dynamic>> _accesos = [];
  int? _idUsuario;

  @override
  void initState() {
    super.initState();
    _obtenerIdUsuario();
  }

  // Método para obtener el ID del usuario autenticado
  Future<void> _obtenerIdUsuario() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _idUsuario = prefs.getInt('idUsuario');
    });
    if (_idUsuario != null) {
      await _consultarAccesos(); // Consultar accesos al cargar la vista
    }
  }

  // Método para consultar los accesos
  Future<void> _consultarAccesos() async {
    final String fecha = _fechaController.text.trim();
    if (_idUsuario == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: Usuario no autenticado")),
      );
      return;
    }

    String url =
        'https://sistema-de-accesos-backend-production.up.railway.app/url/mobile/acceso/filtrarAccesos?idUsuario=$_idUsuario';
    if (fecha.isNotEmpty) {
      url += '&fecha=$fecha';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      setState(() {
        _accesos = data.map((item) {
          return {
            'fechaAcceso': item['fechaAcceso'] ?? 'No disponible',
            'horaAcceso': item['horaAcceso'] ?? 'No disponible',
            'tipoAcceso': item['tipoAcceso'] ?? 'No disponible',
          };
        }).toList();
      });
    } else {
      Fluttertoast.showToast(
        msg: "No se encontraron accesos",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            SizedBox(height: 20),
            TextField(
              controller: _fechaController,
              decoration: InputDecoration(
                labelText: 'Ingrese la fecha (opcional)',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
              onTap: () async {
                FocusScope.of(context).requestFocus(FocusNode());
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (pickedDate != null) {
                  setState(() {
                    _fechaController.text =
                        "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                  });
                }
              },
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _consultarAccesos,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF083E6C), // Color de fondo del botón
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                'Consultar Accesos',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white, // Color blanco para el texto
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(child: _buildAccesoTable()),
          ],
        ),
      ),
    );
  }

  // Construir el encabezado de la vista
  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          'Mis Accesos',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF083E6C),
          ),
        ),
        Divider(color: Colors.indigo[900]),
      ],
    );
  }

  // Construir la tabla de accesos
  Widget _buildAccesoTable() {
    return _accesos.isNotEmpty
        ? SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Table(
              border: TableBorder.all(color: Colors.grey),
              columnWidths: {
                0: FlexColumnWidth(1),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1),
              },
              children: [
                _buildTableRow(
                    'Fecha de Acceso', 'Hora de Acceso', 'Tipo de Acceso',
                    isHeader: true),
                ..._accesos.map((acceso) {
                  return _buildTableRow(
                    acceso['fechaAcceso'] ?? 'No disponible',
                    acceso['horaAcceso'] ?? 'No disponible',
                    acceso['tipoAcceso'] ?? 'No disponible',
                  );
                }).toList(),
              ],
            ),
          )
        : Center(
            child: Text("No se encontraron accesos",
                style: TextStyle(color: Colors.grey, fontSize: 16)));
  }

  // Construir una fila de la tabla
  TableRow _buildTableRow(String fecha, String hora, String tipo,
      {bool isHeader = false}) {
    return TableRow(
      decoration: BoxDecoration(
        color: isHeader ? Color(0xFF083E6C) : Colors.white,
      ),
      children: [
        _buildTableCell(fecha, isHeader),
        _buildTableCell(hora, isHeader),
        _buildTableCell(tipo, isHeader),
      ],
    );
  }

  // Construir una celda de la tabla
  Widget _buildTableCell(String text, bool isHeader) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          color: isHeader ? Colors.white : Colors.black,
          fontSize: isHeader ? 16 : 14,
        ),
      ),
    );
  }
}
