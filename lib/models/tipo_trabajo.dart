class TipoTrabajo {
  final int? id;
  final String nombre;
  final double costo;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TipoTrabajo({
    this.id,
    required this.nombre,
    required this.costo,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'nombre': nombre,
        'costo': costo,
        if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
        if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
      };

  factory TipoTrabajo.fromJson(Map<String, dynamic> json) => TipoTrabajo(
        id: json['id'],
        nombre: json['nombre'],
        costo: json['costo'].toDouble(),
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'])
            : null,
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'])
            : null,
      );

  // Método para crear una copia con valores actualizados
  TipoTrabajo copyWith({
    int? id,
    String? nombre,
    double? costo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TipoTrabajo(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      costo: costo ?? this.costo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'TipoTrabajo(id: $id, nombre: $nombre, costo: $costo)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TipoTrabajo &&
        other.id == id &&
        other.nombre == nombre &&
        other.costo == costo;
  }

  @override
  int get hashCode => id.hashCode ^ nombre.hashCode ^ costo.hashCode;
}
