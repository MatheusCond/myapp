import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'dart:typed_data';
import 'login_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class FotoScreen extends StatefulWidget {
  const FotoScreen({super.key});

  @override
  State<FotoScreen> createState() => _FotoScreenState();
}

class _FotoScreenState extends State<FotoScreen> {
  File? _image;
  Uint8List? _webImage;
  final ImagePicker _picker = ImagePicker();
  final _auth = FirebaseAuth.instance;
  bool _isAnalyzing = false;
  String _analysisResult = '';

  Future<void> _getImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      if (kIsWeb) {
        // Tratamento para Web
        var bytes = await pickedFile.readAsBytes();
        setState(() {
          _webImage = bytes;
          _analysisResult = '';
        });
      } else {
        // Tratamento para Mobile
        setState(() {
          _image = File(pickedFile.path);
          _analysisResult = '';
        });
      }
      _analyzeMedicine(pickedFile);
    }
  }

  Future<void> _analyzeMedicine(XFile imageFile) async {
    setState(() {
      _isAnalyzing = true;
    });

    try {
      final bytes = await imageFile.readAsBytes();

      final content = [
        Content.multi([
          TextPart('''
          Analise esta imagem de medicamento e forneça as seguintes informações em português:
          1. Nome do medicamento
          2. Princípio ativo
          3. Indicações principais
          4. Contraindicações
          5. Efeitos colaterais comuns
          6. Dosagem recomendada
          
          Por favor, organize a resposta em tópicos claros e bem formatados.
          '''),
          DataPart('image/jpeg', bytes),
        ]),
      ];

      final model = GenerativeModel(
        model: 'gemini-1.5-flash', // Voltando para o modelo estável
        apiKey: 'AIzaSyCMkzMskuZykC3CxdguaWyBcpljMR6jaq8',
      );

      final response = await model.generateContent(content);
      setState(() {
        _analysisResult =
            response.text ?? 'Não foi possível analisar a imagem.';
      });
    } catch (e) {
      setState(() {
        _analysisResult = 'Erro ao analisar a imagem: $e';
      });
      print('Erro detalhado: $e'); // Para debug
    } finally {
      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  Widget _buildImageWidget() {
    if (kIsWeb) {
      if (_webImage != null) {
        return Image.memory(
          _webImage!,
          fit: BoxFit.contain,
        );
      }
    } else {
      if (_image != null) {
        return Image.file(
          _image!,
          fit: BoxFit.contain,
        );
      }
    }
    return const Center(
      child: Text(
        'Nenhuma imagem selecionada',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Análise de Medicamentos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/fundo.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey.withOpacity(0.3),
                  ),
                  child: _buildImageWidget(),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _getImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Tirar Foto'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _getImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Galeria'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (_isAnalyzing)
                  const Center(
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          'Analisando medicamento...',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  )
                else if (_analysisResult.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Resultado da Análise:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(_analysisResult),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _logout() async {
    await _auth.signOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }
}
