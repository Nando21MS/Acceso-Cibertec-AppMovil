import 'package:accessqr/HomePage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:accessqr/ReportPage.dart';

class VisitorFormPage extends StatefulWidget {
  @override
  _VisitorFormPageState createState() => _VisitorFormPageState();
}

class _VisitorFormPageState extends State<VisitorFormPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombresController = TextEditingController();
  final TextEditingController _apellidosController = TextEditingController();
  final TextEditingController _celularController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _numDocController = TextEditingController();
  final TextEditingController _motivoVisitaController = TextEditingController();

  List<Map<String, dynamic>> tiposDocumentos = [];
  int? tipoDocumentoSeleccionado;
  bool _numDocError = false;

  // Cargar los tipos de documentos desde el backend
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

  // Método para enviar el formulario
  Future<void> _registrarVisitante() async {
    if (_formKey.currentState?.validate() ?? false) {
      final Map<String, dynamic> visitanteData = {
        "usuario": {
          "nombres": _nombresController.text,
          "apellidos": _apellidosController.text,
          "celular": _celularController.text,
          "correo": _correoController.text,
          "numDoc": _numDocController.text,
          "tipodocumento": {
            "idTipoDoc": tipoDocumentoSeleccionado,
          },
        },
        "motivoVisita": _motivoVisitaController.text,
      };

      final String jsonBody = json.encode(visitanteData);
      print('Enviando datos: $jsonBody'); // Debug: imprime los datos enviados

      try {
        final response = await http.post(
          Uri.parse(
              'https://sistema-de-accesos-backend-production.up.railway.app/url/usuario/registrarVisitante'),
          headers: {'Content-Type': 'application/json'},
          body: jsonBody,
        );

        print(
            'Estado de respuesta: ${response.statusCode}'); // Debug: imprime el código de estado
        print(
            'Respuesta del servidor: ${response.body}'); // Debug: imprime el cuerpo de la respuesta

        if (response.statusCode == 200) {
          // Retrieve the visitor's name and document number
          String fullName =
              _nombresController.text + " " + _apellidosController.text;
          String documentNumber = _numDocController.text;
          setState(() {
            _numDocError = false;
          });

          // Clear the form fields
          _nombresController.clear();
          _apellidosController.clear();
          _celularController.clear();
          _correoController.clear();
          _numDocController.clear();
          _motivoVisitaController.clear();
          tipoDocumentoSeleccionado = null;

          Fluttertoast.showToast(
            msg: "Visitante registrado exitosamente",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.green,
            textColor: Colors.white,
          );

          // Navigate to ReportPage with the visitor's details
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => ReportPage(
                fullName: fullName,
                documentNumber: documentNumber,
              ),
            ),
          );
        } else {
          setState(() {
            _numDocError = true;
          });
          Fluttertoast.showToast(
            msg: "${response.body}",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
        }
      } catch (error) {
        print('Error de conexión: $error'); // Debug: imprime el error
        Fluttertoast.showToast(
          msg: "Error de conexión: $error",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    }
  }

  // Validaciones
  String? _validarNombresApellidos(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo es obligatorio';
    }
    if (value.trim().length < 3) {
      return 'Debe tener al menos 3 caracteres';
    }
    // Expresión regular para validar solo letras (con tildes) y espacios (pero no consecutivos)
    RegExp regex = RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚ\s]+$');
    if (!regex.hasMatch(value.trim())) {
      return 'Solo se permiten letras y espacios, sin puntuación ni números';
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
  }

  String? _validarCelular(String? value) {
    if (value == null || value.isEmpty) {
      return 'Este campo es obligatorio';
    }
    RegExp regex = RegExp(r'^9\d{8}$');
    if (!regex.hasMatch(value)) {
      return 'El número de celular debe comenzar con 9 y tener 9 dígitos';
    }
    return null;
  }

  String? _validarCorreo(String? value) {
    if (value == null || value.isEmpty) {
      return 'Este campo es obligatorio';
    }
    // Expresión regular para validar un correo electrónico simple
    RegExp regex = RegExp(
        r'^[a-zA-Z0-9]+([._%+-]?[a-zA-Z0-9]+)*@[a-zA-Z0-9]+\.[a-zA-Z]{2,}$');
    if (!regex.hasMatch(value)) {
      return 'Correo electrónico no válido';
    }
    // Validar que no termine en @cibertec.edu.pe
    if (value.endsWith('@cibertec.edu.pe')) {
      return 'No se permite registrar correos de dominio @cibertec.edu.pe';
    }
    return null;
  }

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

  String? _validarMotivoVisita(String? value) {
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
  }

  @override
  void initState() {
    super.initState();
    _cargarTiposDocumentos();
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
                pageBuilder: (context, animation1, animation2) => HomePage(),
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
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.disabled,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Center(
                  child: Text(
                    'Formulario Para Visita',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF083E6C),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                // Nombre
                TextFormField(
                  controller: _nombresController,
                  decoration: const InputDecoration(
                    labelText: 'Nombres',
                    border: OutlineInputBorder(),
                  ),
                  validator: _validarNombresApellidos,
                ),
                const SizedBox(height: 16),

                // Apellido
                TextFormField(
                  controller: _apellidosController,
                  decoration: const InputDecoration(
                    labelText: 'Apellidos',
                    border: OutlineInputBorder(),
                  ),
                  validator: _validarNombresApellidos,
                ),
                const SizedBox(height: 16),

                // Celular
                TextFormField(
                  controller: _celularController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Celular',
                    border: OutlineInputBorder(),
                  ),
                  validator: _validarCelular,
                ),
                const SizedBox(height: 16),

                // Correo
                TextFormField(
                  controller: _correoController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Correo',
                    border: OutlineInputBorder(),
                  ),
                  validator: _validarCorreo,
                ),
                const SizedBox(height: 16),

                // Tipo de Documento
                DropdownButtonFormField<int>(
                  value: tipoDocumentoSeleccionado,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de Documento',
                    border: OutlineInputBorder(),
                  ),
                  items: tiposDocumentos.map((tipo) {
                    return DropdownMenuItem<int>(
                      value: tipo['idTipoDoc'],
                      child: Text(tipo['descripcion']),
                    );
                  }).toList(),
                  onChanged: (int? value) {
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

                // Número de Documento
                TextFormField(
                  controller: _numDocController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: 'Número de Documento',
                    border: OutlineInputBorder(),
                    errorText: _numDocError ? 'Error en el documento' : null,
                    errorStyle: const TextStyle(color: Colors.red),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: _numDocError ? Colors.red : Colors.blue,
                        width: 2.0,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: _numDocError ? Colors.red : Colors.grey,
                      ),
                    ),
                  ),
                  validator: _validarNumeroDocumento,
                ),
                const SizedBox(height: 16),

                // Motivo de Visita
                TextFormField(
                  controller: _motivoVisitaController,
                  decoration: const InputDecoration(
                    labelText: 'Motivo de Visita',
                    border: OutlineInputBorder(),
                  ),
                  validator: _validarMotivoVisita,
                ),
                const SizedBox(height: 24),

                // Botón de Enviar
                ElevatedButton(
                  onPressed: _registrarVisitante,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF083E6C),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text(
                    'Registrar Visitante',
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
