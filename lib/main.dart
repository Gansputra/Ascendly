import 'package:ascendly/core/supabase_config.dart';
import 'package:ascendly/core/theme.dart';
import 'package:ascendly/providers/app_provider.dart';
import 'package:ascendly/screens/splash_screen.dart';
import 'package:ascendly/services/auth_service.dart';
import 'package:ascendly/screens/main_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: appProvider.themeMode,
      home: StreamBuilder<AuthState>(
        stream: Supabase.instance.client.auth.onAuthStateChange,
        builder: (context, snapshot) {
          // Check both the snapshot and the current session for reliability
          final session = snapshot.data?.session ?? Supabase.instance.client.auth.currentSession;
          if (session != null) {
            return const MainWrapper();
          }
          return const SplashScreen();
        },
      ),
    );
  }
}
