// Archivo principal de la app Flutter
import 'package:flutter/material.dart';
import 'package:flutter_application_1/calculadorapage.dart';
import 'package:flutter_application_1/loginpage.dart';
import 'package:flutter_application_1/preferences.dart';
import 'package:flutter_application_1/registropage.dart';
import 'package:flutter_application_1/sumapage.dart';
import 'package:flutter_application_1/alquilerauto.dart';

void main() {
  // Punto de entrada de la app
  runApp(const MyApp());
}

// Widget raíz de la aplicación
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your a+++++++++++++++++++++++++++pplication with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const Login(),
    );
  }
}

class LoginCheck extends StatefulWidget {
  const LoginCheck({super.key});

  @override
  State<LoginCheck> createState() => _LoginCheckState();
}

class _LoginCheckState extends State<LoginCheck> {
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final isLoggedIn = await Preferences.isLoggedIn();
    setState(() {
      _isLoggedIn = isLoggedIn;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return _isLoggedIn ? const MyHomePage(title: 'Inicio') : const Login();
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<void> _logout() async {
    await Preferences.clearUserData();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Login()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: const Text('Arithmetic sig in Login'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Login()),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Image.network(
            'https://picsum.photos/536/354',
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          ExpansionTile(
            title: const Text('Suma'),
            leading: const Icon(Icons.add),
            trailing: const Icon(Icons.radio_button_checked),
            children: <Widget>[
              ListTile(
                title: const Text('haz clic para sumar'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SumaPage()),
                  );
                },
              ),
            ],
          ),
          ExpansionTile(
            title: const Text('Calculadora'),
            leading: const Icon(Icons.add),
            trailing: const Icon(Icons.radio_button_checked),
            children: <Widget>[
              ListTile(
                title: const Text('haz clic para Calculadora'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CalculadoraPage()),
                  );
                },
              ),
            ],
          ),
          ExpansionTile(
            title: const Text('Registro'),
            leading: const Icon(Icons.add),
            trailing: const Icon(Icons.radio_button_checked),
            children: <Widget>[
              ListTile(
                title: const Text('haz click para  Registro'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RegistroPage()),
                  );
                },
              ),
            ],
          ),
          ExpansionTile(
            title: const Text('Login'),
            leading: const Icon(Icons.add),
            trailing: const Icon(Icons.radio_button_checked),
            children: <Widget>[
              ListTile(
                title: const Text('haz click para  Login'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Login()),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
