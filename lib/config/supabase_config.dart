class SupabaseConfig {
  // IMPORTANTE: Reemplaza estos valores con tu configuración de Supabase
  static const String supabaseUrl = 'https://wgwzwsqeomohdonazcyj.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Indnd3p3c3Flb21vaGRvbmF6Y3lqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE5MTk2ODQsImV4cCI6MjA2NzQ5NTY4NH0.p8i6uUoHDnrDFk21b5djs4_SG2Zx4wf8tyhplMUPVZI';

  // Configuración de tablas
  static const String tablaTiposTrabajo = 'tipos_trabajo';

  // Configuración de tiempo de espera
  static const Duration timeoutDuration = Duration(seconds: 30);

  // Configuración de reintentos
  static const int maxRetries = 3;

  // Verificar si la configuración está completa
  static bool get isConfigured =>
      supabaseUrl != 'TU_SUPABASE_URL_AQUI' &&
      supabaseAnonKey != 'TU_SUPABASE_ANON_KEY_AQUI' &&
      supabaseUrl.isNotEmpty &&
      supabaseAnonKey.isNotEmpty;
}
