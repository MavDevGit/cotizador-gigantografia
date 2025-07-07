import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/tipo_trabajo.dart';

class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance => _instance ??= SupabaseService._();

  SupabaseService._();

  SupabaseClient get client => Supabase.instance.client;

  // Inicializar Supabase
  static Future<void> initialize({
    required String url,
    required String anonKey,
  }) async {
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );
  }

  // ============ OPERACIONES PARA TIPOS DE TRABAJO ============

  // Obtener todos los tipos de trabajo
  Future<List<TipoTrabajo>> getTiposDeTrabajos() async {
    try {
      final response =
          await client.from('tipos_trabajo').select().order('nombre');

      return (response as List)
          .map((json) => TipoTrabajo.fromJson(json))
          .toList();
    } catch (e) {
      print('Error al obtener tipos de trabajo: $e');
      throw Exception('Error al obtener tipos de trabajo: $e');
    }
  }

  // Crear un nuevo tipo de trabajo
  Future<TipoTrabajo> crearTipoTrabajo(TipoTrabajo tipoTrabajo) async {
    try {
      final response = await client
          .from('tipos_trabajo')
          .insert(tipoTrabajo.toJson())
          .select()
          .single();

      return TipoTrabajo.fromJson(response);
    } catch (e) {
      print('Error al crear tipo de trabajo: $e');
      throw Exception('Error al crear tipo de trabajo: $e');
    }
  }

  // Actualizar un tipo de trabajo existente
  Future<TipoTrabajo> actualizarTipoTrabajo(TipoTrabajo tipoTrabajo) async {
    try {
      final response = await client
          .from('tipos_trabajo')
          .update(tipoTrabajo.toJson())
          .eq('id', tipoTrabajo.id!)
          .select()
          .single();

      return TipoTrabajo.fromJson(response);
    } catch (e) {
      print('Error al actualizar tipo de trabajo: $e');
      throw Exception('Error al actualizar tipo de trabajo: $e');
    }
  }

  // Eliminar un tipo de trabajo
  Future<void> eliminarTipoTrabajo(int id) async {
    try {
      await client.from('tipos_trabajo').delete().eq('id', id);
    } catch (e) {
      print('Error al eliminar tipo de trabajo: $e');
      throw Exception('Error al eliminar tipo de trabajo: $e');
    }
  }

  // Sincronizar tipos de trabajo con datos locales
  Future<void> sincronizarTiposDeTrabajos(
      List<TipoTrabajo> tiposLocales) async {
    try {
      // Primero obtenemos todos los tipos de trabajo existentes
      final tiposRemoto = await getTiposDeTrabajos();

      // Crear un mapa de tipos remotos por nombre para búsqueda rápida
      final tiposRemotoPorNombre = <String, TipoTrabajo>{};
      for (final tipo in tiposRemoto) {
        tiposRemotoPorNombre[tipo.nombre] = tipo;
      }

      // Sincronizar cada tipo local
      for (final tipoLocal in tiposLocales) {
        final tipoRemoto = tiposRemotoPorNombre[tipoLocal.nombre];

        if (tipoRemoto == null) {
          // No existe en remoto, lo creamos
          await crearTipoTrabajo(tipoLocal);
        } else if (tipoRemoto.costo != tipoLocal.costo) {
          // Existe pero con diferentes valores, actualizamos
          final tipoActualizado = tipoLocal.copyWith(id: tipoRemoto.id);
          await actualizarTipoTrabajo(tipoActualizado);
        }
      }
    } catch (e) {
      print('Error al sincronizar tipos de trabajo: $e');
      throw Exception('Error al sincronizar tipos de trabajo: $e');
    }
  }

  // Verificar conectividad con Supabase
  Future<bool> verificarConexion() async {
    try {
      await client.from('tipos_trabajo').select('count').limit(1);
      return true;
    } catch (e) {
      print('Error de conexión con Supabase: $e');
      return false;
    }
  }

  // Obtener estadísticas de sincronización
  Future<Map<String, int>> obtenerEstadisticas() async {
    try {
      final response = await client.from('tipos_trabajo').select('id').count();

      return {
        'total_tipos': response.count,
        'ultima_sincronizacion': DateTime.now().millisecondsSinceEpoch,
      };
    } catch (e) {
      print('Error al obtener estadísticas: $e');
      return {
        'total_tipos': 0,
        'ultima_sincronizacion': 0,
      };
    }
  }
}
