import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

/// Pantalla de inicio de sesión
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controladores para los campos de correo y contraseña
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  /// Método para manejar el proceso de inicio de sesión
  Future<void> _login() async {
    try {
      // Intento de autenticación con Firebase usando correo y contraseña
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Si el login es exitoso, mostramos un mensaje de éxito con AwesomeDialog
      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.rightSlide,
        title: 'Éxito',
        desc: 'Inicio de sesión exitoso',
        btnOkOnPress: () {
          Navigator.pushReplacementNamed(context, '/home');
        },
      ).show();
    } catch (e) {
      // Imprime el error completo para entenderlo mejor
      print("Error completo: $e");

      String errorMessage = e.toString();

      if (errorMessage.contains('user-not-found')) {
        errorMessage = 'Este correo no está registrado. Regístrate primero.';
      } else if (errorMessage.contains('wrong-password')) {
        errorMessage = 'Contraseña incorrecta. Por favor, inténtalo de nuevo.';
      } else if (errorMessage.contains('invalid-email')) {
        errorMessage = 'Formato de correo inválido. Por favor, verifica.';
      } else {
        errorMessage = 'Error inesperado. Por favor, inténtalo de nuevo.';
      }

      // Mostrar el diálogo de error con el mensaje correcto
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.rightSlide,
        title: 'Error',
        desc: errorMessage,
        btnOkOnPress: () {},
      ).show();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo degradado
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
                          Icons.restaurant_menu,
                          size: 50,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Texto de bienvenida
                      const Text(
                        'BIENVENIDO',
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
                      const SizedBox(height: 24),

                      // Botón de inicio de sesión
                      ElevatedButton(
                        child: const Text('LOGIN'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2196F3),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 50, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: _login,
                      ),
                      const SizedBox(height: 16),

                      // Enlace para recuperación de contraseña
                      TextButton(
                        child: const Text(
                          '¿Olvidaste tu contraseña?',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          // Implementar recuperación de contraseña
                        },
                      ),
                      const SizedBox(height: 16),

                      // Botón para crear cuenta
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/register');
                        },
                        child: const Text(
                          'Crear cuenta',
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
