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

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDarkMode = false; // Cambiar a modo claro por defecto

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode =
          prefs.getBool('isDarkMode') ?? false; // Modo claro por defecto
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
      title: 'Sistema de Cotizaciones',
      theme: _lightTheme(),
      darkTheme: _darkTheme(),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: CotizadorApp(toggleTheme: _toggleTheme, isDarkMode: isDarkMode),
    );
  }

  ThemeData _darkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.dark,
      ),
    );
  }

  ThemeData _lightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.light,
      ),
    );
  }
}

class ItemCotizacion {
  String tipo;
  double cantidad;
  double ancho;
  double alto;
  double adicional;
  double costo;

  ItemCotizacion({
    required this.tipo,
    required this.cantidad,
    required this.ancho,
    required this.alto,
    required this.adicional,
    required this.costo,
  });

  Map<String, dynamic> toJson() => {
        'tipo': tipo,
        'cantidad': cantidad,
        'ancho': ancho,
        'alto': alto,
        'adicional': adicional,
        'costo': costo,
      };

  factory ItemCotizacion.fromJson(Map<String, dynamic> json) => ItemCotizacion(
        tipo: json['tipo'],
        cantidad: json['cantidad'].toDouble(),
        ancho: json['ancho'].toDouble(),
        alto: json['alto'].toDouble(),
        adicional: json['adicional']?.toDouble() ?? 0.0,
        costo: json['costo'].toDouble(),
      );
}

class CotizadorApp extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  CotizadorApp({required this.toggleTheme, required this.isDarkMode});

  @override
  _CotizadorAppState createState() => _CotizadorAppState();
}

class _CotizadorAppState extends State<CotizadorApp> {
  Map<String, TipoTrabajo> tiposDeTrabajos = {};
  List<ItemCotizacion> itemsCotizacion = [];
  final TipoTrabajoProvider _tipoTrabajoProvider = TipoTrabajoProvider.instance;
  bool _isLoading = false;
  bool _isSupabaseConnected = false;

  final TextEditingController anchoController = TextEditingController();
  final TextEditingController altoController = TextEditingController();
  final TextEditingController cantidadController = TextEditingController();
  final TextEditingController adicionalController = TextEditingController();

  String? tipoSeleccionado;
  double subtotal = 0.0;

