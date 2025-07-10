import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/supabase_service.dart';
import 'config/supabase_config.dart';
import 'models/tipo_trabajo.dart';
import 'providers/tipo_trabajo_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Supabase si está configurado
  if (SupabaseConfig.isConfigured) {
    try {
      await SupabaseService.initialize(
        url: SupabaseConfig.supabaseUrl,
        anonKey: SupabaseConfig.supabaseAnonKey,
      );
      print('✅ Supabase inicializado correctamente');
    } catch (e) {
      print('❌ Error al inicializar Supabase: $e');
    }
  } else {
    print('⚠️ Supabase no está configurado. Funcionará solo en modo local.');
  }

  runApp(CotizadorGigantografiaApp());
}

class CotizadorGigantografiaApp extends StatefulWidget {
  @override
  _CotizadorGigantografiaAppState createState() =>
      _CotizadorGigantografiaAppState();
}

class _CotizadorGigantografiaAppState extends State<CotizadorGigantografiaApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistema de Cotizaciones Gigantografía',
      debugShowCheckedModeBanner: false,
      theme: _buildElegantTheme(),
      home: const CotizadorHomePage(),
    );
  }

  ThemeData _buildElegantTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF0AE98A),
        brightness: Brightness.dark,
        primary: const Color(0xFF0AE98A), // Verde Platzi como primario
        secondary: const Color(0xFF13161c), // Fondo principal oscuro
        tertiary: const Color(0xFF1e2229), // Superficies secundarias
        surface: const Color(0xFF1e2229), // Cards y superficies
        background: const Color(0xFF13161c), // Fondo principal
        onPrimary: const Color(0xFF13161c), // Texto sobre verde
        onSecondary: const Color(0xFF0AE98A), // Verde sobre oscuro
        onSurface: const Color(0xFFFFFFFF), // Texto blanco en superficies
        onBackground: const Color(0xFFFFFFFF), // Texto blanco en fondo
        surfaceVariant: const Color(0xFF252930), // Variante de superficie
        onSurfaceVariant: const Color(0xFFB0B3B8), // Texto gris claro
        error: const Color(0xFFFF5252),
        onError: Colors.white,
        outline: const Color(0xFF0AE98A), // Bordes en verde
      ),
      // Botones elevados con estilo Platzi
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: const Color(0xFF0AE98A),
          foregroundColor: const Color(0xFF13161c),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      // Cards con estilo Platzi
      cardTheme: const CardThemeData(
        elevation: 0,
        color: Color(0xFF1e2229),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12))),
        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      // Inputs con estilo Platzi
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF353A42), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF353A42), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF0AE98A), width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        fillColor: const Color(0xFF252930),
        filled: true,
        labelStyle: const TextStyle(color: Color(0xFFB0B3B8)),
        hintStyle: const TextStyle(color: Color(0xFF6B7280)),
      ),
      // AppBar estilo Platzi
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Color(0xFF13161c), // Fondo oscuro principal
        foregroundColor: Color(0xFFFFFFFF), // Texto blanco
        titleTextStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: Color(0xFFFFFFFF),
        ),
        surfaceTintColor: Colors.transparent,
      ),
      // Drawer estilo Platzi
      drawerTheme: const DrawerThemeData(
        backgroundColor: Color(0xFF1e2229),
        surfaceTintColor: Colors.transparent,
      ),
      // SnackBar estilo Platzi
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF0AE98A),
        contentTextStyle: const TextStyle(
            color: Color(0xFF13161c), fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
      ),
      // Text theme con colores Platzi
      textTheme: const TextTheme(
        headlineLarge:
            TextStyle(color: Color(0xFFFFFFFF), fontWeight: FontWeight.w700),
        headlineMedium:
            TextStyle(color: Color(0xFFFFFFFF), fontWeight: FontWeight.w600),
        headlineSmall:
            TextStyle(color: Color(0xFFFFFFFF), fontWeight: FontWeight.w600),
        titleLarge:
            TextStyle(color: Color(0xFFFFFFFF), fontWeight: FontWeight.w600),
        titleMedium:
            TextStyle(color: Color(0xFFFFFFFF), fontWeight: FontWeight.w500),
        titleSmall:
            TextStyle(color: Color(0xFFB0B3B8), fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(color: Color(0xFFFFFFFF)),
        bodyMedium: TextStyle(color: Color(0xFFB0B3B8)),
        bodySmall: TextStyle(color: Color(0xFF6B7280)),
      ),
      // Divider estilo Platzi
      dividerTheme: const DividerThemeData(
        color: Color(0xFF353A42),
        thickness: 1,
      ),
    );
  }
}

// Modelo de datos mejorado para items de cotización
class ItemCotizacion {
  final String tipo;
  final double cantidad;
  final double ancho;
  final double alto;
  final double adicional;
  final double costo;
  final DateTime fechaCreacion;

  ItemCotizacion({
    required this.tipo,
    required this.cantidad,
    required this.ancho,
    required this.alto,
    required this.adicional,
    required this.costo,
    DateTime? fechaCreacion,
  }) : fechaCreacion = fechaCreacion ?? DateTime.now();

  double get metrosCuadrados => ancho * alto * cantidad;
  double get costoBase => metrosCuadrados * (costo - adicional / cantidad);

  Map<String, dynamic> toJson() => {
        'tipo': tipo,
        'cantidad': cantidad,
        'ancho': ancho,
        'alto': alto,
        'adicional': adicional,
        'costo': costo,
        'fechaCreacion': fechaCreacion.toIso8601String(),
      };

  factory ItemCotizacion.fromJson(Map<String, dynamic> json) => ItemCotizacion(
        tipo: json['tipo'],
        cantidad: json['cantidad'].toDouble(),
        ancho: json['ancho'].toDouble(),
        alto: json['alto'].toDouble(),
        adicional: json['adicional']?.toDouble() ?? 0.0,
        costo: json['costo'].toDouble(),
        fechaCreacion:
            DateTime.tryParse(json['fechaCreacion'] ?? '') ?? DateTime.now(),
      );
}

// Página principal renovada con diseño profesional
class CotizadorHomePage extends StatefulWidget {
  const CotizadorHomePage({
    Key? key,
  }) : super(key: key);

  @override
  _CotizadorHomePageState createState() => _CotizadorHomePageState();
}

