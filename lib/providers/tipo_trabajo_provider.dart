import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tipo_trabajo.dart';
import '../services/supabase_service.dart';

class TipoTrabajoProvider {
  static TipoTrabajoProvider? _instance;
  static TipoTrabajoProvider get instance =>
      _instance ??= TipoTrabajoProvider._();

  TipoTrabajoProvider._();

  final SupabaseService _supabaseService = SupabaseService.instance;
  static const String _localStorageKey = 'tipos_trabajo';
  static const String _lastSyncKey = 'last_sync_timestamp';

  // ============ OPERACIONES LOCALES ============

  // Guardar tipos de trabajo localmente
  Future<void> _guardarTiposLocalmente(List<TipoTrabajo> tipos) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tiposJson = tipos.map((tipo) => tipo.toJson()).toList();
      await prefs.setString(_localStorageKey, json.encode(tiposJson));
      await prefs.setInt(_lastSyncKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print('Error al guardar tipos localmente: $e');
    }
  }

  // Cargar tipos de trabajo desde almacenamiento local
  Future<List<TipoTrabajo>> _cargarTiposLocalmente() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? tiposJson = prefs.getString(_localStorageKey);

      if (tiposJson != null) {
        final List<dynamic> tiposList = json.decode(tiposJson);
        return tiposList.map((json) => TipoTrabajo.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error al cargar tipos localmente: $e');
      return [];
    }
  }

  // Obtener timestamp de la última sincronización
  Future<DateTime?> _obtenerUltimaSincronizacion() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final int? timestamp = prefs.getInt(_lastSyncKey);
      return timestamp != null
          ? DateTime.fromMillisecondsSinceEpoch(timestamp)
          : null;
    } catch (e) {
      print('Error al obtener última sincronización: $e');
      return null;
    }
  }

  // ============ OPERACIONES PRINCIPALES ============

  // Obtener todos los tipos de trabajo (con fallback local)
  Future<List<TipoTrabajo>> obtenerTiposDeTrabajos(
      {bool forzarRemoto = false}) async {
    try {
      List<TipoTrabajo> tipos = [];

      if (forzarRemoto || await _supabaseService.verificarConexion()) {
        // Intentar obtener desde Supabase
        tipos = await _supabaseService.getTiposDeTrabajos();
        // Guardar localmente como respaldo
        await _guardarTiposLocalmente(tipos);
      } else {
        // Usar datos locales si no hay conexión
        tipos = await _cargarTiposLocalmente();
      }

      return tipos;
    } catch (e) {
      print('Error al obtener tipos de trabajo, usando datos locales: $e');
      // Fallback a datos locales en caso de error
      return await _cargarTiposLocalmente();
    }
  }

  // Crear nuevo tipo de trabajo
  Future<TipoTrabajo> crearTipoTrabajo(TipoTrabajo tipoTrabajo) async {
    try {
      TipoTrabajo nuevoTipo;

      if (await _supabaseService.verificarConexion()) {
        // Crear en Supabase
        nuevoTipo = await _supabaseService.crearTipoTrabajo(tipoTrabajo);
        // Actualizar cache local
        await _actualizarCacheLocal();
      } else {
        // Crear localmente (se sincronizará después)
        nuevoTipo = tipoTrabajo.copyWith(
          id: DateTime.now().millisecondsSinceEpoch, // ID temporal
          createdAt: DateTime.now(),
        );
        await _agregarTipoLocalPendiente(nuevoTipo);
      }

      return nuevoTipo;
    } catch (e) {
      print('Error al crear tipo de trabajo: $e');
      throw Exception('Error al crear tipo de trabajo: $e');
    }
  }

  // Actualizar tipo de trabajo existente
  Future<TipoTrabajo> actualizarTipoTrabajo(TipoTrabajo tipoTrabajo) async {
    try {
      TipoTrabajo tipoActualizado;

      if (await _supabaseService.verificarConexion()) {
        // Actualizar en Supabase
        tipoActualizado =
            await _supabaseService.actualizarTipoTrabajo(tipoTrabajo);
        // Actualizar cache local
        await _actualizarCacheLocal();
      } else {
        // Actualizar localmente (se sincronizará después)
        tipoActualizado = tipoTrabajo.copyWith(updatedAt: DateTime.now());
        await _actualizarTipoLocalPendiente(tipoActualizado);
      }

      return tipoActualizado;
    } catch (e) {
      print('Error al actualizar tipo de trabajo: $e');
      throw Exception('Error al actualizar tipo de trabajo: $e');
    }
  }

  // Eliminar tipo de trabajo
  Future<void> eliminarTipoTrabajo(int id) async {
    try {
      if (await _supabaseService.verificarConexion()) {
        // Eliminar en Supabase
        await _supabaseService.eliminarTipoTrabajo(id);
        // Actualizar cache local
        await _actualizarCacheLocal();
      } else {
        // Marcar como eliminado localmente
        await _marcarTipoEliminadoLocalmente(id);
      }
    } catch (e) {
      print('Error al eliminar tipo de trabajo: $e');
      throw Exception('Error al eliminar tipo de trabajo: $e');
    }
  }

  // Sincronizar datos pendientes
  Future<void> sincronizarDatosPendientes() async {
    try {
      if (!await _supabaseService.verificarConexion()) {
        throw Exception('No hay conexión con Supabase');
      }

      // Obtener cambios pendientes
      final cambiosPendientes = await _obtenerCambiosPendientes();

      // Sincronizar cada cambio
      for (final cambio in cambiosPendientes) {
        await _procesarCambioPendiente(cambio);
      }

      // Limpiar cambios pendientes
      await _limpiarCambiosPendientes();

      // Actualizar cache local con datos remotos
      await _actualizarCacheLocal();
    } catch (e) {
      print('Error al sincronizar datos pendientes: $e');
      throw Exception('Error al sincronizar datos pendientes: $e');
    }
  }

  // Forzar sincronización completa
  Future<void> sincronizacionCompleta() async {
    try {
      if (!await _supabaseService.verificarConexion()) {
        throw Exception('No hay conexión con Supabase');
      }

      // Obtener todos los tipos locales
      final tiposLocales = await _cargarTiposLocalmente();

      // Sincronizar con Supabase
      await _supabaseService.sincronizarTiposDeTrabajos(tiposLocales);

      // Actualizar cache local
      await _actualizarCacheLocal();
    } catch (e) {
      print('Error en sincronización completa: $e');
      throw Exception('Error en sincronización completa: $e');
    }
  }

  // ============ MÉTODOS AUXILIARES ============

  Future<void> _actualizarCacheLocal() async {
    try {
      final tipos = await _supabaseService.getTiposDeTrabajos();
      await _guardarTiposLocalmente(tipos);
    } catch (e) {
      print('Error al actualizar cache local: $e');
    }
  }

  Future<void> _agregarTipoLocalPendiente(TipoTrabajo tipo) async {
    // Implementar lógica para cambios pendientes
    final tipos = await _cargarTiposLocalmente();
    tipos.add(tipo);
    await _guardarTiposLocalmente(tipos);
  }

  Future<void> _actualizarTipoLocalPendiente(TipoTrabajo tipo) async {
    // Implementar lógica para cambios pendientes
    final tipos = await _cargarTiposLocalmente();
    final index = tipos.indexWhere((t) => t.id == tipo.id);
    if (index != -1) {
      tipos[index] = tipo;
      await _guardarTiposLocalmente(tipos);
    }
  }

  Future<void> _marcarTipoEliminadoLocalmente(int id) async {
    // Implementar lógica para cambios pendientes
    final tipos = await _cargarTiposLocalmente();
    tipos.removeWhere((t) => t.id == id);
    await _guardarTiposLocalmente(tipos);
  }

  Future<List<Map<String, dynamic>>> _obtenerCambiosPendientes() async {
    // Implementar lógica para obtener cambios pendientes
    return [];
  }

  Future<void> _procesarCambioPendiente(Map<String, dynamic> cambio) async {
    // Implementar lógica para procesar cambios pendientes
  }

  Future<void> _limpiarCambiosPendientes() async {
    // Implementar lógica para limpiar cambios pendientes
  }

  // Obtener información de estado
  Future<Map<String, dynamic>> obtenerEstadoSincronizacion() async {
    try {
      final ultimaSync = await _obtenerUltimaSincronizacion();
      final tiposLocales = await _cargarTiposLocalmente();
      final conexionRemota = await _supabaseService.verificarConexion();

      return {
        'ultima_sincronizacion': ultimaSync?.toIso8601String(),
        'tipos_locales': tiposLocales.length,
        'conexion_remota': conexionRemota,
        'necesita_sincronizacion': ultimaSync == null ||
            DateTime.now().difference(ultimaSync).inHours > 24,
      };
    } catch (e) {
      print('Error al obtener estado de sincronización: $e');
      return {
        'ultima_sincronizacion': null,
        'tipos_locales': 0,
        'conexion_remota': false,
        'necesita_sincronizacion': true,
      };
    }
  }
}