  @override
  void initState() {
    super.initState();
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
      // Fallback a método anterior para compatibilidad
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Datos sincronizados con Supabase'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error al sincronizar: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error al sincronizar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
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
      setState(() =>
          subtotal = (cantidad * ancho * alto * trabajo.costo) + adicional);
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

      if (costo <= 0) return;

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
    } catch (e) {
      // Error handling
    }
  }

  void _limpiarCampos() {
    anchoController.clear();
    altoController.clear();
    cantidadController.clear();
    adicionalController.clear();
    _actualizarSubtotal();
  }

  void _eliminarItem(int index) {
    setState(() {
      itemsCotizacion.removeAt(index);
    });
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
        },
      ),
    );
  }

  double get total =>
      itemsCotizacion.fold(0.0, (sum, item) => sum + item.costo);

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 768;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text('Cotizaciones'),
            if (_isSupabaseConnected) ...[
              SizedBox(width: 8),
              Icon(Icons.cloud_done, color: Colors.green, size: 16),
            ] else if (SupabaseConfig.isConfigured) ...[
              SizedBox(width: 8),
              Icon(Icons.cloud_off, color: Colors.orange, size: 16),
            ],
          ],
        ),
        actions: [
          if (SupabaseConfig.isConfigured)
            IconButton(
              icon: _isLoading
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(Icons.sync),
              onPressed: _isLoading ? null : _sincronizarConSupabase,
              tooltip: 'Sincronizar con Supabase',
            ),
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.toggleTheme,
            tooltip: widget.isDarkMode
                ? 'Cambiar a modo claro'
                : 'Cambiar a modo oscuro',
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => _mostrarGestionTrabajos(),
            tooltip: 'Gestionar tipos de trabajo',
          ),
        ],
      ),
      body: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: _buildFormularioEntrada(),
        ),
        Container(
          width: 1,
          color: Theme.of(context).dividerColor,
        ),
        Expanded(
          flex: 2,
          child: _buildResumenCotizacion(),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildFormularioEntrada(),
        Container(
          height: 1,
          color: Theme.of(context).dividerColor,
        ),
        Expanded(child: _buildResumenCotizacion()),
      ],
    );
  }

  Widget _buildFormularioEntrada() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1024;
    final isTablet = screenWidth > 768 && screenWidth <= 1024;

    return Container(
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Título y estado de conexión
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Añadir Nuevo Trabajo',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  if (_isSupabaseConnected)
                    Chip(
                      avatar: Icon(Icons.cloud_done, color: Colors.green),
                      label: Text('Sincronizado'),
                    ),
                ],
              ),
              SizedBox(height: 16),

              // Dropdown de tipos de trabajo
              if (tiposDeTrabajos.isNotEmpty) ...[
                DropdownButtonFormField<String>(
                  value: tipoSeleccionado,
                  decoration: InputDecoration(
                    labelText: 'Tipo de Trabajo',
                    prefixIcon: Icon(Icons.work),
                  ),
                  items: tiposDeTrabajos.keys.map((String value) {
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
                SizedBox(height: 16),
              ],

              // Campos de entrada optimizados por dispositivo
              if (isDesktop) ...[
                // Escritorio: 3 campos en una fila
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: anchoController,
                        labelText: 'Ancho (m)',
                        icon: Icons.straighten,
                        isDesktop: isDesktop,
                        isTablet: isTablet,
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: _buildTextField(
                        controller: altoController,
                        labelText: 'Alto (m)',
                        icon: Icons.height,
                        isDesktop: isDesktop,
                        isTablet: isTablet,
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: _buildTextField(
                        controller: cantidadController,
                        labelText: 'Cantidad',
                        icon: Icons.format_list_numbered,
                        isDesktop: isDesktop,
                        isTablet: isTablet,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                _buildTextField(
                  controller: adicionalController,
                  labelText: 'Costo Adicional (Bs)',
                  icon: Icons.add_circle_outline,
                  isDesktop: isDesktop,
                  isTablet: isTablet,
                ),
              ] else if (isTablet) ...[
                // Tableta: 2 campos por fila
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: anchoController,
                        labelText: 'Ancho (m)',
                        icon: Icons.straighten,
                        isDesktop: isDesktop,
                        isTablet: isTablet,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: altoController,
                        labelText: 'Alto (m)',
                        icon: Icons.height,
                        isDesktop: isDesktop,
                        isTablet: isTablet,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: cantidadController,
                        labelText: 'Cantidad',
                        icon: Icons.format_list_numbered,
                        isDesktop: isDesktop,
                        isTablet: isTablet,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: adicionalController,
                        labelText: 'Adicional (Bs)',
                        icon: Icons.add_circle_outline,
                        isDesktop: isDesktop,
                        isTablet: isTablet,
                      ),
                    ),
                  ],
                ),
              ] else ...[
                // Móvil: Campos más compactos, 2 por fila para dimensiones
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: anchoController,
                        labelText: 'Ancho (m)',
                        icon: Icons.straighten,
                        isDesktop: isDesktop,
                        isTablet: isTablet,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                        controller: altoController,
                        labelText: 'Alto (m)',
                        icon: Icons.height,
                        isDesktop: isDesktop,
                        isTablet: isTablet,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: cantidadController,
                        labelText: 'Cantidad',
                        icon: Icons.format_list_numbered,
                        isDesktop: isDesktop,
                        isTablet: isTablet,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                        controller: adicionalController,
                        labelText: 'Adicional (Bs)',
                        icon: Icons.add_circle_outline,
                        isDesktop: isDesktop,
                        isTablet: isTablet,
                      ),
                    ),
                  ],
                ),
              ],

              SizedBox(
                  height: isDesktop
                      ? 32
                      : isTablet
                          ? 24
                          : 20),

              // Contenedor del subtotal
              Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'SUBTOTAL:',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer,
                                ),
                      ),
                      Text(
                        'Bs ${subtotal.toStringAsFixed(2)}',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer,
                                ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(
                  height: isDesktop
                      ? 24
                      : isTablet
                          ? 20
                          : 16),

              // Botón de añadir
              ElevatedButton.icon(
                onPressed: subtotal > 0 ? _anadirItem : null,
                icon: Icon(Icons.add),
                label: Text('AÑADIR TRABAJO'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    required bool isDesktop,
    required bool isTablet,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon),
      ),
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
    );
  }

  Widget _buildResumenCotizacion() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1024;
    final isTablet = screenWidth > 768 && screenWidth <= 1024;
    final isMobile = screenWidth <= 768;

    return Container(
      child: Card(
        margin: EdgeInsets.zero,
        child: Column(
          children: [
            // Encabezado
            Container(
              padding: EdgeInsets.all(16),
              color: Theme.of(context).colorScheme.surfaceVariant,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Resumen de Cotización',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      if (itemsCotizacion.isNotEmpty) ...[
                        SizedBox(height: 4),
                        Text(
                          '${itemsCotizacion.length} elemento${itemsCotizacion.length > 1 ? 's' : ''}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ],
                  ),
                  if (itemsCotizacion.isNotEmpty)
                    ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Confirmar'),
                            content:
                                Text('¿Deseas limpiar toda la cotización?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text('Cancelar'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  setState(() {
                                    itemsCotizacion.clear();
                                  });
                                },
                                child: Text('Limpiar'),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: Icon(Icons.clear_all),
                      label: Text(isMobile ? 'Limpiar' : 'Limpiar Todo'),
                    ),
                ],
              ),
            ),

            // Contenido
            Expanded(
              child: itemsCotizacion.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long,
                            size: 80,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No hay trabajos añadidos',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Completa el formulario y añade tu primer trabajo',
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(
                        horizontal: isDesktop
                            ? 24
                            : isTablet
                                ? 20
                                : 16,
                        vertical: isDesktop ? 16 : 12,
                      ),
                      itemCount: itemsCotizacion.length,
                      itemBuilder: (context, index) {
                        final item = itemsCotizacion[index];
                        return Card(
                          margin: EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(item.tipo),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 4),
                                Text(
                                  '${item.cantidad} x ${item.ancho}m x ${item.alto}m',
                                ),
                                if (item.adicional > 0) ...[
                                  SizedBox(height: 2),
                                  Text(
                                    'Adicional: Bs ${item.adicional.toStringAsFixed(2)}',
                                    style: TextStyle(color: Colors.orange),
                                  ),
                                ],
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Bs ${item.costo.toStringAsFixed(2)}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    Text(
                                      '${(item.ancho * item.alto * item.cantidad).toStringAsFixed(2)} m²',
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                                SizedBox(width: 8),
                                PopupMenuButton<String>(
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      _editarItem(index);
                                    } else if (value == 'delete') {
                                      _eliminarItem(index);
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit),
                                          SizedBox(width: 8),
                                          Text('Editar'),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(Icons.delete, color: Colors.red),
                                          SizedBox(width: 8),
                                          Text('Eliminar'),
                                        ],
                                      ),
                                    ),
                                  ],
                                  child: Icon(Icons.more_vert),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // Total
            if (itemsCotizacion.isNotEmpty) ...[
              Container(
                padding: EdgeInsets.all(16),
                color: Theme.of(context).colorScheme.primary,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TOTAL:',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                        ),
                        Text(
                          'Cotización completa',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                        ),
                      ],
                    ),
                    Text(
                      'Bs ${total.toStringAsFixed(2)}',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _mostrarGestionTrabajos() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GestionTrabajosDialog(
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

  @override
  void dispose() {
    anchoController.dispose();
    altoController.dispose();
    cantidadController.dispose();
    adicionalController.dispose();
    super.dispose();
  }
}

class GestionTrabajosDialog extends StatefulWidget {
  final Map<String, TipoTrabajo> tiposDeTrabajos;
  final Function(Map<String, TipoTrabajo>) onSave;
  final VoidCallback toggleTheme;
  final bool isDarkMode;
  final bool isSupabaseConnected;

  GestionTrabajosDialog({
    required this.tiposDeTrabajos,
    required this.onSave,
    required this.toggleTheme,
    required this.isDarkMode,
    required this.isSupabaseConnected,
  });

  @override
  _GestionTrabajosDialogState createState() => _GestionTrabajosDialogState();
}

class _GestionTrabajosDialogState extends State<GestionTrabajosDialog> {
  late Map<String, TipoTrabajo> tiposLocales;
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController costoController = TextEditingController();
  final TipoTrabajoProvider _tipoTrabajoProvider = TipoTrabajoProvider.instance;
  String? tipoSeleccionado;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    tiposLocales = Map.from(widget.tiposDeTrabajos);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1024;
    final isMobile = screenWidth <= 768;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            if (!isMobile) // Ocultar título en móviles
              Text(
                'Gestionar Tipos de Trabajo',
                style: TextStyle(
                  fontSize: isDesktop ? 20 : 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            if (widget.isSupabaseConnected) ...[
              SizedBox(width: isMobile ? 0 : 8),
              Icon(Icons.cloud_done,
                  color: Colors.green, size: isDesktop ? 18 : 16),
            ] else if (SupabaseConfig.isConfigured) ...[
              SizedBox(width: isMobile ? 0 : 8),
              Icon(Icons.cloud_off,
                  color: Colors.orange, size: isDesktop ? 18 : 16),
            ],
          ],
        ),
        automaticallyImplyLeading: false,
        elevation: isDesktop ? 2 : 1,
        actions: [
          if (SupabaseConfig.isConfigured)
            IconButton(
              icon: _isLoading
                  ? SizedBox(
                      width: isDesktop ? 18 : 16,
                      height: isDesktop ? 18 : 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(Icons.sync, size: isDesktop ? 24 : 20),
              onPressed: _isLoading ? null : _sincronizarConSupabase,
              tooltip: 'Sincronizar con Supabase',
            ),
          IconButton(
            icon: Icon(
              widget.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              size: isDesktop ? 24 : 20,
            ),
            onPressed: widget.toggleTheme,
            tooltip: widget.isDarkMode
                ? 'Cambiar a modo claro'
                : 'Cambiar a modo oscuro',
          ),
          SizedBox(width: isDesktop ? 16 : 8),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.close, size: isDesktop ? 20 : 18),
            label: Text(
              'CERRAR',
              style: TextStyle(
                fontSize: isDesktop ? 14 : 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 20 : 16,
                vertical: isDesktop ? 12 : 10,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(isDesktop ? 8 : 6),
              ),
            ),
          ),
          SizedBox(width: isDesktop ? 16 : 8),
        ],
      ),
      body: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: _buildFormularioTrabajo(),
        ),
        Container(
          width: 1,
          color: Theme.of(context).dividerColor,
        ),
        Expanded(
          flex: 1,
          child: _buildListaTrabajos(),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        Expanded(
          flex: 1,
          child: _buildFormularioTrabajo(),
        ),
        Container(
          height: 1,
          color: Theme.of(context).dividerColor,
        ),
        Expanded(
          flex: 1,
          child: _buildListaTrabajos(),
        ),
      ],
    );
  }

  Widget _buildFormularioTrabajo() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1024;
    final isTablet = screenWidth > 768 && screenWidth <= 1024;
    final isMobile = screenWidth <= 768;

    return Container(
      child: Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
        ),
        elevation: isDesktop ? 4 : 2,
        child: Padding(
          padding: EdgeInsets.all(isDesktop
              ? 32
              : isTablet
                  ? 24
                  : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Título y estado
              Row(
                children: [
                  Expanded(
                    child: Text(
                      isMobile ? 'Añadir/Editar' : 'Añadir/Editar Trabajo',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: isDesktop
                                    ? 22
                                    : isTablet
                                        ? 20
                                        : 16,
                              ),
                    ),
                  ),
                  if (widget.isSupabaseConnected)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 12 : 8,
                        vertical: isDesktop ? 6 : 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border:
                            Border.all(color: Colors.green.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.cloud_done,
                              color: Colors.green, size: isDesktop ? 16 : 12),
                          SizedBox(width: 4),
                          Text(
                            'Sync',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: isDesktop ? 12 : 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              SizedBox(
                  height: isDesktop
                      ? 24
                      : isTablet
                          ? 20
                          : 16),

              // Campos de entrada optimizados
              if (isMobile) ...[
                // Móvil: Campos más compactos
                TextFormField(
                  controller: nombreController,
                  decoration: InputDecoration(
                    labelText: 'Nombre',
                    prefixIcon: Icon(Icons.work, size: 20),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(
                          color: Theme.of(context).primaryColor, width: 2),
                    ),
                  ),
                  style: TextStyle(fontSize: 14),
                  textInputAction: TextInputAction.next,
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: costoController,
                  decoration: InputDecoration(
                    labelText: 'Costo (Bs)',
                    prefixIcon: Icon(Icons.attach_money, size: 20),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(
                          color: Theme.of(context).primaryColor, width: 2),
                    ),
                  ),
                  style: TextStyle(fontSize: 14),
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                ),
              ] else ...[
                // Escritorio y tableta: Campos más espaciosos
                TextFormField(
                  controller: nombreController,
                  decoration: InputDecoration(
                    labelText: 'Nombre del Trabajo',
                    prefixIcon: Icon(Icons.work, size: isDesktop ? 24 : 20),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 16 : 12,
                      vertical: isDesktop ? 18 : 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(isDesktop ? 8 : 6),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(isDesktop ? 8 : 6),
                      borderSide: BorderSide(
                          color: Theme.of(context).primaryColor, width: 2),
                    ),
                  ),
                  style: TextStyle(fontSize: isDesktop ? 16 : 14),
                  textInputAction: TextInputAction.next,
                ),
                SizedBox(height: isDesktop ? 20 : 16),
                TextFormField(
                  controller: costoController,
                  decoration: InputDecoration(
                    labelText: 'Costo por m² (Bs)',
                    prefixIcon:
                        Icon(Icons.attach_money, size: isDesktop ? 24 : 20),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 16 : 12,
                      vertical: isDesktop ? 18 : 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(isDesktop ? 8 : 6),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(isDesktop ? 8 : 6),
                      borderSide: BorderSide(
                          color: Theme.of(context).primaryColor, width: 2),
                    ),
                  ),
                  style: TextStyle(fontSize: isDesktop ? 16 : 14),
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                ),
              ],

              SizedBox(
                  height: isDesktop
                      ? 32
                      : isTablet
                          ? 24
                          : 20),

              // Botones de acción optimizados
              if (isMobile) ...[
                // Móvil: Botones más compactos en grid
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _anadirTrabajo,
                        icon: Icon(Icons.add, size: 18),
                        label: Text('Añadir', style: TextStyle(fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: tipoSeleccionado != null
                            ? _actualizarTrabajo
                            : null,
                        icon: Icon(Icons.edit, size: 18),
                        label: Text('Editar', style: TextStyle(fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: tipoSeleccionado != null ? _eliminarTrabajo : null,
                  icon: Icon(Icons.delete, size: 18),
                  label: Text('Eliminar', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ] else ...[
                // Escritorio y tableta: Botones más espaciosos
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _anadirTrabajo,
                        icon: Icon(Icons.add, size: isDesktop ? 24 : 20),
                        label: Text(
                          'Añadir',
                          style: TextStyle(
                            fontSize: isDesktop ? 16 : 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            vertical: isDesktop ? 16 : 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(isDesktop ? 8 : 6),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: isDesktop ? 16 : 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: tipoSeleccionado != null
                            ? _actualizarTrabajo
                            : null,
                        icon: Icon(Icons.edit, size: isDesktop ? 24 : 20),
                        label: Text(
                          'Actualizar',
                          style: TextStyle(
                            fontSize: isDesktop ? 16 : 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            vertical: isDesktop ? 16 : 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(isDesktop ? 8 : 6),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isDesktop ? 16 : 12),
                ElevatedButton.icon(
                  onPressed: tipoSeleccionado != null ? _eliminarTrabajo : null,
                  icon: Icon(Icons.delete, size: isDesktop ? 24 : 20),
                  label: Text(
                    'Eliminar',
                    style: TextStyle(
                      fontSize: isDesktop ? 16 : 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(
                      vertical: isDesktop ? 16 : 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(isDesktop ? 8 : 6),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListaTrabajos() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1024;
    final isTablet = screenWidth > 768 && screenWidth <= 1024;
    final isMobile = screenWidth <= 768;

    return Container(
      child: Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
        ),
        elevation: isDesktop ? 4 : 2,
        child: Padding(
          padding: EdgeInsets.all(isDesktop
              ? 32
              : isTablet
                  ? 24
                  : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isMobile ? 'Trabajos' : 'Trabajos Existentes',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: isDesktop
                          ? 22
                          : isTablet
                              ? 20
                              : 16,
                    ),
              ),
              SizedBox(
                  height: isDesktop
                      ? 20
                      : isTablet
                          ? 16
                          : 12),
              Expanded(
                child: tiposLocales.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.work_off,
                              size: isDesktop
                                  ? 64
                                  : isTablet
                                      ? 56
                                      : 48,
                              color: Colors.grey,
                            ),
                            SizedBox(height: isDesktop ? 16 : 12),
                            Text(
                              isMobile
                                  ? 'Sin trabajos'
                                  : 'No hay trabajos definidos',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: isDesktop
                                    ? 16
                                    : isTablet
                                        ? 15
                                        : 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: tiposLocales.length,
                        itemBuilder: (context, index) {
                          final key = tiposLocales.keys.elementAt(index);
                          final trabajo = tiposLocales[key]!;
                          final isSelected = tipoSeleccionado == key;

                          return Container(
                            margin: EdgeInsets.only(bottom: isDesktop ? 8 : 6),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(isDesktop ? 10 : 8),
                                side: isSelected
                                    ? BorderSide(
                                        color: Theme.of(context).primaryColor,
                                        width: 2,
                                      )
                                    : BorderSide.none,
                              ),
                              elevation: isSelected ? 4 : 1,
                              color: isSelected
                                  ? Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.08)
                                  : null,
                              child: ListTile(
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: isDesktop
                                      ? 20
                                      : isTablet
                                          ? 16
                                          : 12,
                                  vertical: isDesktop
                                      ? 12
                                      : isTablet
                                          ? 10
                                          : 8,
                                ),
                                title: Text(
                                  trabajo.nombre,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: isDesktop
                                        ? 16
                                        : isTablet
                                            ? 15
                                            : 14,
                                    color: isSelected
                                        ? Theme.of(context).primaryColor
                                        : null,
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: EdgeInsets.only(top: 4),
                                  child: Text(
                                    'Bs ${trabajo.costo.toStringAsFixed(2)} por m²',
                                    style: TextStyle(
                                      fontSize: isDesktop
                                          ? 14
                                          : isTablet
                                              ? 13
                                              : 12,
                                      color: isSelected
                                          ? Theme.of(context)
                                              .primaryColor
                                              .withOpacity(0.7)
                                          : null,
                                    ),
                                  ),
                                ),
                                trailing: isSelected
                                    ? Icon(
                                        Icons.check_circle,
                                        color: Theme.of(context).primaryColor,
                                        size: isDesktop ? 24 : 20,
                                      )
                                    : Icon(
                                        Icons.radio_button_unchecked,
                                        color: Colors.grey,
                                        size: isDesktop ? 24 : 20,
                                      ),
                                onTap: () {
                                  setState(() {
                                    tipoSeleccionado = key;
                                    nombreController.text = trabajo.nombre;
                                    costoController.text =
                                        trabajo.costo.toString();
                                  });
                                },
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sincronizarConSupabase() async {
    if (!widget.isSupabaseConnected) return;

    setState(() => _isLoading = true);

    try {
      await _tipoTrabajoProvider.sincronizarDatosPendientes();

      // Recargar datos desde Supabase
      final tipos =
          await _tipoTrabajoProvider.obtenerTiposDeTrabajos(forzarRemoto: true);
      final tiposMap = <String, TipoTrabajo>{};

      for (final tipo in tipos) {
        tiposMap[tipo.nombre] = tipo;
      }

      setState(() {
        tiposLocales = tiposMap;
        tipoSeleccionado = null;
        nombreController.clear();
        costoController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Datos sincronizados con Supabase'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error al sincronizar: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error al sincronizar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _anadirTrabajo() async {
    final nombre = nombreController.text.trim();
    final costo = double.tryParse(costoController.text);

    if (nombre.isNotEmpty && costo != null && costo > 0) {
      if (!tiposLocales.containsKey(nombre)) {
        final nuevoTipo = TipoTrabajo(nombre: nombre, costo: costo);

        try {
          // Si está conectado a Supabase, crear allí también
          if (widget.isSupabaseConnected) {
            await _tipoTrabajoProvider.crearTipoTrabajo(nuevoTipo);
          }

          setState(() {
            tiposLocales[nombre] = nuevoTipo;
          });

          _limpiarCampos();

          if (widget.isSupabaseConnected) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('✅ Trabajo añadido y sincronizado'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          print('Error al crear tipo de trabajo: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Error al crear trabajo: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⚠️ Ya existe un trabajo con ese nombre'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _actualizarTrabajo() async {
    if (tipoSeleccionado == null) return;

    final nombre = nombreController.text.trim();
    final costo = double.tryParse(costoController.text);

    if (nombre.isNotEmpty && costo != null && costo > 0) {
      try {
        final tipoOriginal = tiposLocales[tipoSeleccionado]!;
        final tipoActualizado = tipoOriginal.copyWith(
          nombre: nombre,
          costo: costo,
        );

        // Si está conectado a Supabase, actualizar allí también
        if (widget.isSupabaseConnected && tipoOriginal.id != null) {
          await _tipoTrabajoProvider.actualizarTipoTrabajo(tipoActualizado);
        }

        setState(() {
          if (tipoSeleccionado != nombre) {
            tiposLocales.remove(tipoSeleccionado);
          }
          tiposLocales[nombre] = tipoActualizado;
          tipoSeleccionado = nombre;
        });

        _limpiarCampos();

        if (widget.isSupabaseConnected) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Trabajo actualizado y sincronizado'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        print('Error al actualizar tipo de trabajo: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al actualizar trabajo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _eliminarTrabajo() async {
    if (tipoSeleccionado != null) {
      try {
        final tipoAEliminar = tiposLocales[tipoSeleccionado]!;

        // Si está conectado a Supabase, eliminar allí también
        if (widget.isSupabaseConnected && tipoAEliminar.id != null) {
          await _tipoTrabajoProvider.eliminarTipoTrabajo(tipoAEliminar.id!);
        }

        setState(() {
          tiposLocales.remove(tipoSeleccionado);
          tipoSeleccionado = null;
        });

        _limpiarCampos();

        if (widget.isSupabaseConnected) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Trabajo eliminado y sincronizado'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        print('Error al eliminar tipo de trabajo: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al eliminar trabajo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _limpiarCampos() {
    nombreController.clear();
    costoController.clear();
    setState(() {
      tipoSeleccionado = null;
    });
  }

  @override
  void dispose() {
    nombreController.dispose();
    costoController.dispose();
    super.dispose();
  }
}

class EditarItemDialog extends StatefulWidget {
  final ItemCotizacion item;
  final Map<String, TipoTrabajo> tiposDeTrabajos;
  final Function(ItemCotizacion) onSave;

  EditarItemDialog({
    required this.item,
    required this.tiposDeTrabajos,
    required this.onSave,
  });

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
    // Inicializar con los valores del item actual
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
      final trabajo = widget.tiposDeTrabajos.values
          .firstWhere((t) => t.nombre == tipoSeleccionado);
      final cantidad = double.tryParse(cantidadController.text) ?? 1.0;
      final ancho = double.tryParse(anchoController.text) ?? 0.0;
      final alto = double.tryParse(altoController.text) ?? 0.0;
      final adicional = double.tryParse(adicionalController.text) ?? 0.0;
      setState(() =>
          subtotal = (cantidad * ancho * alto * trabajo.costo) + adicional);
    } catch (e) {
      setState(() => subtotal = 0.0);
    }
  }

  void _guardarCambios() {
    if (tipoSeleccionado == null) return;

    try {
      final trabajo = widget.tiposDeTrabajos.values
          .firstWhere((t) => t.nombre == tipoSeleccionado);
      final cantidad = double.tryParse(cantidadController.text) ?? 1.0;
      final ancho = double.tryParse(anchoController.text) ?? 0.0;
      final alto = double.tryParse(altoController.text) ?? 0.0;
      final adicional = double.tryParse(adicionalController.text) ?? 0.0;
      final costo = (cantidad * ancho * alto * trabajo.costo) + adicional;

      if (costo <= 0) return;

      final itemEditado = ItemCotizacion(
        tipo: trabajo.nombre,
        cantidad: cantidad,
        ancho: ancho,
        alto: alto,
        adicional: adicional,
        costo: costo,
      );

      widget.onSave(itemEditado);
      Navigator.of(context).pop();
    } catch (e) {
      // Error handling
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1024;
    final isTablet = screenWidth > 768 && screenWidth <= 1024;
    final isMobile = screenWidth <= 768;

    return Dialog(
      child: Container(
        width: isDesktop
            ? 500
            : isTablet
                ? 450
                : double.infinity,
        constraints: BoxConstraints(
          maxWidth: isDesktop
              ? 500
              : isTablet
                  ? 450
                  : double.infinity,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Título
            Text(
              'Editar Trabajo',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),

            // Dropdown de tipos de trabajo
            if (widget.tiposDeTrabajos.isNotEmpty) ...[
              DropdownButtonFormField<String>(
                value: tipoSeleccionado,
                decoration: InputDecoration(
                  labelText: 'Tipo de Trabajo',
                  prefixIcon: Icon(Icons.work),
                ),
                items: widget.tiposDeTrabajos.values.map((trabajo) {
                  return DropdownMenuItem<String>(
                    value: trabajo.nombre,
                    child: Text(trabajo.nombre),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    tipoSeleccionado = newValue;
                  });
                  _actualizarSubtotal();
                },
              ),
              SizedBox(height: 16),
            ],

            // Campos de entrada optimizados
            if (isMobile) ...[
              // Móvil: Campos en grid 2x2
              Row(
                children: [
                  Expanded(
                    child: _buildEditTextField(
                      controller: anchoController,
                      labelText: 'Ancho (m)',
                      icon: Icons.straighten,
                      isDesktop: isDesktop,
                      isTablet: isTablet,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildEditTextField(
                      controller: altoController,
                      labelText: 'Alto (m)',
                      icon: Icons.height,
                      isDesktop: isDesktop,
                      isTablet: isTablet,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildEditTextField(
                      controller: cantidadController,
                      labelText: 'Cantidad',
                      icon: Icons.format_list_numbered,
                      isDesktop: isDesktop,
                      isTablet: isTablet,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildEditTextField(
                      controller: adicionalController,
                      labelText: 'Adicional',
                      icon: Icons.add_circle_outline,
                      isDesktop: isDesktop,
                      isTablet: isTablet,
                    ),
                  ),
                ],
              ),
            ] else ...[
              // Escritorio y tableta: Campos en filas
              Row(
                children: [
                  Expanded(
                    child: _buildEditTextField(
                      controller: anchoController,
                      labelText: 'Ancho (m)',
                      icon: Icons.straighten,
                      isDesktop: isDesktop,
                      isTablet: isTablet,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildEditTextField(
                      controller: altoController,
                      labelText: 'Alto (m)',
                      icon: Icons.height,
                      isDesktop: isDesktop,
                      isTablet: isTablet,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildEditTextField(
                      controller: cantidadController,
                      labelText: 'Cantidad',
                      icon: Icons.format_list_numbered,
                      isDesktop: isDesktop,
                      isTablet: isTablet,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildEditTextField(
                      controller: adicionalController,
                      labelText: 'Adicional (Bs)',
                      icon: Icons.add_circle_outline,
                      isDesktop: isDesktop,
                      isTablet: isTablet,
                    ),
                  ),
                ],
              ),
            ],

            SizedBox(height: 24),

            // Subtotal con estilos del tema
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'SUBTOTAL:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      'Bs ${subtotal.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24),

            // Botones de acción
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close),
                    label: Text('CANCELAR'),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: subtotal > 0 ? _guardarCambios : null,
                    icon: Icon(Icons.save),
                    label: Text('GUARDAR'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    required bool isDesktop,
    required bool isTablet,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon),
      ),
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
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
