import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  static const apiKey =
      'AIzaSyCMkzMskuZykC3CxdguaWyBcpljMR6jaq8'; // Substitua pela sua chave API
  late final GenerativeModel _model;

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash', // Modelo atualizado
      apiKey: apiKey,
    );
  }

  Future<String> analyzeMedicineImage(File imageFile) async {
    try {
      final data = await imageFile.readAsBytes();

      final prompt = '''
      Analise esta imagem de medicamento e forneça as seguintes informações em português:
      1. Nome do medicamento
      2. Princípio ativo
      3. Indicações principais
      4. Contraindicações
      5. Efeitos colaterais comuns
      6. Dosagem recomendada
      
      Formate a resposta de forma clara e organizada.
      ''';

      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', data),
        ]),
      ];

      final response = await _model.generateContent(content);

      return response.text ?? 'Não foi possível analisar a imagem.';
    } catch (e) {
      print('Erro detalhado do Gemini: $e'); // Para ajudar no debug
      return 'Erro ao analisar a imagem: $e';
    }
  }
}
