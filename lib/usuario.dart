class Usuario {
  String nombres;
  String apellidos;
  String email;
  String login;
  String dni;

  Usuario({required this.nombres, required this.apellidos, required this.email, required this.login, required this.dni});

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      nombres: json['nombres'],
      apellidos: json['apellidos'],
      email: json['email'],
      login: json['login'],
      dni: json['dni'],
    );
  }
}