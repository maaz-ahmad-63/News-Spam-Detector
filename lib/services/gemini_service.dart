import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/analysis_result.dart';

class GeminiService {
  static String? _apiKey;
  static const String _model = 'gemini-2.0-flash';
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';
  static const String _apiKeyFromDefine =
      String.fromEnvironment('GEMINI_API_KEY');

  static void initialize() {
    if (_apiKeyFromDefine.isEmpty) {
      throw Exception('GEMINI_API_KEY not set. Build with --dart-define=GEMINI_API_KEY=your_key');
    }
    _apiKey = _apiKeyFromDefine;
  }

  static const String _analysisPrompt = '''
You are an expert fact-checker and misinformation analyst. Analyze the following news content and determine its authenticity.

Provide your analysis in the following EXACT JSON format (no markdown, no code blocks, just pure JSON):
{
  "verdict": "<one of: Real, Fake, Misleading, Satire, Unverifiable>",
  "confidence_score": <a number between 0.0 and 1.0>,
  "summary": "<a 2-3 sentence summary of your analysis>",
  "reasons": ["<reason 1>", "<reason 2>", "<reason 3>"],
  "red_flags": ["<red flag 1>", "<red flag 2>"],
  "suggestions": ["<what the reader should do to verify>", "<additional suggestion>"],
  "category": "<one of: Political, Health, Science, Technology, Entertainment, Finance, Social Media, General>"
}

Important guidelines:
- Look for sensationalist language, emotional manipulation, and clickbait patterns
- Check for logical inconsistencies and unverifiable claims
- Consider the writing style and professionalism
- Look for signs of AI-generated content
- Assess the plausibility of the claims
- If it's a screenshot of a tweet, also consider the context and the claims made in the tweet

Now analyze this content:
''';

  static Future<Map<String, dynamic>> _callGeminiApi(
      Map<String, dynamic> requestBody) async {
    if (_apiKey == null) {
      throw Exception('Gemini service not initialized');
    }

    final url = Uri.parse(
        '$_baseUrl/$_model:generateContent?key=$_apiKey');

    // Retry up to 2 times on rate limit errors
    for (int attempt = 0; attempt < 3; attempt++) {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      if (response.statusCode == 429) {
        if (attempt < 2) {
          // Wait before retrying (10s, then 20s)
          await Future.delayed(Duration(seconds: 10 * (attempt + 1)));
          continue;
        }
        throw Exception(
            'API quota exceeded. The free Gemini tier allows ~15 requests/minute. '
            'Please wait a minute and try again.');
      }

      final errorBody = jsonDecode(response.body);
      final errorMessage =
          errorBody['error']?['message'] ?? 'Unknown API error';
      throw Exception(
          'Gemini API error (${response.statusCode}): $errorMessage');
    }

    throw Exception('Failed after retries');
  }

  static String _extractText(Map<String, dynamic> responseJson) {
    try {
      final candidates = responseJson['candidates'] as List?;
      if (candidates == null || candidates.isEmpty) {
        throw Exception('No response generated');
      }
      final parts = candidates[0]['content']['parts'] as List;
      return parts.map((p) => p['text'] ?? '').join();
    } catch (e) {
      throw Exception('Failed to parse Gemini response: $e');
    }
  }

  static Future<AnalysisResult> analyzeText(String newsText) async {
    final prompt = '$_analysisPrompt\n\n$newsText';

    final requestBody = {
      'contents': [
        {
          'parts': [
            {'text': prompt}
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.3,
        'topP': 0.95,
        'maxOutputTokens': 2048,
      },
    };

    final responseJson = await _callGeminiApi(requestBody);
    final responseText = _extractText(responseJson);
    return _parseResponse(responseText);
  }

  static Future<AnalysisResult> analyzeImage(Uint8List imageBytes, String fileName) async {
    final String mimeType = _getMimeType(fileName);
    final String base64Image = base64Encode(imageBytes);

    final prompt =
        '$_analysisPrompt\n\n[The content is in the attached image - it may be a screenshot of a news article, tweet, or social media post. Extract the text and analyze it.]';

    final requestBody = {
      'contents': [
        {
          'parts': [
            {'text': prompt},
            {
              'inline_data': {
                'mime_type': mimeType,
                'data': base64Image,
              }
            }
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.3,
        'topP': 0.95,
        'maxOutputTokens': 2048,
      },
    };

    final responseJson = await _callGeminiApi(requestBody);
    final responseText = _extractText(responseJson);
    return _parseResponse(responseText);
  }

  static String _getMimeType(String path) {
    final ext = path.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      default:
        return 'image/jpeg';
    }
  }

  static AnalysisResult _parseResponse(String responseText) {
    try {
      String cleaned = responseText.trim();
      if (cleaned.startsWith('```json')) {
        cleaned = cleaned.substring(7);
      } else if (cleaned.startsWith('```')) {
        cleaned = cleaned.substring(3);
      }
      if (cleaned.endsWith('```')) {
        cleaned = cleaned.substring(0, cleaned.length - 3);
      }
      cleaned = cleaned.trim();

      final Map<String, dynamic> json = jsonDecode(cleaned);
      return AnalysisResult.fromParsed(json);
    } catch (e) {
      return AnalysisResult(
        verdict: 'Unverifiable',
        confidenceScore: 0.5,
        summary: responseText.length > 300
            ? '${responseText.substring(0, 300)}...'
            : responseText,
        reasons: ['Unable to parse structured analysis'],
        redFlags: [],
        suggestions: ['Try again or verify manually'],
        category: 'General',
      );
    }
  }
}
