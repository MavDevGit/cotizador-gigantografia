import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistema de Cotizaciones',
      theme: ThemeData(
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
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFF3A3A3A),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Color(0xFF1976D2)),
          ),
        ),
      ),
      home: CotizadorApp(),
    );
  }
}

class TipoTrabajo {
  String nombre;
  double costo;

  TipoTrabajo({required this.nombre, required this.costo});

  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'costo': costo,
      };

  factory TipoTrabajo.fromJson(Map<String, dynamic> json) => TipoTrabajo(
        nombre: json['nombre'],
        costo: json['costo'].toDouble(),
      );
}

class ItemCotizacion {
  String tipo;
  double cantidad;
  double ancho;
  double alto;
  double costo;

  ItemCotizacion({
    required this.tipo,
    required this.cantidad,
    required this.ancho,
    required this.alto,
    required this.costo,
  });

  Map<String, dynamic> toJson() => {
        'tipo': tipo,
        'cantidad': cantidad,
        'ancho': ancho,
        'alto': alto,
        'costo': costo,
      };

  factory ItemCotizacion.fromJson(Map<String, dynamic> json) => ItemCotizacion(
        tipo: json['tipo'],
        cantidad: json['cantidad'].toDouble(),
        ancho: json['ancho'].toDouble(),
        alto: json['alto'].toDouble(),
        costo: json['costo'].toDouble(),
      );
}

class CotizadorApp extends StatefulWidget {
  @override
  _CotizadorAppState createState() => _CotizadorAppState();
}

class _CotizadorAppState extends State<CotizadorApp> {
  Map<String, TipoTrabajo> tiposDeTrabajos = {};
  List<ItemCotizacion> itemsCotizacion = [];

  final TextEditingController anchoController = TextEditingController();
  final TextEditingController altoController = TextEditingController();
  final TextEditingController cantidadController = TextEditingController();

