import 'package:google_generative_ai/google_generative_ai.dart';

class ChatService {
  final GenerativeModel _model;

  ChatService(String apiKey)
      : _model = GenerativeModel(
          model: 'gemini-1.5-flash-latest',
          apiKey: apiKey,
        );

  Future<String> sendMessage(String userMessage) async {
    final prompt = userMessage;
    final content = [Content.text(prompt)];
    
    try {
      final response = await _model.generateContent(content);
      return response.text ?? 'No response';
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }
}
