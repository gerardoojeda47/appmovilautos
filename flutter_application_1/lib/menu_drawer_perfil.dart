// Drawer personalizado para el menú lateral de la app
import 'package:flutter/material.dart';

class MenuDrawerPerfil extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          // Encabezado del Drawer con icono y nombre
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blueAccent,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.account_circle, size: 64, color: Colors.white),
                SizedBox(height: 8),
                Text(
                  'Usuario',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ],
            ),
          ),
          // Opción para ir a la pantalla de inicio
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Inicio'),
            onTap: () {
              Navigator.pop(context);
              // Aquí puedes navegar a la pantalla de inicio
            },
          ),
          // Opción para ir a la pantalla de alquiler de autos
          ListTile(
            leading: Icon(Icons.directions_car),
            title: Text('Alquiler de Autos'),
            onTap: () {
              Navigator.pop(context);
              // Aquí puedes navegar a la pantalla de alquiler de autos
            },
          ),
          // Opción para ir a la pantalla de perfil de usuario
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Perfil'),
            onTap: () {
              Navigator.pop(context);
              // Aquí puedes navegar a la pantalla de perfil
            },
          ),
        ],
      ),
    );
  }
} 