import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'config/theme.dart';
import 'services/gemini_service.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.darkBg,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // Optional in production (for example, Vercel deploys using --dart-define).
  }

  try {
    GeminiService.initialize();
  } catch (e) {
    debugPrint('Gemini initialization error: $e');
  }

  runApp(const SpamNewsDetectorApp());
}

class SpamNewsDetectorApp extends StatelessWidget {
  const SpamNewsDetectorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'News Verifier',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const HomeScreen(),
    );
  }
}
