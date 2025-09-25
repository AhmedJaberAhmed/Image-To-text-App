import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class GeminiService {
  final String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';

   final String _apiKey = ' ';

  Future<String> analyzeImage(File image) async {
    final bytes = await image.readAsBytes();
    final base64Image = base64Encode(bytes);

    int retries = 3;
    int delaySeconds = 2;

    for (int attempt = 0; attempt < retries; attempt++) {
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': 'Please describe what you see in this image.'},
                {
                  'inline_data': {
                    'mime_type': 'image/jpeg',
                    'data': base64Image,
                  }
                }
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'] ??
            'No description found.';
      } else if (response.statusCode == 503 && attempt < retries - 1) {
         await Future.delayed(Duration(seconds: delaySeconds));
        delaySeconds *= 2;
        continue;
      } else {
        throw Exception(
            "Failed to analyze image: ${response.statusCode} - ${response.body}");
      }
    }

    throw Exception("Image analysis failed after retries.");
  }
}
