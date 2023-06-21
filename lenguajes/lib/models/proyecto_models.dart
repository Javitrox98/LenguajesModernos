import 'dart:io';

class Producto {
  final String id;
  final String codigo;
  final String nombre;
  final String descripcion;
  final String precio;
  int stock;
  final String? imageUrl;
  int contador;

  Producto({
    required this.id,
    required this.codigo,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.stock,
    required this.imageUrl,
    this.contador = 0,
  });

  File? get imagenFile => null;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'codigo': codigo,
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'stock': stock,
      'imageUrl': imageUrl,
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
      imageUrl: map['imageUrl'], // Se ha cambiado de imagenFile a imageUrl
    );
  }
}

class Proveedores {
  final String id;
  final String nombre;
  final String apellido;
  final String rut;
  final String giro;

  Proveedores({
    required this.id,
    required this.nombre,
    required this.rut,
    required this.apellido,
    required this.giro,
  });
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'apellido': apellido,
      'rut': rut,
      'giro': giro,
    };
  }

  factory Proveedores.fromMap(Map<String, dynamic> map) {
    return Proveedores(
      id: map['id'],
      nombre: map['nombre'],
      rut: map['rut'],
      apellido: 'apellido',
      giro: 'giro',
    );
  }
}
