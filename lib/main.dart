import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
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
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  Future<void> _saveThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDarkMode);
  }

  void _toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
    _saveThemePreference();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistema de Cotizaciones Gigantografía',
      debugShowCheckedModeBanner: false,
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home:
          CotizadorHomePage(toggleTheme: _toggleTheme, isDarkMode: isDarkMode),
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1565C0),
        brightness: Brightness.light,
        primary: const Color(0xFF1565C0),
        secondary: const Color(0xFF0D47A1),
        surface: Colors.white,
        background: const Color(0xFFF8F9FA),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: const Color(0xFF1A1A1A),
        onBackground: const Color(0xFF1A1A1A),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      cardTheme: const CardThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12))),
        margin: EdgeInsets.all(8),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1565C0),
        brightness: Brightness.dark,
        primary: const Color(0xFF42A5F5),
        secondary: const Color(0xFF1976D2),
        surface: const Color(0xFF1E1E1E),
        background: const Color(0xFF121212),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
        onBackground: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      cardTheme: const CardThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12))),
        margin: EdgeInsets.all(8),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
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
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const CotizadorHomePage({
    Key? key,
    required this.toggleTheme,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  _CotizadorHomePageState createState() => _CotizadorHomePageState();
}

class _CotizadorHomePageState extends State<CotizadorHomePage>
    with SingleTickerProviderStateMixin {
  Map<String, TipoTrabajo> tiposDeTrabajos = {};
  List<ItemCotizacion> itemsCotizacion = [];
  final TipoTrabajoProvider _tipoTrabajoProvider = TipoTrabajoProvider.instance;
  bool _isLoading = false;
  bool _isSupabaseConnected = false;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

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

    _cargarDatos();
    _setupListeners();
    _verificarConexionSupabase();
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

  Future<void> _cargarDatos() async {
    setState(() => _isLoading = true);

    try {
      final tipos = await _tipoTrabajoProvider.obtenerTiposDeTrabajos();
      final tiposMap = <String, TipoTrabajo>{};

      for (final tipo in tipos) {
        tiposMap[tipo.nombre] = tipo;
      }

      setState(() {
        tiposDeTrabajos = tiposMap;
        if (tiposDeTrabajos.isNotEmpty) {
          tipoSeleccionado = tiposDeTrabajos.keys.first;
        }
      });
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

  Future<void> _sincronizarConSupabase() async {
    if (!_isSupabaseConnected) return;

    setState(() => _isLoading = true);

    try {
      await _tipoTrabajoProvider.sincronizarDatosPendientes();
      await _cargarDatos();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Datos sincronizados exitosamente'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } catch (e) {
      print('Error al sincronizar: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Error al sincronizar: $e')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
          toggleTheme: widget.toggleTheme,
          isDarkMode: widget.isDarkMode,
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
      body: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: _buildBody(),
          );
        },
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.calculate, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Cotizador Gigantografía',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                'Sistema Profesional',
                style: TextStyle(
                    fontSize: 12, color: Colors.white.withOpacity(0.8)),
              ),
            ],
          ),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        if (_isSupabaseConnected)
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cloud_done, color: Colors.green, size: 16),
                SizedBox(width: 4),
                Text(
                  'Conectado',
                  style: TextStyle(color: Colors.green, fontSize: 12),
                ),
              ],
            ),
          )
        else if (SupabaseConfig.isConfigured)
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cloud_off, color: Colors.orange, size: 16),
                SizedBox(width: 4),
                Text(
                  'Sin conexión',
                  style: TextStyle(color: Colors.orange, fontSize: 12),
                ),
              ],
            ),
          ),
        if (SupabaseConfig.isConfigured)
          IconButton(
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.sync),
            onPressed: _isLoading ? null : _sincronizarConSupabase,
            tooltip: 'Sincronizar con Supabase',
          ),
        IconButton(
          icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
          onPressed: widget.toggleTheme,
          tooltip: widget.isDarkMode ? 'Modo claro' : 'Modo oscuro',
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: _mostrarGestionTrabajos,
          tooltip: 'Gestionar tipos de trabajo',
        ),
        const SizedBox(width: 8),
      ],
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
    return Padding(
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
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildFormularioCard(),
          const SizedBox(height: 16),
          Expanded(child: _buildResumenCard()),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildFormularioCard(),
        const SizedBox(height: 8),
        Expanded(child: _buildResumenCard()),
      ],
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
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.add_box,
            color: Theme.of(context).colorScheme.primary,
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nuevo Trabajo',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              'Ingrese los datos del trabajo a cotizar',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7),
                  ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTipoDropdown() {
    return DropdownButtonFormField<String>(
      value: tipoSeleccionado,
      decoration: InputDecoration(
        labelText: 'Tipo de Trabajo',
        prefixIcon: const Icon(Icons.work_outline),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: tiposDeTrabajos.keys.map((String value) {
        final tipo = tiposDeTrabajos[value]!;
        return DropdownMenuItem<String>(
          value: value,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(child: Text(value)),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.primaryContainer.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SUBTOTAL',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
              ),
              if (subtotal > 0) ...[
                const SizedBox(height: 4),
                Text(
                  _getMetrosCuadradosText(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onPrimaryContainer
                            .withOpacity(0.8),
                      ),
                ),
              ],
            ],
          ),
          Text(
            'Bs ${subtotal.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
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
    return ElevatedButton.icon(
      onPressed: subtotal > 0 ? _anadirItem : null,
      icon: const Icon(Icons.add_circle_outline),
      label: const Text('AÑADIR TRABAJO'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: subtotal > 0 ? 4 : 0,
      ),
    );
  }

  Widget _buildResumenCard() {
    return Card(
      child: Column(
        children: [
          _buildResumenHeader(),
          Expanded(child: _buildResumenBody()),
          if (itemsCotizacion.isNotEmpty) _buildTotalFooter(),
        ],
      ),
    );
  }

  Widget _buildResumenHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.receipt_long,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cotización',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  itemsCotizacion.isEmpty
                      ? 'No hay trabajos añadidos'
                      : '${itemsCotizacion.length} trabajo${itemsCotizacion.length > 1 ? 's' : ''}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant
                            .withOpacity(0.7),
                      ),
                ),
              ],
            ),
          ),
          if (itemsCotizacion.isNotEmpty)
            IconButton(
              onPressed: _limpiarTodaLaCotizacion,
              icon: const Icon(Icons.clear_all),
              tooltip: 'Limpiar todo',
            ),
        ],
      ),
    );
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
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color:
                  Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt_long,
              size: 64,
              color: Theme.of(context)
                  .colorScheme
                  .onSurfaceVariant
                  .withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No hay trabajos añadidos',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Completa el formulario y añade tu primer trabajo',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(int index) {
    final item = itemsCotizacion[index];
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.work_outline,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.tipo,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.cantidad.toStringAsFixed(0)} × ${item.ancho}m × ${item.alto}m = ${item.metrosCuadrados.toStringAsFixed(2)} m²',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (item.adicional > 0) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Adicional: Bs ${item.adicional.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.orange,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Bs ${item.costo.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => _editarItem(index),
                      icon: const Icon(Icons.edit_outlined),
                      iconSize: 20,
                      tooltip: 'Editar',
                    ),
                    IconButton(
                      onPressed: () => _eliminarItem(index),
                      icon: const Icon(Icons.delete_outline),
                      iconSize: 20,
                      tooltip: 'Eliminar',
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: const BorderRadius.only(
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
              Text(
                'TOTAL GENERAL',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                'Cotización completa',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.8),
                    ),
              ),
            ],
          ),
          Text(
            'Bs ${total.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    if (itemsCotizacion.isEmpty) return const SizedBox.shrink();

    return FloatingActionButton.extended(
      onPressed: _exportarCotizacion,
      icon: const Icon(Icons.share),
      label: const Text('Exportar'),
      backgroundColor: Theme.of(context).colorScheme.secondary,
      foregroundColor: Colors.white,
    );
  }

  void _limpiarTodaLaCotizacion() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar'),
        content: const Text(
            '¿Estás seguro de que deseas limpiar toda la cotización?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                itemsCotizacion.clear();
              });
              _mostrarExito('Cotización limpiada');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Limpiar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _exportarCotizacion() {
    // Aquí puedes implementar la lógica de exportación
    _mostrarExito('Función de exportación próximamente');
  }

  @override
  void dispose() {
    anchoController.dispose();
    altoController.dispose();
    cantidadController.dispose();
    adicionalController.dispose();
    _animationController.dispose();
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
              items: widget.tiposDeTrabajos.keys.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
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
  final VoidCallback toggleTheme;
  final bool isDarkMode;
  final bool isSupabaseConnected;

  const GestionTrabajosPage({
    Key? key,
    required this.tiposDeTrabajos,
    required this.onSave,
    required this.toggleTheme,
    required this.isDarkMode,
    required this.isSupabaseConnected,
  }) : super(key: key);

  @override
  _GestionTrabajosPageState createState() => _GestionTrabajosPageState();
}