class _CotizadorHomePageState extends State<CotizadorHomePage>
    with TickerProviderStateMixin {
  Map<String, TipoTrabajo> tiposDeTrabajos = {};
  List<ItemCotizacion> itemsCotizacion = [];
  final TipoTrabajoProvider _tipoTrabajoProvider = TipoTrabajoProvider.instance;
  bool _isLoading = false;
  bool _isSupabaseConnected = false;
  bool _hasRemoteChanges = false; // Indica si hay cambios en la base de datos
  bool _isSyncing = false; // Indica si está sincronizando
  Timer? _syncCheckTimer; // Timer para verificación periódica

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late AnimationController _syncAnimationController;

  // Controladores de texto
  final TextEditingController anchoController = TextEditingController();
  final TextEditingController altoController = TextEditingController();
  final TextEditingController cantidadController =
      TextEditingController(text: '1');
  final TextEditingController adicionalController =
      TextEditingController(text: '0');

  String? tipoSeleccionado;
  double subtotal = 0.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    // Inicializar animación de sincronización
    _syncAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _cargarDatos();
    _setupListeners();
    _verificarConexionSupabase();
    _verificarCambiosRemotos(); // Verificar cambios al iniciar

    // Configurar verificación periódica de cambios remotos (cada 30 segundos)
    _syncCheckTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted && _isSupabaseConnected && !_isSyncing) {
        _verificarCambiosRemotos();
      }
    });
  }

  void _setupListeners() {
    anchoController.addListener(_actualizarSubtotal);
    altoController.addListener(_actualizarSubtotal);
    cantidadController.addListener(_actualizarSubtotal);
    adicionalController.addListener(_actualizarSubtotal);
  }

  Future<void> _verificarConexionSupabase() async {
    if (SupabaseConfig.isConfigured) {
      try {
        final conexion = await SupabaseService.instance.verificarConexion();
        setState(() {
          _isSupabaseConnected = conexion;
        });
      } catch (e) {
        print('Error al verificar conexión con Supabase: $e');
      }
    }
  }

  // Verificar si hay cambios en la base de datos remota
  Future<void> _verificarCambiosRemotos() async {
    if (!SupabaseConfig.isConfigured || !_isSupabaseConnected) {
      setState(() {
        _hasRemoteChanges = false;
      });
      return;
    }

    try {
      // Obtener tipos de trabajo remotos
      final tiposRemotos = await _tipoTrabajoProvider.obtenerTiposDeTrabajos();

      // Comparar con los tipos locales para detectar diferencias
      bool hayDiferencias = false;

      // Verificar si hay diferencias en cantidad
      if (tiposRemotos.length != tiposDeTrabajos.length) {
        hayDiferencias = true;
      } else {
        // Verificar si hay diferencias en contenido
        for (final tipoRemoto in tiposRemotos) {
          final tipoLocal = tiposDeTrabajos[tipoRemoto.nombre];
          if (tipoLocal == null ||
              tipoLocal.costo != tipoRemoto.costo ||
              tipoLocal.id != tipoRemoto.id) {
            hayDiferencias = true;
            break;
          }
        }
      }

      setState(() {
        _hasRemoteChanges = hayDiferencias;
      });

      print(
          '🔍 Verificación de cambios remotos: ${hayDiferencias ? 'HAY CAMBIOS' : 'SIN CAMBIOS'}');
    } catch (e) {
      print('❌ Error al verificar cambios remotos: $e');
      setState(() {
        _hasRemoteChanges = false;
      });
    }
  }

  // Sincronizar datos con Supabase
  Future<void> _sincronizarConSupabase() async {
    if (!SupabaseConfig.isConfigured) {
      _mostrarError('Supabase no está configurado');
      return;
    }

    if (!_isSupabaseConnected) {
      _mostrarError('No hay conexión con Supabase');
      return;
    }

    setState(() {
      _isSyncing = true;
    });

    // Iniciar animación de rotación continua
    _syncAnimationController.repeat();

    try {
      // Obtener datos actualizados de Supabase
      final tiposActualizados =
          await _tipoTrabajoProvider.obtenerTiposDeTrabajos();
      final tiposMap = <String, TipoTrabajo>{};

      // Crear mapa evitando duplicados (usar el más reciente por ID)
      for (final tipo in tiposActualizados) {
        final existing = tiposMap[tipo.nombre];
        if (existing == null ||
            (tipo.id != null &&
                existing.id != null &&
                tipo.id! > existing.id!)) {
          tiposMap[tipo.nombre] = tipo;
        }
      }

      setState(() {
        tiposDeTrabajos = tiposMap;
        _hasRemoteChanges = false; // Ya no hay cambios después de sincronizar

        // Validar que tipoSeleccionado sigue siendo válido
        if (tipoSeleccionado != null &&
            !tiposMap.containsKey(tipoSeleccionado)) {
          tipoSeleccionado = tiposMap.isNotEmpty ? tiposMap.keys.first : null;
        }
      });

      // Guardar datos localmente
      await _guardarDatos();
      _actualizarSubtotal();

      _mostrarExito('Datos sincronizados exitosamente');
      print('✅ Sincronización completada');
    } catch (e) {
      print('❌ Error al sincronizar: $e');
      _mostrarError('Error al sincronizar: $e');
    } finally {
      // Detener animación de rotación
      _syncAnimationController.stop();
      _syncAnimationController.reset();

      setState(() {
        _isSyncing = false;
      });
    }
  }

  Future<void> _cargarDatos() async {
    setState(() => _isLoading = true);

    try {
      final tipos = await _tipoTrabajoProvider.obtenerTiposDeTrabajos();
      final tiposMap = <String, TipoTrabajo>{};

      // Crear mapa evitando duplicados (usar el más reciente por ID)
      for (final tipo in tipos) {
        final existing = tiposMap[tipo.nombre];
        if (existing == null ||
            (tipo.id != null &&
                existing.id != null &&
                tipo.id! > existing.id!)) {
          tiposMap[tipo.nombre] = tipo;
        }
      }

      setState(() {
        tiposDeTrabajos = tiposMap;
        if (tiposDeTrabajos.isNotEmpty) {
          tipoSeleccionado = tiposDeTrabajos.keys.first;
        }
      });

      // Verificar cambios remotos después de cargar datos locales
      await _verificarCambiosRemotos();
    } catch (e) {
      print('Error al cargar datos: $e');
      await _cargarDatosLocales();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _cargarDatosLocales() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tiposJson = prefs.getString('tipos_trabajo');

    if (tiposJson != null) {
      final Map<String, dynamic> tiposMap = json.decode(tiposJson);
      setState(() {
        tiposDeTrabajos = tiposMap
            .map((key, value) => MapEntry(key, TipoTrabajo.fromJson(value)));
      });
    }

    if (tiposDeTrabajos.isNotEmpty) {
      setState(() {
        tipoSeleccionado = tiposDeTrabajos.keys.first;
      });
    }
  }

  Future<void> _guardarDatos() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> tiposMap =
        tiposDeTrabajos.map((key, value) => MapEntry(key, value.toJson()));
    await prefs.setString('tipos_trabajo', json.encode(tiposMap));
  }

  void _actualizarSubtotal() {
    if (tipoSeleccionado == null ||
        !tiposDeTrabajos.containsKey(tipoSeleccionado)) {
      setState(() => subtotal = 0.0);
      return;
    }

    try {
      final trabajo = tiposDeTrabajos[tipoSeleccionado]!;
      final cantidad = double.tryParse(cantidadController.text) ?? 1.0;
      final ancho = double.tryParse(anchoController.text) ?? 0.0;
      final alto = double.tryParse(altoController.text) ?? 0.0;
      final adicional = double.tryParse(adicionalController.text) ?? 0.0;

      setState(() {
        subtotal = (cantidad * ancho * alto * trabajo.costo) + adicional;
      });
    } catch (e) {
      setState(() => subtotal = 0.0);
    }
  }

  void _anadirItem() {
    if (tipoSeleccionado == null ||
        !tiposDeTrabajos.containsKey(tipoSeleccionado)) return;

    try {
      final trabajo = tiposDeTrabajos[tipoSeleccionado]!;
      final cantidad = double.tryParse(cantidadController.text) ?? 1.0;
      final ancho = double.tryParse(anchoController.text) ?? 0.0;
      final alto = double.tryParse(altoController.text) ?? 0.0;
      final adicional = double.tryParse(adicionalController.text) ?? 0.0;
      final costo = (cantidad * ancho * alto * trabajo.costo) + adicional;

      if (costo <= 0 || ancho <= 0 || alto <= 0) {
        _mostrarError(
            'Por favor, ingrese valores válidos para las dimensiones.');
        return;
      }

      setState(() {
        itemsCotizacion.add(ItemCotizacion(
          tipo: trabajo.nombre,
          cantidad: cantidad,
          ancho: ancho,
          alto: alto,
          adicional: adicional,
          costo: costo,
        ));
      });

      _limpiarCampos();
      _mostrarExito('Trabajo añadido exitosamente');
    } catch (e) {
      _mostrarError('Error al añadir el trabajo');
    }
  }

  void _limpiarCampos() {
    anchoController.clear();
    altoController.clear();
    cantidadController.text = '1';
    adicionalController.text = '0';
    _actualizarSubtotal();
  }

  void _eliminarItem(int index) {
    setState(() {
      itemsCotizacion.removeAt(index);
    });
    _mostrarExito('Trabajo eliminado');
  }

  void _editarItem(int index) {
    showDialog(
      context: context,
      builder: (context) => EditarItemDialog(
        item: itemsCotizacion[index],
        tiposDeTrabajos: tiposDeTrabajos,
        onSave: (itemEditado) {
          setState(() {
            itemsCotizacion[index] = itemEditado;
          });
          _mostrarExito('Trabajo actualizado');
        },
      ),
    );
  }

  void _mostrarError(String mensaje) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(mensaje)),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  void _mostrarExito(String mensaje) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Text(mensaje),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  void _mostrarGestionTrabajos() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GestionTrabajosPage(
          tiposDeTrabajos: tiposDeTrabajos,
          isSupabaseConnected: _isSupabaseConnected,
          onSave: (nuevosTipos) async {
            setState(() {
              tiposDeTrabajos = nuevosTipos;
              if (tiposDeTrabajos.isNotEmpty &&
                  !tiposDeTrabajos.containsKey(tipoSeleccionado)) {
                tipoSeleccionado = tiposDeTrabajos.keys.first;
              }
            });
            await _guardarDatos();
            _actualizarSubtotal();
          },
        ),
      ),
    );
  }

  double get total =>
      itemsCotizacion.fold(0.0, (sum, item) => sum + item.costo);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: _buildAppBar(),
      drawer: _buildNavigationDrawer(),
      body: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: _buildBody(),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      titleSpacing: 0,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF0AE98A),
              borderRadius: BorderRadius.circular(8),
            ),
            child:
                const Icon(Icons.calculate, color: Color(0xFF13161c), size: 24),
          ),
          const SizedBox(width: 16),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cotizador',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFFFFFFF)),
              ),
              Text(
                'Gigantografía',
                style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF0AE98A),
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
      backgroundColor: const Color(0xFF13161c),
      foregroundColor: const Color(0xFFFFFFFF),
      elevation: 0,
      actions: [
        if (SupabaseConfig.isConfigured) ...[
          // Indicador de estado de conexión
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _isSupabaseConnected
                  ? const Color(0xFF0AE98A).withOpacity(0.1)
                  : const Color(0xFF252930),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: _isSupabaseConnected
                    ? const Color(0xFF0AE98A)
                    : const Color(0xFF353A42),
                width: 1,
              ),
            ),
            child: Tooltip(
              message: _isSupabaseConnected
                  ? 'Conectado a la nube'
                  : 'Sin conexión a la nube',
              child: Icon(
                _isSupabaseConnected ? Icons.cloud_done : Icons.cloud_off,
                color: _isSupabaseConnected
                    ? const Color(0xFF0AE98A)
                    : const Color(0xFF6B7280),
                size: 18,
              ),
            ),
          ),
          // Botón de sincronización
          if (_isSupabaseConnected)
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
              decoration: BoxDecoration(
                color: _hasRemoteChanges
                    ? const Color(0xFFFF6B6B)
                        .withOpacity(0.1) // Rojo si hay cambios
                    : const Color(0xFF252930),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: _hasRemoteChanges
                      ? const Color(0xFFFF6B6B) // Rojo si hay cambios
                      : const Color(0xFF353A42),
                  width: 1,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(6),
                  onTap: (_isSyncing || _isLoading)
                      ? null
                      : _sincronizarConSupabase,
                  child: Tooltip(
                    message: _hasRemoteChanges
                        ? 'Hay cambios nuevos - Tap para sincronizar'
                        : _isSyncing
                            ? 'Sincronizando...'
                            : 'Datos actualizados',
                    child: Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      child: _isSyncing
                          ? RotationTransition(
                              turns: _syncAnimationController,
                              child: Icon(
                                Icons.sync,
                                color: const Color(0xFF0AE98A),
                                size: 18,
                              ),
                            )
                          : Icon(
                              Icons.sync,
                              color: _hasRemoteChanges
                                  ? const Color(
                                      0xFFFF6B6B) // Rojo si hay cambios
                                  : const Color(
                                      0xFFB0B3B8), // Gris si no hay cambios
                              size: 18,
                            ),
                    ),
                  ),
                ),
              ),
            ),
        ],
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildNavigationDrawer() {
    return Drawer(
      child: Column(
        children: [
          // Header del Drawer
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFF13161c), // Fondo oscuro como Platzi
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0AE98A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.calculate,
                    color: Color(0xFF13161c),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Cotizador',
                      style: TextStyle(
                        color: Color(0xFFFFFFFF),
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Gigantografía',
                      style: TextStyle(
                        color: Color(0xFF0AE98A),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Opciones del menú
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Cotización
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.calculate,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  title: const Text('Nueva Cotización'),
                  subtitle: const Text('Crear cotización'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),

                const Divider(),

                // Gestión de trabajos
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .secondary
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.work_outline,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  title: const Text('Trabajos'),
                  subtitle: const Text('Gestionar precios'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.pop(context);
                    _mostrarGestionTrabajos();
                  },
                ),

                // Historial (placeholder para futuras funcionalidades)
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.history,
                      color: Colors.purple,
                    ),
                  ),
                  title: const Text('Historial'),
                  subtitle: const Text('Cotizaciones anteriores'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.pop(context);
                    _mostrarExito('Función próximamente disponible');
                  },
                ),

                // Reportes
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.assessment,
                      color: Colors.orange,
                    ),
                  ),
                  title: const Text('Reportes'),
                  subtitle: const Text('Estadísticas y reportes'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.pop(context);
                    _mostrarExito('Función próximamente disponible');
                  },
                ),

                const Divider(),

                // Sincronización (si Supabase está configurado)
                if (SupabaseConfig.isConfigured)
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _isSupabaseConnected
                            ? Colors.green.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(
                              Icons.sync,
                              color: _isSupabaseConnected
                                  ? Colors.green
                                  : Colors.grey,
                            ),
                    ),
                    title: const Text('Sincronizar'),
                    subtitle: Text(_isSupabaseConnected
                        ? 'Sincronizar con la nube'
                        : 'Sin conexión a la nube'),
                    enabled: !_isLoading && _isSupabaseConnected,
                    onTap: _isLoading
                        ? null
                        : () {
                            Navigator.pop(context);
                            _sincronizarConSupabase();
                          },
                  ),
              ],
            ),
          ),

          // Footer del drawer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Sistema de Cotizaciones v1.0',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.work_outline,
                      size: 16,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tipos de trabajo: ${tiposDeTrabajos.length}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 1200) {
          return _buildDesktopLayout();
        } else if (constraints.maxWidth > 768) {
          return _buildTabletLayout();
        } else {
          return _buildMobileLayout();
        }
      },
    );
  }

  Widget _buildDesktopLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: _buildFormularioCard(),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 3,
            child: _buildResumenCard(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabletLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildFormularioCard(),
          const SizedBox(height: 16),
          _buildResumenCard(),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          _buildFormularioCard(),
          const SizedBox(height: 8),
          _buildResumenCard(),
        ],
      ),
    );
  }

  Widget _buildFormularioCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildFormularioHeader(),
            const SizedBox(height: 24),
            if (tiposDeTrabajos.isNotEmpty) ...[
              _buildTipoDropdown(),
              const SizedBox(height: 20),
            ],
            _buildDimensionFields(),
            const SizedBox(height: 20),
            _buildSubtotalCard(),
            const SizedBox(height: 20),
            _buildAddButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildFormularioHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1e2229),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF353A42),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0AE98A), Color(0xFF0AE98A)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.add_business,
              color: Color(0xFF13161c),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nuevo Trabajo',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFFFFFFF),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Ingrese los datos del trabajo para calcular el costo',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFFB0B3B8),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0AE98A).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${tiposDeTrabajos.length} tipos disponibles',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF0AE98A),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipoDropdown() {
    // Crear una lista ordenada por ID ascendente y remover duplicados
    final sortedEntries = tiposDeTrabajos.entries.toList()
      ..sort((a, b) {
        final idA = a.value.id ?? 0;
        final idB = b.value.id ?? 0;
        return idA.compareTo(idB);
      });

    // Verificar que tipoSeleccionado sea válido
    if (tipoSeleccionado != null &&
        !tiposDeTrabajos.containsKey(tipoSeleccionado)) {
      tipoSeleccionado =
          tiposDeTrabajos.isNotEmpty ? tiposDeTrabajos.keys.first : null;
    }

    return DropdownButtonFormField<String>(
      value: tipoSeleccionado,
      decoration: InputDecoration(
        labelText: 'Tipo de Trabajo',
        prefixIcon: const Icon(Icons.work_outline),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: sortedEntries.map((entry) {
        final nombre = entry.key;
        final tipo = entry.value;
        return DropdownMenuItem<String>(
          value: nombre,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(child: Text(nombre)),
              const SizedBox(width: 8),
              Text(
                'Bs ${tipo.costo.toStringAsFixed(2)}/m²',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          tipoSeleccionado = newValue;
        });
        _actualizarSubtotal();
      },
    );
  }

  Widget _buildDimensionFields() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          return Row(
            children: [
              Expanded(
                  child: _buildTextField(
                      anchoController, 'Ancho (m)', Icons.straighten)),
              const SizedBox(width: 16),
              Expanded(
                  child: _buildTextField(
                      altoController, 'Alto (m)', Icons.height)),
              const SizedBox(width: 16),
              Expanded(
                  child: _buildTextField(cantidadController, 'Cantidad',
                      Icons.format_list_numbered)),
              const SizedBox(width: 16),
              Expanded(
                  child: _buildTextField(adicionalController, 'Adicional (Bs)',
                      Icons.attach_money)),
            ],
          );
        } else {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                      child: _buildTextField(
                          anchoController, 'Ancho (m)', Icons.straighten)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _buildTextField(
                          altoController, 'Alto (m)', Icons.height)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                      child: _buildTextField(cantidadController, 'Cantidad',
                          Icons.format_list_numbered)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _buildTextField(adicionalController,
                          'Adicional (Bs)', Icons.attach_money)),
                ],
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
    );
  }

  Widget _buildSubtotalCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1e2229), // Superficie oscura estilo Platzi
        borderRadius: BorderRadius.circular(12),
        border: subtotal > 0
            ? Border.all(
                color: const Color(0xFF0AE98A).withOpacity(0.3), width: 1)
            : Border.all(color: const Color(0xFF353A42), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: subtotal > 0
                      ? const Color(0xFF0AE98A).withOpacity(0.1)
                      : const Color(0xFF353A42).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.calculate,
                  color: subtotal > 0
                      ? const Color(0xFF0AE98A)
                      : const Color(0xFF6B7280),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'SUBTOTAL',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: subtotal > 0
                      ? const Color(0xFF0AE98A)
                      : const Color(0xFF6B7280),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (subtotal > 0) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getMetrosCuadradosText(),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFFB0B3B8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tipoSeleccionado ?? '',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                const Text(
                  'Vacio',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
              Text(
                'Bs ${subtotal.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: subtotal > 0 ? 28 : 24,
                  fontWeight: FontWeight.w700,
                  color: subtotal > 0
                      ? const Color(0xFFFFFFFF)
                      : const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getMetrosCuadradosText() {
    final cantidad = double.tryParse(cantidadController.text) ?? 0.0;
    final ancho = double.tryParse(anchoController.text) ?? 0.0;
    final alto = double.tryParse(altoController.text) ?? 0.0;
    final metrosCuadrados = cantidad * ancho * alto;
    return '${metrosCuadrados.toStringAsFixed(2)} m²';
  }

  Widget _buildAddButton() {
    final isEnabled = subtotal > 0;

    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: isEnabled
            ? const LinearGradient(
                colors: [Color(0xFF0AE98A), Color(0xFF0AE98A)],
              )
            : null,
        color: isEnabled ? null : const Color(0xFF252930),
        border: isEnabled
            ? null
            : Border.all(color: const Color(0xFF353A42), width: 1),
      ),
      child: ElevatedButton.icon(
        onPressed: isEnabled ? _anadirItem : null,
        icon: Icon(
          Icons.add_circle_outline,
          size: 20,
          color: isEnabled ? const Color(0xFF13161c) : const Color(0xFF6B7280),
        ),
        label: Text(
          'AÑADIR TRABAJO',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            color:
                isEnabled ? const Color(0xFF13161c) : const Color(0xFF6B7280),
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }

  Widget _buildResumenCard() {
    return SizedBox(
      height: 600, // Altura fija para el resumen
      child: Card(
        child: Column(
          children: [
            _buildResumenHeader(),
            Expanded(child: _buildResumenBody()),
            if (itemsCotizacion.isNotEmpty) _buildTotalFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildResumenHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF1e2229), // Superficie estilo Platzi
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF0AE98A).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: const Color(0xFF0AE98A).withOpacity(0.3), width: 1),
            ),
            child: const Icon(
              Icons.receipt_long,
              color: Color(0xFF0AE98A),
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cotización',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFFFFFFF),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  itemsCotizacion.isEmpty
                      ? 'No hay trabajos añadidos'
                      : '${itemsCotizacion.length} trabajo${itemsCotizacion.length > 1 ? 's' : ''} • ${_getTotalMetrosCuadrados().toStringAsFixed(2)} m²',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFFB0B3B8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (itemsCotizacion.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF0AE98A).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: const Color(0xFF0AE98A).withOpacity(0.3), width: 1),
              ),
              child: Text(
                'Bs ${total.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0AE98A),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF252930),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFF353A42),
                  width: 1,
                ),
              ),
              child: PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert,
                    color: Color(0xFFB0B3B8), size: 20),
                tooltip: 'Más opciones',
                color: const Color(0xFF252930),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: Color(0xFF353A42)),
                ),
                onSelected: (value) {
                  if (value == 'clear_all') {
                    _limpiarTodaLaCotizacion();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'clear_all',
                    child: Row(
                      children: [
                        Icon(Icons.clear_all, color: Colors.red, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Limpiar cotización',
                          style: TextStyle(color: Color(0xFFFFFFFF)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Método helper para calcular el total de metros cuadrados
  double _getTotalMetrosCuadrados() {
    return itemsCotizacion.fold(0.0, (sum, item) => sum + item.metrosCuadrados);
  }

  Widget _buildResumenBody() {
    if (itemsCotizacion.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: itemsCotizacion.length,
      itemBuilder: (context, index) => _buildItemCard(index),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFF1e2229),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF353A42),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.description_outlined,
              size: 48,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No hay trabajos añadidos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFFFFFFFF),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Completa el formulario y añade tu primer trabajo\npara comenzar con la cotización',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFFB0B3B8),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF0AE98A).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF0AE98A).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  size: 16,
                  color: Color(0xFF0AE98A),
                ),
                SizedBox(width: 6),
                Text(
                  'Tip: Selecciona el tipo de trabajo y llena las dimensiones',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF0AE98A),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(int index) {
    final item = itemsCotizacion[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1e2229),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF353A42),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF0AE98A).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFF0AE98A).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.work_outline,
              color: Color(0xFF0AE98A),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.tipo,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFFFFFFF),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${item.cantidad.toStringAsFixed(0)} × ${item.ancho}m × ${item.alto}m',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFFB0B3B8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0AE98A).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${item.metrosCuadrados.toStringAsFixed(2)} m²',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF0AE98A),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (item.adicional > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '+Bs ${item.adicional.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.orange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Bs ${item.costo.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0AE98A),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF252930),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF353A42),
                        width: 1,
                      ),
                    ),
                    child: IconButton(
                      onPressed: () => _editarItem(index),
                      icon: const Icon(Icons.edit_outlined),
                      iconSize: 18,
                      color: const Color(0xFFB0B3B8),
                      tooltip: 'Editar',
                      padding: const EdgeInsets.all(8),
                      constraints:
                          const BoxConstraints(minWidth: 36, minHeight: 36),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF252930),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF353A42),
                        width: 1,
                      ),
                    ),
                    child: IconButton(
                      onPressed: () => _eliminarItem(index),
                      icon: const Icon(Icons.delete_outline),
                      iconSize: 18,
                      color: Colors.red.withOpacity(0.8),
                      tooltip: 'Eliminar',
                      padding: const EdgeInsets.all(8),
                      constraints:
                          const BoxConstraints(minWidth: 36, minHeight: 36),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotalFooter() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF0AE98A),
            Color(0xFF0AE98A),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF13161c).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.attach_money,
                      color: Color(0xFF13161c),
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'TOTAL GENERAL',
                    style: TextStyle(
                      color: Color(0xFF13161c),
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${itemsCotizacion.length} trabajo${itemsCotizacion.length > 1 ? 's' : ''} • ${_getTotalMetrosCuadrados().toStringAsFixed(2)} m²',
                style: TextStyle(
                  color: const Color(0xFF13161c).withOpacity(0.7),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF13161c).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Bs ${total.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Color(0xFF13161c),
                fontWeight: FontWeight.w700,
                fontSize: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _limpiarTodaLaCotizacion() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1e2229),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF353A42)),
        ),
        title: const Text(
          'Limpiar Cotización',
          style: TextStyle(
            color: Color(0xFFFFFFFF),
            fontWeight: FontWeight.w600,
          ),
        ),
        content: const Text(
          '¿Estás seguro de que deseas limpiar toda la cotización?\n\nSe eliminarán todos los trabajos añadidos.',
          style: TextStyle(color: Color(0xFFB0B3B8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Color(0xFFB0B3B8)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                itemsCotizacion.clear();
              });
              _mostrarExito('Cotización limpiada exitosamente');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Limpiar Todo'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    anchoController.dispose();
    altoController.dispose();
    cantidadController.dispose();
    adicionalController.dispose();
    _animationController.dispose();
    _syncAnimationController.dispose();
    _syncCheckTimer?.cancel(); // Cancelar timer de verificación
    super.dispose();
  }
}

