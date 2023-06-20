class Producto {
  final String id;
  final String codigo;
  final String nombre;
  final String descripcion;
  final String precio;
  int stock;

  Producto({
    required this.id,
    required this.codigo,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.stock,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'codigo': codigo,
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'stock': stock,
    };
  }

  factory Producto.fromMap(Map<String, dynamic> map) {
    return Producto(
      id: map['id'],
      codigo: map['codigo'],
      nombre: map['nombre'],
      descripcion: map['descripcion'],
      precio: map['precio'],
      stock: map['stock'],
    );
  }
}
