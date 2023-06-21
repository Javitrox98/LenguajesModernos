import 'package:flutter/material.dart';

class Categoria {
  final String nombre;
  final String descripcion;

  Categoria({required this.nombre, required this.descripcion});
}

class ListaCategoriasPage extends StatelessWidget {
  final List<Categoria> categorias;

  ListaCategoriasPage({required this.categorias});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Categorías'),
      ),
      body: ListView.builder(
        itemCount: categorias.length,
        itemBuilder: (context, index) {
          Categoria categoria = categorias[index];
          return ListTile(
            title: Text(categoria.nombre),
            subtitle: Text(categoria.descripcion),
          );
        },
      ),
    );
  }
}