// Diálogo para editar items
class EditarItemDialog extends StatefulWidget {
  final ItemCotizacion item;
  final Map<String, TipoTrabajo> tiposDeTrabajos;
  final Function(ItemCotizacion) onSave;

  const EditarItemDialog({
    Key? key,
    required this.item,
    required this.tiposDeTrabajos,
    required this.onSave,
  }) : super(key: key);

  @override
  _EditarItemDialogState createState() => _EditarItemDialogState();
}

class _EditarItemDialogState extends State<EditarItemDialog> {
  final TextEditingController anchoController = TextEditingController();
  final TextEditingController altoController = TextEditingController();
  final TextEditingController cantidadController = TextEditingController();
  final TextEditingController adicionalController = TextEditingController();

  String? tipoSeleccionado;
  double subtotal = 0.0;

  @override
  void initState() {
    super.initState();
    tipoSeleccionado = widget.item.tipo;
    anchoController.text = widget.item.ancho.toString();
    altoController.text = widget.item.alto.toString();
    cantidadController.text = widget.item.cantidad.toString();
    adicionalController.text = widget.item.adicional.toString();

    _setupListeners();
    _actualizarSubtotal();
  }

  void _setupListeners() {
    anchoController.addListener(_actualizarSubtotal);
    altoController.addListener(_actualizarSubtotal);
    cantidadController.addListener(_actualizarSubtotal);
    adicionalController.addListener(_actualizarSubtotal);
  }

