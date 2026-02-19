import 'package:ascendly/core/supabase_config.dart';
import 'package:ascendly/core/theme.dart';
import 'package:ascendly/providers/app_provider.dart';
import 'package:ascendly/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await SupabaseConfig.initialize();
  } catch (e) {
    debugPrint('Supabase/DotEnv initialization failed: $e');
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: const AscendlyApp(),
    ),
  );
}

class AscendlyApp extends StatelessWidget {
  const AscendlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);

    return MaterialApp(
      title: 'Ascendly',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(useMaterial3: true), // Define a basic light theme or use your custom one
      darkTheme: AppTheme.darkTheme,
      themeMode: appProvider.themeMode,
      home: const SplashScreen(),
    );
  }
}
