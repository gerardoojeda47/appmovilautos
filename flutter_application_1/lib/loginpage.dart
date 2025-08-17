// Pantalla de inicio de sesión de usuario
import 'package:flutter/material.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/preferences.dart';
import 'package:flutter_application_1/registropage.dart';
import 'alquilerauto.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Importamos la función getBackendBaseUrl desde preferences.dart

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  // Controladores y variables de estado para el formulario
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkExistingUser(); // Verifica si ya hay usuario guardado
  }

  // Verifica si hay datos de usuario guardados
  Future<void> _checkExistingUser() async {
    final hasData = await Preferences.hasUserData();
    if (hasData) {
      final credentials = await Preferences.getUserCredentials();
      if (credentials['email'] != null && credentials['password'] != null) {
        setState(() {
          _emailController.text = credentials['email']!;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Lógica de inicio de sesión
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Construir la URL del endpoint de login
      final url = '${getBackendBaseUrl()}/api/users/login';
      print('URL de login: $url'); // Debug: Mostrar URL

      // Crear el cuerpo de la petición con los nombres de campos que espera el backend
      final Map<String, dynamic> requestBody = {
        'correo': _emailController.text,  // Cambiado de 'email' a 'correo'
        'contraseña': _passwordController.text,  // Cambiado de 'password' a 'contraseña'
      };

      print('Datos de login: ${jsonEncode(requestBody)}'); // Debug: Mostrar datos

      // Enviar datos al API de login en Render
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        // Login exitoso
        await Preferences.setLoggedIn(true);
        if (!mounted) return;
        
        // Mostrar SnackBar de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Inicio de sesión exitoso'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Mostrar alerta de bienvenida
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Bienvenido'),
              content: const Text('Has iniciado sesión correctamente.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Navegar a la pantalla principal después de cerrar el diálogo
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => AlquilerAutoScreen()),
                    );
                  },
                  child: const Text('Continuar'),
                ),
              ],
            );
          },
        );
        // No navegamos aquí porque lo haremos después de cerrar el diálogo
      } else {
        // Login fallido, intenta extraer mensaje de error del backend
        String errorMsg = 'Credenciales incorrectas';
        try {
          final data = jsonDecode(response.body);
          if (data['error'] != null) {
            errorMsg = data['error'];
            // Mensajes personalizados para errores comunes
            if (data['error'] == 'Usuario no encontrado') {
              errorMsg = 'No existe una cuenta con este correo electrónico.';
            } else if (data['error'] == 'Contraseña incorrecta') {
              errorMsg = 'La contraseña es incorrecta. Por favor, inténtalo de nuevo.';
            } else if (data['error'] == 'Cuenta no verificada') {
              errorMsg = 'Por favor, verifica tu correo electrónico antes de iniciar sesión.';
            } else if (data['error'] == 'Cuenta deshabilitada') {
              errorMsg = 'Esta cuenta ha sido deshabilitada. Contacta al soporte.';
            }
          } else if (data['message'] != null) {
            errorMsg = data['message'];
          }
        } catch (e) {
          print('Error al procesar la respuesta del servidor: $e');
        }
        if (!mounted) return;
        setState(() {
          _errorMessage = errorMsg;
        });
        
        // Mostrar alerta de error de login
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error de inicio de sesión'),
              content: Text(errorMsg),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Aceptar'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Error de conexión: ${e.toString()}';
      });
      // Mostrar alerta de error de conexión
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error de conexión'),
            content: Text('No se pudo conectar con el servidor. Verifica tu conexión a internet e intenta nuevamente.\n\nDetalle: ${e.toString()}'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Aceptar'),
              ),
            ],
          );
        },
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange[400],
        foregroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => AlquilerAutoScreen()),
            );
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text(
          "Iniciar Sesión",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Icono de usuario
                const Icon(
                  Icons.account_circle,
                  size: 100,
                  color: Colors.orange,
                ),
                const SizedBox(height: 32),
                // Mensaje de error
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red[900]),
                      textAlign: TextAlign.center,
                    ),
                  ),
                // Campo de correo
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  enabled: !_isLoading,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese su correo electrónico';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Por favor ingrese un correo electrónico válido';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Correo electrónico',
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Campo de contraseña
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  enabled: !_isLoading,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese su contraseña';
                    }
                    if (value.length < 6) {
                      return 'La contraseña debe tener al menos 6 caracteres';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: _isLoading ? null : () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Botón de iniciar sesión
                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Iniciar Sesión',
                          style: TextStyle(fontSize: 18),
                        ),
                ),
                const SizedBox(height: 16),
                // Botón para ir a registro
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const RegistroPage()),
                          );
                        },
                  child: const Text(
                    '¿No tienes cuenta? Regístrate',
                    style: TextStyle(color: Colors.orange),
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