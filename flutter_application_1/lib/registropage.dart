// Pantalla de registro de usuario
import 'package:flutter/material.dart';
import 'package:flutter_application_1/preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Importamos la función getBackendBaseUrl desde preferences.dart

class RegistroPage extends StatefulWidget {
  const RegistroPage({super.key});

  @override
  State<RegistroPage> createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  // Controladores y variables de estado para el formulario
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  // Lógica de registro de usuario
  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Construir la URL del endpoint de registro
      final baseUrl = getBackendBaseUrl();
      final url = '$baseUrl/api/users/registro';
      print('URL de registro: $url'); // Debug: Mostrar URL
      
      // Verificar la URL base
      print('URL base del backend: $baseUrl'); // Debug: Mostrar URL base
      
      final Map<String, dynamic> requestBody = {
        'nombre': _nameController.text,
        'correo': _emailController.text,  // Cambiado de 'email' a 'correo'
        'contraseña': _passwordController.text,  // Cambiado de 'password' a 'contraseña'
        'confirmarContraseña': _confirmPasswordController.text,  // Añadido campo faltante
      };
      
      print('Datos de registro: ${jsonEncode(requestBody)}'); // Debug: Mostrar datos
      
      print('Datos de registro: ${jsonEncode(requestBody)}'); // Debug: Mostrar datos
      
      // Enviar datos al API de registro en Render
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      );
      
      print('Respuesta del servidor: ${response.statusCode}'); // Debug: Mostrar código de estado
      print('Cuerpo de la respuesta: ${response.body}'); // Debug: Mostrar cuerpo de la respuesta

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (!mounted) return;
        // Mostrar alerta de éxito
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Registro exitoso'),
              content: const Text('Tu cuenta ha sido creada correctamente. Ahora puedes iniciar sesión con tus credenciales.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pop(context); // Volver a la pantalla de login
                  },
                  child: const Text('Aceptar'),
                ),
              ],
            );
          },
        );
        // También mostrar un SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registro exitoso'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Intenta extraer mensaje de error del backend
        String errorMsg = 'Error al registrar usuario';
        try {
          final data = jsonDecode(response.body);
          if (data['error'] != null) {
            errorMsg = data['error'];
            // Mensajes personalizados para errores comunes
            if (data['error'] == 'El correo ya está registrado') {
              errorMsg = 'Este correo electrónico ya está en uso. Por favor, utiliza otro.';
            } else if (data['error'] == 'El nombre de usuario ya está en uso') {
              errorMsg = 'Este nombre de usuario ya está en uso. Por favor, elige otro.';
            } else if (data['error'] == 'Las contraseñas no coinciden') {
              errorMsg = 'Las contraseñas no coinciden. Por favor, verifica.';
            } else if (data['camposFaltantes'] != null) {
              final campos = data['camposFaltantes'] as Map<String, dynamic>;
              final faltantes = campos.entries
                  .where((e) => e.value == true)
                  .map((e) => {
                        'correo': 'correo electrónico',
                        'contraseña': 'contraseña',
                        'confirmarContraseña': 'confirmación de contraseña',
                        'nombre': 'nombre'
                      }[e.key] ?? e.key)
                  .join(', ');
              errorMsg = 'Por favor completa los siguientes campos: $faltantes';
            }
          }
        } catch (e) {
          print('Error al procesar la respuesta del servidor: $e');
        }
        if (!mounted) return;
        setState(() {
          _errorMessage = errorMsg;
        });
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
        title: const Text('Registro'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _isLoading ? null : () => Navigator.pop(context),
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
                // Icono de registro
                const Icon(
                  Icons.person_add,
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
                // Campo de nombre
                TextFormField(
                  controller: _nameController,
                  enabled: !_isLoading,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese su nombre';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Nombre',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
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
                const SizedBox(height: 16),
                // Campo de confirmar contraseña
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: !_isConfirmPasswordVisible,
                  enabled: !_isLoading,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor confirme su contraseña';
                    }
                    if (value != _passwordController.text) {
                      return 'Las contraseñas no coinciden';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Confirmar contraseña',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: _isLoading ? null : () {
                        setState(() {
                          _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Botón de registro
                ElevatedButton(
                  onPressed: _isLoading ? null : _register,
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
                          'Registrarse',
                          style: TextStyle(fontSize: 18),
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