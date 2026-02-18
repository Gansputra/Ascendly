import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static Future<void> initialize() async {
    try {
      await dotenv.load(fileName: ".env");
      final url = dotenv.get('SUPABASE_URL');
      final anonKey = dotenv.get('SUPABASE_ANON_KEY');
      
      debugPrint('SupabaseConfig: Initializing with URL: $url');
      debugPrint('SupabaseConfig: Anon Key loaded: ${anonKey.substring(0, 10)}...');

      await Supabase.initialize(
        url: url,
        anonKey: anonKey,
      );
      debugPrint('SupabaseConfig: Initialization successful');
    } catch (e) {
      debugPrint('SupabaseConfig: Error during initialization: $e');
      rethrow;
    }
  }

  static SupabaseClient get client => Supabase.instance.client;
}
