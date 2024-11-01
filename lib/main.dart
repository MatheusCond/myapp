import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'dart:async';

void main() async {
  await runZonedGuarded(() async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Configura o tratamento global de erros do Flutter
      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.presentError(details);
        debugPrint('Erro Flutter: ${details.toString()}');
      };

      runApp(const MyApp());
    } catch (e, stackTrace) {
      debugPrint('Erro na inicialização: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }, (error, stackTrace) {
    debugPrint('Erro não tratado: $error');
    debugPrint('Stack trace: $stackTrace');
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 54, 105, 244),
          foregroundColor: Colors.white,
        ),
      ),
      home: const LoginScreen(),
      // Adiciona tratamento global de erros na navegação
      builder: (context, widget) {
        Widget error = const Text('Erro na renderização');
        if (widget is Scaffold || widget is Navigator) {
          error = Scaffold(body: Center(child: error));
        }
        ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 60,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Ocorreu um erro',
                    style: TextStyle(fontSize: 18),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            ),
          );
        };
        return widget ?? error;
      },
      debugShowCheckedModeBanner: false, // Remove o banner de debug
    );
  }
}