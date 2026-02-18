import 'package:ascendly/core/supabase_config.dart';
import 'package:ascendly/core/theme.dart';
import 'package:ascendly/screens/splash_screen.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase & DotEnv
  try {
    await SupabaseConfig.initialize();
  } catch (e) {
    debugPrint('Supabase/DotEnv initialization failed: $e');
  }

  runApp(const AscendlyApp());
}

class AscendlyApp extends StatelessWidget {
  const AscendlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ascendly',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}
