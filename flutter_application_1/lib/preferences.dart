// Utilidades para guardar y recuperar preferencias del usuario (login, registro, etc)
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class Preferences {
  static const String _emailKey = 'email'; // Clave para el email
  static const String _passwordKey = 'password'; // Clave para la contraseña
  static const String _isLoggedInKey = 'isLoggedIn'; // Clave para el estado de login

  // Guarda las credenciales del usuario
  static Future<void> saveUserCredentials(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_emailKey, email);
    await prefs.setString(_passwordKey, password);
  }

  // Recupera las credenciales del usuario
  static Future<Map<String, String?>> getUserCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'email': prefs.getString(_emailKey),
      'password': prefs.getString(_passwordKey),
    };
  }

  // Verifica si un email ya está registrado
  static Future<bool> isEmailRegistered(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString(_emailKey);
    return savedEmail == email;
  }

  // Marca si el usuario está logueado
  static Future<void> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, value);
  }

  // Verifica si el usuario está logueado
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // Borra los datos del usuario (logout)
  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_emailKey);
    await prefs.remove(_passwordKey);
    await prefs.remove(_isLoggedInKey);
  }

  // Verifica si hay datos de usuario guardados
  static Future<bool> hasUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_emailKey) && prefs.containsKey(_passwordKey);
  }
}

String getBackendBaseUrl() {
  if (kIsWeb) {
    return 'http://localhost:9001'; // Cambia si tu backend está en otra IP para web
  } else if (Platform.isAndroid) {
    return 'http://10.0.2.2:9001'; // Android emulator
  } else if (Platform.isIOS) {
    return 'http://localhost:9001'; // iOS simulator
  } else {
    return 'http://localhost:9001'; // Por defecto para desktop
  }
} 