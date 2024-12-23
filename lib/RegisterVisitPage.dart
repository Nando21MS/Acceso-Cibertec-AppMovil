import 'package:accessqr/HomePage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:accessqr/BarcodePage.dart';

class RegisterVisitPage extends StatefulWidget {
  @override
  _RegisterVisitPageState createState() => _RegisterVisitPageState();
}

class _RegisterVisitPageState extends State<RegisterVisitPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _numDocController = TextEditingController();
  final TextEditingController _motivoVisitaController = TextEditingController();
  final FocusNode _numDocFocusNode = FocusNode(); // Focus node for keyboard
  bool _isError = false; // Flag to track error state

  List<Map<String, dynamic>> tiposDocumentos = [];
  int? tipoDocumentoSeleccionado;

  // Cargar tipos de documentos desde el backend
  Future<void> _cargarTiposDocumentos() async {
    try {
      final response = await http.get(Uri.parse(
          'https://sistema-de-accesos-backend-production.up.railway.app/url/util/listaTipoDoc'));
      if (response.statusCode == 200) {
        final List<dynamic> tipos = json.decode(response.body);
        setState(() {
          tiposDocumentos = tipos.map((tipo) {
            return {
              "idTipoDoc": tipo['idTipoDoc'],
              "descripcion": tipo['descripcion']
            };
          }).toList();
        });
      }
    } catch (error) {
      print('Error al cargar tipos de documentos: $error');
    }
  }

  // Método para registrar el motivo de visita
  Future<void> _registrarMotivoVisita() async {
    if (_formKey.currentState?.validate() ?? false) {
      final Map<String, dynamic> data = {
        "usuario": {
          "numDoc": _numDocController.text,
          "tipodocumento": {
            "idTipoDoc": tipoDocumentoSeleccionado,
          },
        },
        "motivoVisita": _motivoVisitaController.text,
      };

      final String jsonBody = json.encode(data);
      print('Registrando motivo de visita: $jsonBody');

      try {
        final response = await http.post(
          Uri.parse(
              'https://sistema-de-accesos-backend-production.up.railway.app/url/usuario/registrarMotivoVisita'),
          headers: {'Content-Type': 'application/json'},
          body: jsonBody,
        );

        if (response.statusCode == 200) {
          Fluttertoast.showToast(
            msg: "Visita registrada exitosamente",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.green,
            textColor: Colors.white,
          );
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => BarcodePage(
                documentNumber: _numDocController.text,
              ),
            ),
          );
        } else {
          setState(() {
            _isError = true; // Highlight error
          });
          FocusScope.of(context).requestFocus(_numDocFocusNode);
          Fluttertoast.showToast(
            msg: "No se encontró el número de documento",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
      } catch (error) {
        print('Error de conexión: $error');
        Fluttertoast.showToast(
          msg: "Error de conexión: $error",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    }
  }

  // Validación para el número de documento
  String? _validarNumeroDocumento(String? value) {
    if (value == null || value.isEmpty) {
      return 'Este campo es obligatorio';
    }
    if (tipoDocumentoSeleccionado == null) {
      return 'Seleccione un tipo de documento primero';
    }

    // Validar que el número de documento no empiece con "I20"
    if (value.toLowerCase().startsWith('i20')) {
      return 'El número de documento no puede comenzar con "I20" o "i20"';
    }

    if (tipoDocumentoSeleccionado == 1) {
      // DNI (8 dígitos)
      RegExp regexDni = RegExp(r'^\d{8}$');
      if (!regexDni.hasMatch(value)) {
        return 'El DNI debe tener 8 dígitos y solo debe contener números';
      }

      // Evitar secuencias repetitivas de más de 3 veces
      RegExp repetitivas = RegExp(r'(\d)\1{3,}');
      if (repetitivas.hasMatch(value)) {
        return 'El DNI no puede contener más de 3 números repetidos consecutivos';
      }

      // Evitar secuencias ascendentes o descendentes
      for (int i = 0; i < value.length - 3; i++) {
        String subStr = value.substring(i, i + 4);
        if ("0123456789".contains(subStr) || "9876543210".contains(subStr)) {
          return 'El DNI no puede contener secuencias ascendentes o descendentes de más de 3 números';
        }
      }
    } else if (tipoDocumentoSeleccionado == 2) {
      // Validar Pasaporte: 9 a 12 caracteres alfanuméricos, con al menos una letra mayúscula y máximo 3 letras mayúsculas
      RegExp regexPasaporte = RegExp(r'^(?=.*[A-Z])[A-Z0-9]{9,12}$');
      if (!regexPasaporte.hasMatch(value)) {
        return 'El pasaporte debe tener entre 9 y 12 caracteres alfanuméricos, al menos una letra mayúscula y máximo 3 letras mayúsculas';
      }

      // Validar que no haya más de 3 letras consecutivas
      RegExp letrasRepetidas = RegExp(r'[A-Z]{4,}');
      if (letrasRepetidas.hasMatch(value)) {
        return 'El pasaporte no puede contener más de 3 letras consecutivas';
      }

      // Validar que no haya más de 3 números consecutivos iguales
      RegExp numerosRepetidos = RegExp(r'(\d)\1{3,}');
      if (numerosRepetidos.hasMatch(value)) {
        return 'El pasaporte no puede contener más de 3 números consecutivos iguales';
      }

      // Validar que no tenga secuencias ascendentes o descendentes
      for (int i = 0; i < value.length - 3; i++) {
        String subStr = value.substring(i, i + 4);
        if ("0123456789".contains(subStr) || "9876543210".contains(subStr)) {
          return 'El pasaporte no puede contener secuencias ascendentes o descendentes de números';
        }
      }
    } else if (tipoDocumentoSeleccionado == 3) {
      // Validar Carnet de Extranjería: exactamente 12 caracteres alfanuméricos, con al menos una letra mayúscula
      RegExp regexCarnet = RegExp(r'^(?=.*[A-Z])[A-Z0-9]{9,12}$');
      if (!regexCarnet.hasMatch(value)) {
        return 'El Carnet de Extranjería debe tener entre 9 y 12 caracteres alfanuméricoss, al menos una letra mayúscula y máximo 3 letras mayúsculas';
      }

      // Validar que no haya más de 3 letras consecutivas
      RegExp letrasRepetidas = RegExp(r'[A-Z]{4,}');
      if (letrasRepetidas.hasMatch(value)) {
        return 'El Carnet de Extranjería no puede contener más de 3 letras consecutivas';
      }

      // Validar que no haya más de 3 números consecutivos iguales
      RegExp numerosRepetidos = RegExp(r'(\d)\1{3,}');
      if (numerosRepetidos.hasMatch(value)) {
        return 'El Carnet de Extranjería no puede contener más de 3 números consecutivos iguales';
      }

      // Validar que no tenga secuencias ascendentes o descendentes
      for (int i = 0; i < value.length - 3; i++) {
        String subStr = value.substring(i, i + 4);
        if ("0123456789".contains(subStr) || "9876543210".contains(subStr)) {
          return 'El Carnet de Extranjería no puede contener secuencias ascendentes o descendentes de números';
        }
      }
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _cargarTiposDocumentos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF083E6C),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) => HomePage(),
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Center(
                  child: Text(
                    'Registrar Motivo de Visita',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF083E6C),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Selección de tipo de documento
                DropdownButtonFormField<int>(
                  value: tipoDocumentoSeleccionado,
                  items: tiposDocumentos.map((tipo) {
                    return DropdownMenuItem<int>(
                      value: tipo['idTipoDoc'],
                      child: Text(tipo['descripcion']),
                    );
                  }).toList(),
                  decoration: const InputDecoration(
                    labelText: 'Tipo de Documento',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      tipoDocumentoSeleccionado = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Seleccione un tipo de documento';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Número de documento
                TextFormField(
                  controller: _numDocController,
                  focusNode: _numDocFocusNode, // Attach focus node
                  decoration: InputDecoration(
                    labelText: 'Número de Documento',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: _isError
                            ? Colors.red
                            : Colors.blue, // Dynamic color
                        width: 2.0,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: _isError
                            ? Colors.red
                            : Colors.grey, // Dynamic color
                        width: 1.0,
                      ),
                    ),
                  ),
                  keyboardType: TextInputType.text,
                  validator: _validarNumeroDocumento,
                  onChanged: (value) {
                    if (_isError) {
                      setState(() {
                        _isError = false; // Reset error on input
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Motivo de visita
                // Motivo de visita
                TextFormField(
                  controller: _motivoVisitaController,
                  decoration: const InputDecoration(
                    labelText: 'Motivo de la visita',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Este campo es obligatorio';
                    }
                    // Expresión regular para validar letras, tildes y ciertos signos
                    RegExp regex = RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚ\s.,;]+$');
                    if (!regex.hasMatch(value.trim())) {
                      return 'Solo se permiten letras, tildes, espacios y los signos . y ,';
                    }
                    // Validar que no haya espacios consecutivos
                    if (value.contains('  ')) {
                      return 'No se permiten espacios consecutivos';
                    }
                    // Validar que no empiece con un espacio
                    if (value.startsWith(' ')) {
                      return 'No debe empezar con espacios';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Botón para registrar el motivo de visita
                ElevatedButton(
                  onPressed: _registrarMotivoVisita,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF083E6C),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text(
                    'Registrar Motivo de Visita',
                    style: TextStyle(fontSize: 18, color: Colors.white),
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
