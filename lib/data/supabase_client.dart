import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/config/app_config.dart';

/// Initializes the Supabase client once at app startup.
Future<void> initSupabase() async {
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    publishableKey: AppConfig.supabaseAnonKey,
  );
}

/// Convenience getter for the app-wide Supabase client.
SupabaseClient get supabase => Supabase.instance.client;