  void _actualizarSubtotal() {
    if (tipoSeleccionado == null ||
        !widget.tiposDeTrabajos.containsKey(tipoSeleccionado)) {
      setState(() => subtotal = 0.0);
      return;
    }

    try {
      final trabajo = widget.tiposDeTrabajos[tipoSeleccionado]!;
      final cantidad = double.tryParse(cantidadController.text) ?? 1.0;
      final ancho = double.tryParse(anchoController.text) ?? 0.0;
      final alto = double.tryParse(altoController.text) ?? 0.0;
      final adicional = double.tryParse(adicionalController.text) ?? 0.0;

      setState(() {
        subtotal = (cantidad * ancho * alto * trabajo.costo) + adicional;
      });
    } catch (e) {
      setState(() => subtotal = 0.0);
    }
  }

  void _guardarCambios() {
    if (tipoSeleccionado == null) return;

    try {
      final trabajo = widget.tiposDeTrabajos[tipoSeleccionado]!;
      final cantidad = double.tryParse(cantidadController.text) ?? 1.0;
      final ancho = double.tryParse(anchoController.text) ?? 0.0;
      final alto = double.tryParse(altoController.text) ?? 0.0;
      final adicional = double.tryParse(adicionalController.text) ?? 0.0;
      final costo = (cantidad * ancho * alto * trabajo.costo) + adicional;

      if (costo <= 0 || ancho <= 0 || alto <= 0) return;

      final itemEditado = ItemCotizacion(
        tipo: trabajo.nombre,
        cantidad: cantidad,
        ancho: ancho,
        alto: alto,
        adicional: adicional,
        costo: costo,
        fechaCreacion: widget.item.fechaCreacion,
      );

      widget.onSave(itemEditado);
      Navigator.of(context).pop();
    } catch (e) {
      // Error handling
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.edit,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Editar Trabajo',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField<String>(
              value: tipoSeleccionado,
              decoration: InputDecoration(
                labelText: 'Tipo de Trabajo',
                prefixIcon: const Icon(Icons.work_outline),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              items: () {
                // Crear una lista ordenada por ID ascendente
                final sortedEntries = widget.tiposDeTrabajos.entries.toList()
                  ..sort((a, b) {
                    final idA = a.value.id ?? 0;
                    final idB = b.value.id ?? 0;
                    return idA.compareTo(idB);
                  });

                return sortedEntries.map((entry) {
                  final nombre = entry.key;
                  final tipo = entry.value;
                  return DropdownMenuItem<String>(
                    value: nombre,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(child: Text(nombre)),
                        const SizedBox(width: 8),
                        Text(
                          'Bs ${tipo.costo.toStringAsFixed(2)}/m²',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ],
                    ),
                  );
                }).toList();
              }(),
              onChanged: (String? newValue) {
                setState(() {
                  tipoSeleccionado = newValue;
                });
                _actualizarSubtotal();
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: anchoController,
                    decoration: const InputDecoration(
                      labelText: 'Ancho (m)',
                      prefixIcon: Icon(Icons.straighten),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: altoController,
                    decoration: const InputDecoration(
                      labelText: 'Alto (m)',
                      prefixIcon: Icon(Icons.height),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: cantidadController,
                    decoration: const InputDecoration(
                      labelText: 'Cantidad',
                      prefixIcon: Icon(Icons.format_list_numbered),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: adicionalController,
                    decoration: const InputDecoration(
                      labelText: 'Adicional (Bs)',
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'NUEVO TOTAL:',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    'Bs ${subtotal.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: subtotal > 0 ? _guardarCambios : null,
                    child: const Text('Guardar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    anchoController.dispose();
    altoController.dispose();
    cantidadController.dispose();
    adicionalController.dispose();
    super.dispose();
  }
}

// Página de gestión de trabajos completa y profesional
class GestionTrabajosPage extends StatefulWidget {
  final Map<String, TipoTrabajo> tiposDeTrabajos;
  final Function(Map<String, TipoTrabajo>) onSave;
  final bool isSupabaseConnected;

  const GestionTrabajosPage({
    Key? key,
    required this.tiposDeTrabajos,
    required this.onSave,
    required this.isSupabaseConnected,
  }) : super(key: key);

  @override
  _GestionTrabajosPageState createState() => _GestionTrabajosPageState();
}

class _GestionTrabajosPageState extends State<GestionTrabajosPage>
    with TickerProviderStateMixin {
  late Map<String, TipoTrabajo> tiposLocales;
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController costoController = TextEditingController();
  final TipoTrabajoProvider _tipoTrabajoProvider = TipoTrabajoProvider.instance;

  String? tipoSeleccionado;
  bool _isLoading = false;
  bool _isExpanded = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late AnimationController _syncAnimationController;

  @override
  void initState() {
    super.initState();
    tiposLocales = Map.from(widget.tiposDeTrabajos);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    // Inicializar animación de sincronización
    _syncAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: _buildAppBar(),
        body: AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: _buildBody(),
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      titleSpacing: 0,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF0AE98A),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.settings,
              color: Color(0xFF13161c),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Gestión de Trabajos',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFFFFFFF),
                ),
              ),
              Text(
                'Configurar tipos y precios',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF0AE98A),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
      backgroundColor: const Color(0xFF13161c),
      foregroundColor: const Color(0xFFFFFFFF),
      elevation: 0,
      actions: [
        if (SupabaseConfig.isConfigured) ...[
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: widget.isSupabaseConnected
                  ? const Color(0xFF0AE98A).withOpacity(0.1)
                  : const Color(0xFF252930),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: widget.isSupabaseConnected
                    ? const Color(0xFF0AE98A)
                    : const Color(0xFF353A42),
                width: 1,
              ),
            ),
            child: Icon(
              widget.isSupabaseConnected ? Icons.cloud_done : Icons.cloud_off,
              color: widget.isSupabaseConnected
                  ? const Color(0xFF0AE98A)
                  : const Color(0xFF6B7280),
              size: 18,
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF252930),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: const Color(0xFF353A42),
                width: 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(6),
                onTap: _isLoading ? null : _sincronizarConSupabase,
                child: Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  child: _isLoading
                      ? RotationTransition(
                          turns: _syncAnimationController,
                          child: Icon(
                            Icons.sync,
                            color: const Color(0xFF0AE98A),
                            size: 18,
                          ),
                        )
                      : Icon(
                          Icons.sync,
                          color: const Color(0xFFB0B3B8),
                          size: 18,
                        ),
                ),
              ),
            ),
          ),
        ],
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildBody() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 1000) {
          return _buildDesktopLayout();
        } else if (constraints.maxWidth > 600) {
          return _buildTabletLayout();
        } else {
          return _buildMobileLayout();
        }
      },
    );
  }

  Widget _buildDesktopLayout() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Panel izquierdo - Formulario
          Expanded(
            flex: 2,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: _buildFormulario(),
              ),
            ),
          ),
          const SizedBox(width: 24),
          // Panel derecho - Lista de trabajos
          Expanded(
            flex: 3,
            child: Card(
              child: Column(
                children: [
                  _buildListHeader(),
                  Expanded(child: _buildListaBody()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabletLayout() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Formulario en la parte superior
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: _buildFormulario(),
            ),
          ),
          const SizedBox(height: 16),
          // Lista en la parte inferior
          Expanded(
            child: Card(
              child: Column(
                children: [
                  _buildListHeader(),
                  Expanded(child: _buildListaBody()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        // Formulario colapsible en móvil
        ExpansionTile(
          key: ValueKey(
              'expansion_tile_${tipoSeleccionado ?? 'new'}_$_isExpanded'),
          title: const Text('Añadir/Editar Trabajo'),
          subtitle: Text(tipoSeleccionado != null
              ? 'Editando: $tipoSeleccionado'
              : 'Tap para añadir nuevo trabajo'),
          leading: const Icon(Icons.add_business),
          initiallyExpanded: _isExpanded,
          onExpansionChanged: (expanded) {
            setState(() {
              _isExpanded = expanded;
            });
            print('🎯 ExpansionTile cambió a: $expanded');
          },
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: _buildFormulario(),
            ),
          ],
        ),
        // Header de la lista
        _buildListHeader(),
        // Lista de trabajos
        Expanded(child: _buildListaBody()),
      ],
    );
  }

  Widget _buildFormulario() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1e2229),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF353A42),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header del formulario
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF252930),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF353A42),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0AE98A), Color(0xFF0AE98A)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    tipoSeleccionado != null ? Icons.edit : Icons.add_business,
                    color: const Color(0xFF13161c),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tipoSeleccionado != null
                            ? 'Editar Trabajo'
                            : 'Nuevo Trabajo',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFFFFFFF),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        tipoSeleccionado != null
                            ? 'Modificar información del trabajo'
                            : 'Agregar nuevo tipo de trabajo',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFFB0B3B8),
                        ),
                      ),
                    ],
                  ),
                ),
                if (tipoSeleccionado != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0AE98A).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'EDITANDO',
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF0AE98A),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Campo Nombre
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: nombreController,
              style: const TextStyle(color: Color(0xFFFFFFFF)),
              decoration: InputDecoration(
                labelText: 'Nombre del trabajo',
                hintText: 'Ej: Lona impresa, Banner, Vinilo...',
                prefixIcon:
                    const Icon(Icons.work_outline, color: Color(0xFFB0B3B8)),
                labelStyle: const TextStyle(color: Color(0xFFB0B3B8)),
                hintStyle: const TextStyle(color: Color(0xFF6B7280)),
                filled: true,
                fillColor: const Color(0xFF252930),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF353A42)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF353A42)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      const BorderSide(color: Color(0xFF0AE98A), width: 2),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Campo Costo
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: costoController,
              style: const TextStyle(color: Color(0xFFFFFFFF)),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Costo por m²',
                hintText: '0.00',
                prefixIcon:
                    const Icon(Icons.attach_money, color: Color(0xFFB0B3B8)),
                suffixText: 'Bs/m²',
                suffixStyle: const TextStyle(
                    color: Color(0xFF0AE98A), fontWeight: FontWeight.w500),
                labelStyle: const TextStyle(color: Color(0xFFB0B3B8)),
                hintStyle: const TextStyle(color: Color(0xFF6B7280)),
                filled: true,
                fillColor: const Color(0xFF252930),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF353A42)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF353A42)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      const BorderSide(color: Color(0xFF0AE98A), width: 2),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Botones de acción
          if (tipoSeleccionado != null) ...[
            // Modo edición: mostrar Actualizar, Eliminar y Cancelar
            Column(
              children: [
                // Botón Actualizar
                Container(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0AE98A), Color(0xFF0AE98A)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _actualizarTrabajo,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF13161c)),
                            ),
                          )
                        : const Icon(Icons.update,
                            color: Color(0xFF13161c), size: 18),
                    label: Text(
                      _isLoading ? 'ACTUALIZANDO...' : 'ACTUALIZAR TRABAJO',
                      style: TextStyle(
                        color: _isLoading
                            ? const Color(0xFF13161c).withOpacity(0.7)
                            : const Color(0xFF13161c),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Botones Eliminar y Cancelar
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border:
                              Border.all(color: Colors.red.withOpacity(0.3)),
                        ),
                        child: ElevatedButton.icon(
                          onPressed: _eliminarTrabajo,
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.red, size: 18),
                          label: const Text(
                            'ELIMINAR',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFF252930),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF353A42)),
                        ),
                        child: ElevatedButton.icon(
                          onPressed: _limpiarFormulario,
                          icon: const Icon(Icons.clear,
                              color: Color(0xFFB0B3B8), size: 18),
                          label: const Text(
                            'CANCELAR',
                            style: TextStyle(
                              color: Color(0xFFB0B3B8),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ] else ...[
            // Modo creación: mostrar solo Añadir
            Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0AE98A), Color(0xFF0AE98A)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _anadirTrabajo,
                icon: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFF13161c)),
                        ),
                      )
                    : const Icon(Icons.add_circle_outline,
                        color: Color(0xFF13161c), size: 18),
                label: Text(
                  _isLoading ? 'GUARDANDO...' : 'AÑADIR TRABAJO',
                  style: TextStyle(
                    color: _isLoading
                        ? const Color(0xFF13161c).withOpacity(0.7)
                        : const Color(0xFF13161c),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildListHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF1e2229),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF0AE98A).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF0AE98A).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.format_list_bulleted,
              color: Color(0xFF0AE98A),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tipos de Trabajo',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFFFFFFF),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${tiposLocales.length} tipo${tiposLocales.length != 1 ? 's' : ''} configurado${tiposLocales.length != 1 ? 's' : ''}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFFB0B3B8),
                  ),
                ),
              ],
            ),
          ),
          if (tiposLocales.isNotEmpty) ...[
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF252930),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFF353A42),
                  width: 1,
                ),
              ),
              child: PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert,
                    color: Color(0xFFB0B3B8), size: 20),
                tooltip: 'Más opciones',
                color: const Color(0xFF252930),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: Color(0xFF353A42)),
                ),
                onSelected: (value) {
                  if (value == 'clear_all') {
                    _confirmarLimpiarTodo();
                  } else if (value == 'export') {
                    _exportarDatos();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'export',
                    child: Row(
                      children: [
                        Icon(Icons.download,
                            color: Color(0xFF0AE98A), size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Exportar datos',
                          style: TextStyle(color: Color(0xFFFFFFFF)),
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'clear_all',
                    child: Row(
                      children: [
                        Icon(Icons.clear_all, color: Colors.red, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Limpiar todo',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildListaBody() {
    if (tiposLocales.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tiposLocales.length,
      itemBuilder: (context, index) {
        final entry = tiposLocales.entries.elementAt(index);
        return _buildTrabajoCard(entry.key, entry.value, index);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFF1e2229),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF353A42),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.work_off_outlined,
              size: 48,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No hay tipos de trabajo',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFFFFFFFF),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Comienza agregando tu primer tipo de trabajo\ncon el formulario de la izquierda',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFFB0B3B8),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF0AE98A).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF0AE98A).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  size: 16,
                  color: Color(0xFF0AE98A),
                ),
                SizedBox(width: 6),
                Text(
                  'Tip: Define nombre y precio por metro cuadrado',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF0AE98A),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrabajoCard(String nombre, TipoTrabajo trabajo, int index) {
    final isSelected = tipoSeleccionado == nombre;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFF0AE98A).withOpacity(0.1)
            : const Color(0xFF1e2229),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? const Color(0xFF0AE98A) : const Color(0xFF353A42),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () => _seleccionarTrabajo(nombre, trabajo),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF0AE98A)
                      : const Color(0xFF0AE98A).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: isSelected
                      ? null
                      : Border.all(
                          color: const Color(0xFF0AE98A).withOpacity(0.3),
                          width: 1,
                        ),
                ),
                child: Icon(
                  Icons.work_outline,
                  color: isSelected
                      ? const Color(0xFF13161c)
                      : const Color(0xFF0AE98A),
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nombre,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? const Color(0xFF0AE98A)
                            : const Color(0xFFFFFFFF),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0AE98A).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Bs ${trabajo.costo.toStringAsFixed(2)}/m²',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF0AE98A),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (trabajo.id != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF252930),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'ID: ${trabajo.id}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF6B7280),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (isSelected)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0AE98A),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'SELECCIONADO',
                        style: TextStyle(
                          color: Color(0xFF13161c),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _seleccionarTrabajo(nombre, trabajo);
                      } else if (value == 'delete') {
                        _confirmarEliminarTrabajo(nombre);
                      } else if (value == 'duplicate') {
                        _duplicarTrabajo(nombre, trabajo);
                      }
                    },
                    color: const Color(0xFF252930),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: Color(0xFF353A42)),
                    ),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit,
                                color: Color(0xFF0AE98A), size: 18),
                            SizedBox(width: 8),
                            Text('Editar',
                                style: TextStyle(color: Color(0xFFFFFFFF))),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'duplicate',
                        child: Row(
                          children: [
                            Icon(Icons.copy,
                                color: Color(0xFFB0B3B8), size: 18),
                            SizedBox(width: 8),
                            Text('Duplicar',
                                style: TextStyle(color: Color(0xFFFFFFFF))),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red, size: 18),
                            SizedBox(width: 8),
                            Text('Eliminar',
                                style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF252930),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF353A42),
                          width: 1,
                        ),
                      ),
                      child: const Icon(Icons.more_vert,
                          color: Color(0xFFB0B3B8), size: 18),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Métodos de funcionalidad
  void _seleccionarTrabajo(String nombre, TipoTrabajo trabajo) {
    setState(() {
      tipoSeleccionado = nombre;
      nombreController.text = nombre;
      costoController.text = trabajo.costo.toString();
      // Expandir automáticamente el formulario en móvil al seleccionar un trabajo
      _isExpanded = true;
    });
    // Debug: Verificar que la expansión se está activando
    print('🔧 Trabajo seleccionado: $nombre, Expandido: $_isExpanded');
  }

  void _limpiarFormulario() {
    setState(() {
      tipoSeleccionado = null;
      nombreController.clear();
      costoController.clear();
      _isExpanded = false; // Asegurar que se contraiga al limpiar
    });
    print('🧹 Formulario limpiado, Expandido: $_isExpanded');
  }

  Future<void> _anadirTrabajo() async {
    final nombre = nombreController.text.trim();
    final costo = double.tryParse(costoController.text) ?? 0;

    if (nombre.isEmpty || costo <= 0) {
      _mostrarSnackBar('Por favor, completa todos los campos correctamente',
          isError: true);
      return;
    }

    if (tiposLocales.containsKey(nombre)) {
      _mostrarSnackBar('Ya existe un trabajo con ese nombre', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Crear el tipo de trabajo localmente
      final nuevoTrabajo = TipoTrabajo(nombre: nombre, costo: costo);

      // Si Supabase está configurado, intentar crear en la base de datos
      if (SupabaseConfig.isConfigured && widget.isSupabaseConnected) {
        final trabajoCreado =
            await _tipoTrabajoProvider.crearTipoTrabajo(nuevoTrabajo);
        // Actualizar con el ID asignado por Supabase
        setState(() {
          tiposLocales[nombre] = trabajoCreado;
          _limpiarFormulario();
        });
        _mostrarSnackBar(
            'Trabajo "$nombre" añadido y sincronizado correctamente');
      } else {
        // Solo guardar localmente si Supabase no está disponible
        setState(() {
          tiposLocales[nombre] = nuevoTrabajo;
          _limpiarFormulario();
        });
        _mostrarSnackBar(
            'Trabajo "$nombre" añadido correctamente (solo local)');
      }
    } catch (e) {
      // Si falla la sincronización con Supabase, guardar localmente
      setState(() {
        tiposLocales[nombre] = TipoTrabajo(nombre: nombre, costo: costo);
        _limpiarFormulario();
      });
      _mostrarSnackBar(
          'Trabajo "$nombre" añadido localmente. Error de sincronización: $e',
          isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _actualizarTrabajo() async {
    if (tipoSeleccionado == null) return;

    final nuevoNombre = nombreController.text.trim();
    final nuevoCosto = double.tryParse(costoController.text) ?? 0;

    if (nuevoNombre.isEmpty || nuevoCosto <= 0) {
      _mostrarSnackBar('Por favor, completa todos los campos correctamente',
          isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final trabajoActual = tiposLocales[tipoSeleccionado]!;

      // Si cambió el nombre, verificar que no exista otro trabajo con ese nombre
      if (nuevoNombre != tipoSeleccionado) {
        if (tiposLocales.containsKey(nuevoNombre)) {
          _mostrarSnackBar('Ya existe un trabajo con ese nombre',
              isError: true);
          setState(() {
            _isLoading = false;
          });
          return;
        }
      }

      // Crear el trabajo actualizado
      final trabajoActualizado = TipoTrabajo(
        id: trabajoActual.id,
        nombre: nuevoNombre,
        costo: nuevoCosto,
      );

      // Si Supabase está configurado, intentar actualizar en la base de datos
      if (SupabaseConfig.isConfigured && widget.isSupabaseConnected) {
        await _tipoTrabajoProvider.actualizarTipoTrabajo(trabajoActualizado);

        setState(() {
          // Si cambió el nombre, necesitamos eliminar el viejo y crear uno nuevo
          if (nuevoNombre != tipoSeleccionado) {
            tiposLocales.remove(tipoSeleccionado);
            tiposLocales[nuevoNombre] = trabajoActualizado;
            tipoSeleccionado = nuevoNombre;
          } else {
            // Solo actualizamos el trabajo existente
            tiposLocales[tipoSeleccionado!] = trabajoActualizado;
          }
        });
        _mostrarSnackBar(
            'Trabajo "$nuevoNombre" actualizado y sincronizado correctamente');
      } else {
        // Solo guardar localmente si Supabase no está disponible
        setState(() {
          if (nuevoNombre != tipoSeleccionado) {
            tiposLocales.remove(tipoSeleccionado);
            tiposLocales[nuevoNombre] = trabajoActualizado;
            tipoSeleccionado = nuevoNombre;
          } else {
            tiposLocales[tipoSeleccionado!] = trabajoActualizado;
          }
        });
        _mostrarSnackBar(
            'Trabajo "$nuevoNombre" actualizado correctamente (solo local)');
      }
    } catch (e) {
      // Si falla la sincronización con Supabase, guardar localmente
      final trabajoActual = tiposLocales[tipoSeleccionado]!;
      final trabajoActualizado = TipoTrabajo(
        id: trabajoActual.id,
        nombre: nuevoNombre,
        costo: nuevoCosto,
      );

      setState(() {
        if (nuevoNombre != tipoSeleccionado) {
          tiposLocales.remove(tipoSeleccionado);
          tiposLocales[nuevoNombre] = trabajoActualizado;
          tipoSeleccionado = nuevoNombre;
        } else {
          tiposLocales[tipoSeleccionado!] = trabajoActualizado;
        }
      });
      _mostrarSnackBar(
          'Trabajo "$nuevoNombre" actualizado localmente. Error de sincronización: $e',
          isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _eliminarTrabajo() {
    if (tipoSeleccionado == null) return;
    _confirmarEliminarTrabajo(tipoSeleccionado!);
  }

  void _confirmarEliminarTrabajo(String nombre) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1e2229),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF353A42)),
        ),
        title: const Text(
          'Confirmar eliminación',
          style: TextStyle(
            color: Color(0xFFFFFFFF),
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          '¿Estás seguro de que quieres eliminar el trabajo "$nombre"?',
          style: const TextStyle(color: Color(0xFFB0B3B8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Color(0xFFB0B3B8)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _eliminarTrabajoConfirmado(nombre);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Future<void> _eliminarTrabajoConfirmado(String nombre) async {
    final trabajoAEliminar = tiposLocales[nombre];
    if (trabajoAEliminar == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Si Supabase está configurado y el trabajo tiene ID, intentar eliminar de la base de datos
      if (SupabaseConfig.isConfigured &&
          widget.isSupabaseConnected &&
          trabajoAEliminar.id != null) {
        await _tipoTrabajoProvider.eliminarTipoTrabajo(trabajoAEliminar.id!);
        _mostrarSnackBar(
            'Trabajo "$nombre" eliminado y sincronizado correctamente');
      } else {
        _mostrarSnackBar(
            'Trabajo "$nombre" eliminado correctamente (solo local)');
      }

      setState(() {
        tiposLocales.remove(nombre);
        if (tipoSeleccionado == nombre) {
          _limpiarFormulario();
        }
      });
    } catch (e) {
      // Si falla la eliminación en Supabase, eliminar localmente
      setState(() {
        tiposLocales.remove(nombre);
        if (tipoSeleccionado == nombre) {
          _limpiarFormulario();
        }
      });
      _mostrarSnackBar(
          'Trabajo "$nombre" eliminado localmente. Error de sincronización: $e',
          isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _duplicarTrabajo(String nombre, TipoTrabajo trabajo) {
    final nuevoNombre = '$nombre (Copia)';
    var contador = 1;
    var nombreFinal = nuevoNombre;

    while (tiposLocales.containsKey(nombreFinal)) {
      contador++;
      nombreFinal = '$nombre (Copia $contador)';
    }

    setState(() {
      tiposLocales[nombreFinal] = TipoTrabajo(
        nombre: nombreFinal,
        costo: trabajo.costo,
      );
    });

    _mostrarSnackBar('Trabajo duplicado como "$nombreFinal"');
  }

  void _confirmarLimpiarTodo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1e2229),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF353A42)),
        ),
        title: const Text(
          'Limpiar todos los trabajos',
          style: TextStyle(
            color: Color(0xFFFFFFFF),
            fontWeight: FontWeight.w600,
          ),
        ),
        content: const Text(
          '¿Estás seguro de que quieres eliminar todos los tipos de trabajo?\n\nEsta acción no se puede deshacer.',
          style: TextStyle(color: Color(0xFFB0B3B8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Color(0xFFB0B3B8)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _limpiarTodo();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Limpiar Todo'),
          ),
        ],
      ),
    );
  }

  void _limpiarTodo() {
    setState(() {
      tiposLocales.clear();
      _limpiarFormulario();
    });
    _mostrarSnackBar('Todos los trabajos han sido eliminados');
  }

  void _exportarDatos() {
    if (tiposLocales.isEmpty) {
      _mostrarSnackBar('No hay datos para exportar', isError: true);
      return;
    }

    final buffer = StringBuffer();
    buffer.writeln('Tipos de Trabajo - Cotizador Gigantografía');
    buffer.writeln('=========================================');
    buffer.writeln('Exportado el: ${DateTime.now().toString().split('.')[0]}');
    buffer.writeln('');

    buffer.writeln('Nombre del Trabajo\t\tCosto por m² (Bs)');
    buffer.writeln('---------------------------------------------');

    for (final entry in tiposLocales.entries) {
      buffer.writeln('${entry.key}\t\t${entry.value.costo.toStringAsFixed(2)}');
    }

    buffer.writeln('');
    buffer.writeln('Total de trabajos configurados: ${tiposLocales.length}');

    // Aquí podrías implementar la funcionalidad de descarga real
    // Por ahora, solo mostramos el resultado
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1e2229),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF353A42)),
        ),
        title: const Text(
          'Datos exportados',
          style: TextStyle(
            color: Color(0xFFFFFFFF),
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Container(
          constraints: const BoxConstraints(maxHeight: 400),
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF252930),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF353A42)),
              ),
              child: Text(
                buffer.toString(),
                style: const TextStyle(
                  fontFamily: 'monospace',
                  color: Color(0xFFB0B3B8),
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0AE98A),
              foregroundColor: const Color(0xFF13161c),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );

    _mostrarSnackBar('Datos exportados correctamente');
  }

  Future<void> _sincronizarConSupabase() async {
    if (!SupabaseConfig.isConfigured) {
      _mostrarSnackBar('Supabase no está configurado', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Iniciar animación de rotación continua
    _syncAnimationController.repeat();

    try {
      // Sincronizar datos locales con Supabase
      for (final tipoLocal in tiposLocales.values) {
        if (tipoLocal.id == null) {
          // Nuevo tipo de trabajo, crear en Supabase
          await _tipoTrabajoProvider.crearTipoTrabajo(tipoLocal);
        } else {
          // Tipo existente, actualizar en Supabase
          await _tipoTrabajoProvider.actualizarTipoTrabajo(tipoLocal);
        }
      }

      // Actualizar datos locales con los de Supabase
      final tiposActualizados =
          await _tipoTrabajoProvider.obtenerTiposDeTrabajos();
      final Map<String, TipoTrabajo> tiposMap = {};
      for (final tipo in tiposActualizados) {
        tiposMap[tipo.nombre] = tipo;
      }

      setState(() {
        tiposLocales = tiposMap;

        _limpiarFormulario();
      });

      _mostrarSnackBar('Sincronización completada correctamente');
    } catch (e) {
      _mostrarSnackBar('Error al sincronizar: $e', isError: true);
    } finally {
      // Detener animación de rotación
      _syncAnimationController.stop();
      _syncAnimationController.reset();

      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<bool> _onWillPop() async {
    return true;
  }

  void _mostrarSnackBar(String mensaje, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(mensaje)),
          ],
        ),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  void dispose() {
    nombreController.dispose();
    costoController.dispose();
    _animationController.dispose();
    _syncAnimationController.dispose();
    super.dispose();
  }
}
