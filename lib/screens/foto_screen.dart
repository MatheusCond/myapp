import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class FotoScreen extends StatefulWidget {
  const FotoScreen({super.key});

  @override
  State<FotoScreen> createState() => _FotoScreenState();
}

class _FotoScreenState extends State<FotoScreen> {
  File? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> _getImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Foto')),
      body: Column(
        children: [
          if (_image != null)
            Expanded(
              child: Image.file(
                _image!,
                fit: BoxFit.contain,
              ),
            )
          else
            const Expanded(
              child: Center(
                child: Text('Nenhuma imagem selecionada'),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _getImage(ImageSource.camera),
                  child: const Text('Tirar Foto'),
                ),
                ElevatedButton(
                  onPressed: () => _getImage(ImageSource.gallery),
                  child: const Text('Escolher da Galeria'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