  String? tipoSeleccionado;
  double subtotal = 0.0;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
    _setupListeners();
  }

  void _setupListeners() {
    anchoController.addListener(_actualizarSubtotal);
    altoController.addListener(_actualizarSubtotal);
    cantidadController.addListener(_actualizarSubtotal);
  }

  Future<void> _cargarDatos() async {
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
      setState(() => subtotal = cantidad * ancho * alto * trabajo.costo);
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
      final costo = cantidad * ancho * alto * trabajo.costo;

      if (costo <= 0) return;

      setState(() {
        itemsCotizacion.add(ItemCotizacion(
          tipo: trabajo.nombre,
          cantidad: cantidad,
          ancho: ancho,
          alto: alto,
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
        title: Text('Sistema de Cotizaciones Profesional'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => _mostrarGestionTrabajos(),
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
        Expanded(child: _buildResumenCotizacion()),
      ],
    );
  }

  Widget _buildFormularioEntrada() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Añadir Nuevo Trabajo',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              SizedBox(height: 16),
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
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d*')),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: cantidadController,
                decoration: InputDecoration(
                  labelText: 'Cantidad',
                  prefixIcon: Icon(Icons.numbers),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
              ),
              SizedBox(height: 24),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFF1976D2).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Color(0xFF1976D2)),
                ),
                child: Text(
                  'Bs ${subtotal.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1976D2),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _anadirItem,
                icon: Icon(Icons.add),
                label: Text('Añadir a la Cotización'),
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
      padding: EdgeInsets.all(16),
      child: Card(
        child: Column(
          children: [
            Padding(
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
                    IconButton(
                      icon: Icon(Icons.clear_all),
                      onPressed: () {
                        setState(() {
                          itemsCotizacion.clear();
                        });
                      },
                      tooltip: 'Limpiar todo',
                    ),
                ],
              ),
            ),
            if (itemsCotizacion.isEmpty)
              Expanded(
                child: Center(
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
                        'No hay elementos en la cotización',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              Expanded(
                child: ListView.builder(
                  itemCount: itemsCotizacion.length,
                  itemBuilder: (context, index) {
                    final item = itemsCotizacion[index];

                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        title: Text(
                          item.tipo,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                            '${item.ancho}m × ${item.alto}m × ${item.cantidad}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Bs ${item.costo.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF28B463),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editarItem(index),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _eliminarItem(index),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFF28B463).withOpacity(0.1),
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
    showDialog(
      context: context,
      builder: (context) => GestionTrabajosDialog(
        tiposDeTrabajos: tiposDeTrabajos,
        onSave: (nuevosTipos) {
          setState(() {
            tiposDeTrabajos = nuevosTipos;
            if (tiposDeTrabajos.isNotEmpty &&
                !tiposDeTrabajos.containsKey(tipoSeleccionado)) {
              tipoSeleccionado = tiposDeTrabajos.keys.first;
            }
          });
          _guardarDatos();
          _actualizarSubtotal();
        },
      ),
    );
  }
}

class GestionTrabajosDialog extends StatefulWidget {
  final Map<String, TipoTrabajo> tiposDeTrabajos;
  final Function(Map<String, TipoTrabajo>) onSave;

  GestionTrabajosDialog({required this.tiposDeTrabajos, required this.onSave});

  @override
  _GestionTrabajosDialogState createState() => _GestionTrabajosDialogState();
}

class _GestionTrabajosDialogState extends State<GestionTrabajosDialog> {
  late Map<String, TipoTrabajo> tiposLocales;
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController costoController = TextEditingController();
  String? tipoSeleccionado;

  @override
  void initState() {
    super.initState();
    tiposLocales = Map.from(widget.tiposDeTrabajos);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          children: [
            AppBar(
              title: Text('Gestionar Tipos de Trabajo'),
              automaticallyImplyLeading: false,
              actions: [
                TextButton(
                  onPressed: () {
                    widget.onSave(tiposLocales);
                    Navigator.of(context).pop();
                  },
                  child: Text('GUARDAR', style: TextStyle(color: Colors.white)),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: _buildFormularioTrabajo(),
                  ),
                  Expanded(
                    child: _buildListaTrabajos(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormularioTrabajo() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Añadir/Editar Trabajo',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: nombreController,
            decoration: InputDecoration(
              labelText: 'Nombre del Trabajo',
              prefixIcon: Icon(Icons.work),
            ),
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: costoController,
            decoration: InputDecoration(
              labelText: 'Costo (Bs)',
              prefixIcon: Icon(Icons.attach_money),
            ),
            keyboardType: TextInputType.number,
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
    );
  }

  Widget _buildListaTrabajos() {
    return Container(
      padding: EdgeInsets.all(16),
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
                        color: isSelected
                            ? Color(0xFF1976D2).withOpacity(0.3)
                            : null,
                        child: ListTile(
                          title: Text(
                            trabajo.nombre,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle:
                              Text('Bs ${trabajo.costo.toStringAsFixed(2)}'),
                          onTap: () {
                            setState(() {
                              tipoSeleccionado = key;
                              nombreController.text = trabajo.nombre;
                              costoController.text = trabajo.costo.toString();
                            });
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _anadirTrabajo() {
    final nombre = nombreController.text.trim();
    final costo = double.tryParse(costoController.text);

    if (nombre.isNotEmpty && costo != null && costo > 0) {
      if (!tiposLocales.containsKey(nombre)) {
        setState(() {
          tiposLocales[nombre] = TipoTrabajo(nombre: nombre, costo: costo);
        });
        _limpiarCampos();
      }
    }
  }

  void _actualizarTrabajo() {
    if (tipoSeleccionado == null) return;

    final nombre = nombreController.text.trim();
    final costo = double.tryParse(costoController.text);

    if (nombre.isNotEmpty && costo != null && costo > 0) {
      setState(() {
        if (tipoSeleccionado != nombre) {
          tiposLocales.remove(tipoSeleccionado);
        }
        tiposLocales[nombre] = TipoTrabajo(nombre: nombre, costo: costo);
        tipoSeleccionado = nombre;
      });
      _limpiarCampos();
    }
  }

  void _eliminarTrabajo() {
    if (tipoSeleccionado != null) {
      setState(() {
        tiposLocales.remove(tipoSeleccionado);
        tipoSeleccionado = null;
      });
      _limpiarCampos();
    }
  }

  void _limpiarCampos() {
    nombreController.clear();
    costoController.clear();
    setState(() {
      tipoSeleccionado = null;
    });
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

    _setupListeners();
    _actualizarSubtotal();
  }

  void _setupListeners() {
    anchoController.addListener(_actualizarSubtotal);
    altoController.addListener(_actualizarSubtotal);
    cantidadController.addListener(_actualizarSubtotal);
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
      setState(() => subtotal = cantidad * ancho * alto * trabajo.costo);
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
      final costo = cantidad * ancho * alto * trabajo.costo;

      if (costo <= 0) return;

      final itemEditado = ItemCotizacion(
        tipo: trabajo.nombre,
        cantidad: cantidad,
        ancho: ancho,
        alto: alto,
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
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: cantidadController,
              decoration: InputDecoration(
                labelText: 'Cantidad',
                prefixIcon: Icon(Icons.numbers),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
            ),
            SizedBox(height: 24),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF1976D2).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Color(0xFF1976D2)),
              ),
              child: Text(
                'Bs ${subtotal.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1976D2),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Cancelar'),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _guardarCambios,
                    child: Text('Guardar'),
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
    super.dispose();
  }
}