class _GestionTrabajosPageState extends State<GestionTrabajosPage>
    with SingleTickerProviderStateMixin {
  late Map<String, TipoTrabajo> tiposLocales;
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController costoController = TextEditingController();
  final TipoTrabajoProvider _tipoTrabajoProvider = TipoTrabajoProvider.instance;

  String? tipoSeleccionado;
  bool _isLoading = false;
  bool _hasChanges = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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
        floatingActionButton: _buildFloatingActionButton(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.settings, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Gestión de Trabajos',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                'Configurar tipos y precios',
                style: TextStyle(
                    fontSize: 12, color: Colors.white.withOpacity(0.8)),
              ),
            ],
          ),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        if (widget.isSupabaseConnected)
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cloud_done, color: Colors.green, size: 16),
                SizedBox(width: 4),
                Text(
                  'Sincronizado',
                  style: TextStyle(color: Colors.green, fontSize: 12),
                ),
              ],
            ),
          ),
        if (SupabaseConfig.isConfigured)
          IconButton(
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.sync),
            onPressed: _isLoading ? null : _sincronizarConSupabase,
            tooltip: 'Sincronizar con Supabase',
          ),
        IconButton(
          icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
          onPressed: widget.toggleTheme,
          tooltip: widget.isDarkMode ? 'Modo claro' : 'Modo oscuro',
        ),
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
          title: const Text('Añadir/Editar Trabajo'),
          subtitle: Text(tipoSeleccionado != null
              ? 'Editando: $tipoSeleccionado'
              : 'Tap para añadir nuevo trabajo'),
          leading: const Icon(Icons.add_business),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              tipoSeleccionado != null ? Icons.edit : Icons.add,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              tipoSeleccionado != null ? 'Editar Trabajo' : 'Nuevo Trabajo',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Campo Nombre
        TextField(
          controller: nombreController,
          decoration: InputDecoration(
            labelText: 'Nombre del trabajo',
            hintText: 'Ej: Lona impresa, Banner, Vinilo...',
            prefixIcon: const Icon(Icons.work_outline),
            border: const OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Campo Costo
        TextField(
          controller: costoController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Costo por m²',
            hintText: '0.00',
            prefixIcon: const Icon(Icons.attach_money),
            suffixText: 'Bs/m²',
            border: const OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Botones de acción
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: tipoSeleccionado != null
                    ? _actualizarTrabajo
                    : _anadirTrabajo,
                icon: Icon(tipoSeleccionado != null ? Icons.update : Icons.add),
                label: Text(tipoSeleccionado != null ? 'Actualizar' : 'Añadir'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            if (tipoSeleccionado != null) ...[
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _eliminarTrabajo,
                icon: const Icon(Icons.delete),
                label: const Text('Eliminar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: _limpiarFormulario,
              icon: const Icon(Icons.clear),
              label: const Text('Cancelar'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildListHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.list,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            'Tipos de Trabajo (${tiposLocales.length})',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const Spacer(),
          if (tiposLocales.isNotEmpty)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              tooltip: 'Más opciones',
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
                      Icon(Icons.download),
                      SizedBox(width: 8),
                      Text('Exportar datos'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'clear_all',
                  child: Row(
                    children: [
                      Icon(Icons.clear_all, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Limpiar todo', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
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
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color:
                  Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.work_off,
              size: 64,
              color: Theme.of(context)
                  .colorScheme
                  .onSurfaceVariant
                  .withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No hay tipos de trabajo',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Añade tu primer tipo de trabajo\nusando el formulario de arriba',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTrabajoCard(String nombre, TipoTrabajo trabajo, int index) {
    final isSelected = tipoSeleccionado == nombre;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isSelected ? Colors.green.shade100 : null,
      child: InkWell(
        onTap: () => _seleccionarTrabajo(nombre, trabajo),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.green
                      : Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.work_outline,
                  color: isSelected
                      ? Colors.white
                      : Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nombre,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.green.shade800 : null,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Costo: Bs ${trabajo.costo.toStringAsFixed(2)} por m²',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.7),
                          ),
                    ),
                    if (trabajo.id != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'ID: ${trabajo.id}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.5),
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                children: [
                  if (isSelected)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Seleccionado',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
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
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 8),
                            Text('Editar'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'duplicate',
                        child: Row(
                          children: [
                            Icon(Icons.copy),
                            SizedBox(width: 8),
                            Text('Duplicar'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Eliminar',
                                style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    child: const Icon(Icons.more_vert),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    if (!_hasChanges) return const SizedBox.shrink();

    return FloatingActionButton.extended(
      onPressed: _guardarCambios,
      icon: const Icon(Icons.save),
      label: const Text('Guardar Cambios'),
      backgroundColor: Theme.of(context).colorScheme.secondary,
      foregroundColor: Colors.white,
    );
  }

  // Métodos de funcionalidad
  void _checkForChanges() {
    final hasChanges = !_mapsAreEqual(tiposLocales, widget.tiposDeTrabajos);
    if (hasChanges != _hasChanges) {
      setState(() {
        _hasChanges = hasChanges;
      });
    }
  }

  bool _mapsAreEqual(
      Map<String, TipoTrabajo> map1, Map<String, TipoTrabajo> map2) {
    if (map1.length != map2.length) return false;
    for (final entry in map1.entries) {
      final other = map2[entry.key];
      if (other == null ||
          other.nombre != entry.value.nombre ||
          other.costo != entry.value.costo) {
        return false;
      }
    }
    return true;
  }

  void _seleccionarTrabajo(String nombre, TipoTrabajo trabajo) {
    setState(() {
      tipoSeleccionado = nombre;
      nombreController.text = nombre;
      costoController.text = trabajo.costo.toString();
    });
  }

  void _limpiarFormulario() {
    setState(() {
      tipoSeleccionado = null;
      nombreController.clear();
      costoController.clear();
    });
  }

  void _anadirTrabajo() {
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
      tiposLocales[nombre] = TipoTrabajo(nombre: nombre, costo: costo);
      _limpiarFormulario();
      _checkForChanges();
    });

    _mostrarSnackBar('Trabajo "$nombre" añadido correctamente');
  }

  void _actualizarTrabajo() {
    if (tipoSeleccionado == null) return;

    final nuevoNombre = nombreController.text.trim();
    final nuevoCosto = double.tryParse(costoController.text) ?? 0;

    if (nuevoNombre.isEmpty || nuevoCosto <= 0) {
      _mostrarSnackBar('Por favor, completa todos los campos correctamente',
          isError: true);
      return;
    }

    setState(() {
      // Si cambió el nombre, necesitamos eliminar el viejo y crear uno nuevo
      if (nuevoNombre != tipoSeleccionado) {
        if (tiposLocales.containsKey(nuevoNombre)) {
          _mostrarSnackBar('Ya existe un trabajo con ese nombre',
              isError: true);
          return;
        }

        final trabajoActual = tiposLocales[tipoSeleccionado]!;
        tiposLocales.remove(tipoSeleccionado);
        tiposLocales[nuevoNombre] = TipoTrabajo(
          id: trabajoActual.id,
          nombre: nuevoNombre,
          costo: nuevoCosto,
        );
        tipoSeleccionado = nuevoNombre;
      } else {
        // Solo actualizamos el costo
        tiposLocales[tipoSeleccionado!] = TipoTrabajo(
          id: tiposLocales[tipoSeleccionado]!.id,
          nombre: nuevoNombre,
          costo: nuevoCosto,
        );
      }
      _checkForChanges();
    });

    _mostrarSnackBar('Trabajo actualizado correctamente');
  }

  void _eliminarTrabajo() {
    if (tipoSeleccionado == null) return;
    _confirmarEliminarTrabajo(tipoSeleccionado!);
  }

  void _confirmarEliminarTrabajo(String nombre) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content:
            Text('¿Estás seguro de que quieres eliminar el trabajo "$nombre"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _eliminarTrabajoConfirmado(nombre);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _eliminarTrabajoConfirmado(String nombre) {
    setState(() {
      tiposLocales.remove(nombre);
      if (tipoSeleccionado == nombre) {
        _limpiarFormulario();
      }
      _checkForChanges();
    });
    _mostrarSnackBar('Trabajo "$nombre" eliminado correctamente');
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
      _checkForChanges();
    });

    _mostrarSnackBar('Trabajo duplicado como "$nombreFinal"');
  }

  void _confirmarLimpiarTodo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpiar todos los trabajos'),
        content: const Text(
            '¿Estás seguro de que quieres eliminar todos los tipos de trabajo?\n\nEsta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _limpiarTodo();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
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
      _checkForChanges();
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
        title: const Text('Datos exportados'),
        content: SingleChildScrollView(
          child: Text(buffer.toString(),
              style: const TextStyle(fontFamily: 'monospace')),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
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
        _hasChanges = false;
        _limpiarFormulario();
      });

      _mostrarSnackBar('Sincronización completada correctamente');
    } catch (e) {
      _mostrarSnackBar('Error al sincronizar: $e', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _guardarCambios() {
    widget.onSave(tiposLocales);
    setState(() {
      _hasChanges = false;
    });
    _mostrarSnackBar('Cambios guardados correctamente');
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cambios sin guardar'),
        content: const Text(
            'Tienes cambios sin guardar. ¿Quieres guardarlos antes de salir?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Descartar'),
          ),
          ElevatedButton(
            onPressed: () {
              _guardarCambios();
              Navigator.of(context).pop(true);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    return result ?? false;
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
    super.dispose();
  }
}
