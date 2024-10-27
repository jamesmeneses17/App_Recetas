import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

/// Pantalla de registro de usuario
class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // Mensaje de error para mostrar en caso de fallo en el registro
  String _errorMessage = '';

  /// Expresión regular para validar el formato del correo electrónico
  final RegExp emailRegExp =
      RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$");

  /// Método para manejar el proceso de registro
  Future<void> _register() async {
    if (!emailRegExp.hasMatch(_emailController.text)) {
      // Si el formato del correo no es válido, mostrar alerta
      setState(() {
        _errorMessage = 'Por favor ingrese un formato de correo válido';
      });
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.rightSlide,
        title: 'Formato de correo incorrecto',
        desc: _errorMessage,
        btnOkOnPress: () {},
        btnOkColor: const Color(0xFF2196F3),
        dialogBackgroundColor: Colors.white.withOpacity(0.95),
        descTextStyle: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ).show();
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Las contraseñas no coinciden';
      });
      // Mostrar el mensaje de error con `AwesomeDialog`
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.rightSlide,
        title: 'Error',
        desc: _errorMessage,
        btnOkOnPress: () {},
        btnOkColor: const Color(0xFF2196F3),
        dialogBackgroundColor: Colors.white.withOpacity(0.95),
        descTextStyle: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ).show();
      return;
    }

    try {
      // Intento de crear cuenta con Firebase
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Si el registro es exitoso, mostrar mensaje de éxito
      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.rightSlide,
        title: 'Éxito',
        desc: 'Cuenta creada exitosamente',
        btnOkOnPress: () {
          Navigator.pushReplacementNamed(context, '/home');
        },
      ).show();
    } catch (e) {
      // Gestión de errores en el registro
      String errorMessage = e.toString();
      if (errorMessage.contains('weak-password')) {
        errorMessage =
            'La contraseña es muy débil. Debe tener al menos 6 caracteres.';
      } else if (errorMessage.contains('email-already-in-use')) {
        errorMessage = 'El correo electrónico ya está registrado.';
      } else {
        errorMessage =
            'Error al crear la cuenta. Por favor, inténtalo de nuevo.';
      }

      // Mostrar el mensaje de error con `AwesomeDialog`
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.rightSlide,
        title: 'Error',
        desc: errorMessage,
        btnOkOnPress: () {},
        btnOkColor: const Color(0xFF2196F3),
        dialogBackgroundColor: Colors.white.withOpacity(0.95),
        descTextStyle: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ).show();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Colors.orange[300]!, Colors.orange[700]!],
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icono circular en la parte superior
                      const CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.account_circle,
                          size: 50,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Texto de registro
                      const Text(
                        'CREA TU CUENTA',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 48),

                      // Campo de texto para el correo electrónico
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Correo electrónico',
                          prefixIcon:
                              const Icon(Icons.email, color: Colors.orange),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Campo de texto para la contraseña
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Contraseña',
                          prefixIcon:
                              const Icon(Icons.lock, color: Colors.orange),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Campo de texto para confirmar contraseña
                      TextField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Confirmar contraseña',
                          prefixIcon:
                              const Icon(Icons.lock, color: Colors.orange),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Botón de registrarse
                      ElevatedButton(
                        child: const Text('REGISTRARSE'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2196F3),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 50, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: _register,
                      ),
                      const SizedBox(height: 16),

                      // Enlace para ir a la pantalla de inicio de sesión
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context,
                              '/'); // Navegar a la pantalla de inicio de sesión
                        },
                        child: const Text(
                          '¿Ya tienes cuenta? Iniciar sesión',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
