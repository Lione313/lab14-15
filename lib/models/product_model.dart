class ProductModel {
  final String id;
  final String nombre;
  final String descripcion;
  final DateTime fechaVencimiento;
  final double precio;
  final String backgroundImg; 

  ProductModel({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.fechaVencimiento,
    required this.precio,
    required this.backgroundImg,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      fechaVencimiento: DateTime.parse(json['fechaVencimiento']),
      precio: (json['precio'] as num).toDouble(),
      backgroundImg: json['backgroundImg'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'fechaVencimiento': fechaVencimiento.toIso8601String(),
      'precio': precio,
      'backgroundImg': backgroundImg,
    };
  }
}
