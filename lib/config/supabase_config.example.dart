// Este es un archivo de ejemplo para configurar Supabase
// Copia este archivo como supabase_config.dart y añade tus credenciales

class SupabaseConfig {
  // REEMPLAZA con tu URL de Supabase
  static const String supabaseUrl = 'https://tu-proyecto-id.supabase.co';

  // REEMPLAZA con tu API Key anon/public de Supabase
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';

  // Configuración de tablas
  static const String tablaTiposTrabajo = 'tipos_trabajo';

  // Configuración de tiempo de espera
  static const Duration timeoutDuration = Duration(seconds: 30);

  // Configuración de reintentos
  static const int maxRetries = 3;

  // Verificar si la configuración está completa
  static bool get isConfigured =>
      supabaseUrl != 'https://tu-proyecto-id.supabase.co' &&
      supabaseAnonKey != 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...' &&
      supabaseUrl.isNotEmpty &&
      supabaseAnonKey.isNotEmpty;
}

/*
INSTRUCCIONES DE CONFIGURACIÓN:

1. Ve a https://supabase.com y crea un proyecto
2. En tu dashboard, ve a Settings > API
3. Copia la "URL" y pégala en supabaseUrl
4. Copia la "anon public" key y pégala en supabaseAnonKey
5. Ejecuta el script supabase_setup.sql en tu proyecto
6. Guarda este archivo como lib/config/supabase_config.dart

Ejemplo de configuración:
static const String supabaseUrl = 'https://abcdefghijklmnop.supabase.co';
static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFiY2RlZmdoaWprbG1ub3AiLCJyb2xlIjoiYW5vbiIsImlhdCI6MTY5ODQyMDAwMCwiZXhwIjoyMDEzOTk2MDAwfQ.example-key-here';
*/
