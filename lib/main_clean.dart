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
  bool isDarkMode = true;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? true;
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
      theme: isDarkMode ? _darkTheme() : _lightTheme(),
      home: CotizadorApp(toggleTheme: _toggleTheme, isDarkMode: isDarkMode),
    );
  }

  ThemeData _darkTheme() {
    return ThemeData(
      primarySwatch: Colors.blue,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Color(0xFF1A1A1A),
      cardColor: Color(0xFF2D2D2D),
      appBarTheme: AppBarTheme(
        backgroundColor: Color(0xFF2D2D2D),
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF1976D2),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFF3A3A3A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: Color(0xFF1976D2)),
        ),
      ),
    );
  }

  ThemeData _lightTheme() {
    return ThemeData(
      primarySwatch: Colors.blue,
      brightness: Brightness.light,
      scaffoldBackgroundColor: Color(0xFFF5F5F5),
      cardColor: Colors.white,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF1976D2),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFFF0F0F0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: Color(0xFF1976D2)),
        ),
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
    final isDesktop = MediaQuery.of(context).size.width > 768;

    return Container(
      child: Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        child: Padding(
          padding: EdgeInsets.all(isDesktop ? 24 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Añadir Nuevo Trabajo',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                  ),
                  if (_isSupabaseConnected)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.cloud_done, color: Colors.green, size: 12),
                          SizedBox(width: 4),
                          Text(
                            'Sincronizado',
                            style: TextStyle(color: Colors.green, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              SizedBox(height: isDesktop ? 16 : 12),
              if (tiposDeTrabajos.isNotEmpty) ...[
                DropdownButtonFormField<String>(
                  value: tipoSeleccionado,
                  decoration: InputDecoration(
                    labelText: 'Tipo de Trabajo',
                    prefixIcon: Icon(Icons.work),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: isDesktop ? 16 : 12,
                    ),
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
                SizedBox(height: isDesktop ? 16 : 12),
              ],
              // Resto de campos del formulario...
              if (isDesktop) ...[
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: anchoController,
                        decoration: InputDecoration(
                          labelText: 'Ancho (m)',
                          prefixIcon: Icon(Icons.straighten),
                        ),
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d*')),
                        ],
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: altoController,
                        decoration: InputDecoration(
                          labelText: 'Alto (m)',
                          prefixIcon: Icon(Icons.height),
                        ),
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d*')),
                        ],
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: cantidadController,
                        decoration: InputDecoration(
                          labelText: 'Cantidad',
                          prefixIcon: Icon(Icons.format_list_numbered),
                        ),
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d*')),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isDesktop ? 16 : 12),
                TextFormField(
                  controller: adicionalController,
                  decoration: InputDecoration(
                    labelText: 'Costo Adicional (Bs)',
                    prefixIcon: Icon(Icons.add_circle_outline),
                  ),
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                ),
              ] else ...[
                // Versión móvil - campos apilados
                TextFormField(
                  controller: anchoController,
                  decoration: InputDecoration(
                    labelText: 'Ancho (m)',
                    prefixIcon: Icon(Icons.straighten),
                  ),
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: altoController,
                  decoration: InputDecoration(
                    labelText: 'Alto (m)',
                    prefixIcon: Icon(Icons.height),
                  ),
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: cantidadController,
                  decoration: InputDecoration(
                    labelText: 'Cantidad',
                    prefixIcon: Icon(Icons.format_list_numbered),
                  ),
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: adicionalController,
                  decoration: InputDecoration(
                    labelText: 'Costo Adicional (Bs)',
                    prefixIcon: Icon(Icons.add_circle_outline),
                  ),
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                ),
              ],
              SizedBox(height: isDesktop ? 24 : 16),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Subtotal:',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      'Bs ${subtotal.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: isDesktop ? 16 : 12),
              ElevatedButton.icon(
                onPressed: subtotal > 0 ? _anadirItem : null,
                icon: Icon(Icons.add),
                label: Text('AÑADIR TRABAJO'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResumenCotizacion() {
    return Container(
      child: Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Resumen de Cotización',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (itemsCotizacion.isNotEmpty)
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          itemsCotizacion.clear();
                        });
                      },
                      icon: Icon(Icons.clear_all),
                      label: Text('Limpiar'),
                    ),
                ],
              ),
            ),
            Expanded(
              child: itemsCotizacion.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No hay trabajos añadidos',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      itemCount: itemsCotizacion.length,
                      itemBuilder: (context, index) {
                        final item = itemsCotizacion[index];
                        return Card(
                          margin: EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(
                              item.tipo,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              '${item.cantidad} x ${item.ancho}m x ${item.alto}m' +
                                  (item.adicional > 0
                                      ? ' + Bs ${item.adicional.toStringAsFixed(2)}'
                                      : ''),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Bs ${item.costo.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
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
                                          Icon(Icons.delete),
                                          SizedBox(width: 8),
                                          Text('Eliminar'),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            if (itemsCotizacion.isNotEmpty) ...[
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  border: Border(
                    top: BorderSide(color: Color(0xFF28B463)),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'TOTAL:',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Bs ${total.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF28B463),
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
    final isDesktop = MediaQuery.of(context).size.width > 768;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text('Gestionar Tipos de Trabajo'),
            if (widget.isSupabaseConnected) ...[
              SizedBox(width: 8),
              Icon(Icons.cloud_done, color: Colors.green, size: 16),
            ] else if (SupabaseConfig.isConfigured) ...[
              SizedBox(width: 8),
              Icon(Icons.cloud_off, color: Colors.orange, size: 16),
            ],
          ],
        ),
        automaticallyImplyLeading: false,
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
          SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              widget.onSave(tiposLocales);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: Text('GUARDAR'),
          ),
          SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[600],
              foregroundColor: Colors.white,
            ),
            child: Text('CERRAR'),
          ),
          SizedBox(width: 16),
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
    return Container(
      child: Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Añadir/Editar Trabajo',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                  ),
                  if (widget.isSupabaseConnected)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.cloud_done, color: Colors.green, size: 12),
                          SizedBox(width: 4),
                          Text(
                            'Sincronizado',
                            style: TextStyle(color: Colors.green, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: nombreController,
                decoration: InputDecoration(
                  labelText: 'Nombre del Trabajo',
                  prefixIcon: Icon(Icons.work),
                ),
                textInputAction: TextInputAction.next,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: costoController,
                decoration: InputDecoration(
                  labelText: 'Costo (Bs)',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _anadirTrabajo,
                      icon: Icon(Icons.add),
                      label: Text('Añadir'),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed:
                          tipoSeleccionado != null ? _actualizarTrabajo : null,
                      icon: Icon(Icons.edit),
                      label: Text('Actualizar'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: tipoSeleccionado != null ? _eliminarTrabajo : null,
                icon: Icon(Icons.delete),
                label: Text('Eliminar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListaTrabajos() {
    return Container(
      child: Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Trabajos Existentes',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: tiposLocales.isEmpty
                    ? Center(
                        child: Text(
                          'No hay trabajos definidos',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: tiposLocales.length,
                        itemBuilder: (context, index) {
                          final key = tiposLocales.keys.elementAt(index);
                          final trabajo = tiposLocales[key]!;
                          final isSelected = tipoSeleccionado == key;

                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                            ),
                            color: isSelected
                                ? Color(0xFF1976D2).withOpacity(0.3)
                                : null,
                            child: ListTile(
                              title: Text(
                                trabajo.nombre,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                  'Bs ${trabajo.costo.toStringAsFixed(2)}'),
                              onTap: () {
                                setState(() {
                                  tipoSeleccionado = key;
                                  nombreController.text = trabajo.nombre;
                                  costoController.text =
                                      trabajo.costo.toString();
                                });
                              },
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
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      child: Container(
        width: 400,
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Editar Trabajo',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
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
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: anchoController,
                    decoration: InputDecoration(
                      labelText: 'Ancho (m)',
                      prefixIcon: Icon(Icons.straighten),
                    ),
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: altoController,
                    decoration: InputDecoration(
                      labelText: 'Alto (m)',
                      prefixIcon: Icon(Icons.height),
                    ),
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: cantidadController,
                    decoration: InputDecoration(
                      labelText: 'Cantidad',
                      prefixIcon: Icon(Icons.format_list_numbered),
                    ),
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: adicionalController,
                    decoration: InputDecoration(
                      labelText: 'Adicional (Bs)',
                      prefixIcon: Icon(Icons.add_circle_outline),
                    ),
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Subtotal:',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    'Bs ${subtotal.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[600],
                      foregroundColor: Colors.white,
                    ),
                    child: Text('CANCELAR'),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: subtotal > 0 ? _guardarCambios : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('GUARDAR'),
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
