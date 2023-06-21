// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

class Categoria {
  final String nombre;
  final String descripcion;

  Categoria({required this.nombre, required this.descripcion});
}

class ListaCategoriasPage extends StatefulWidget {
  final List<Categoria> categorias;

  ListaCategoriasPage({required this.categorias});

  @override
  _ListaCategoriasPageState createState() => _ListaCategoriasPageState();
}

class _ListaCategoriasPageState extends State<ListaCategoriasPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Categorías'),
      ),
      body: ListView.builder(
        itemCount: widget.categorias.length,
        itemBuilder: (context, index) {
          Categoria categoria = widget.categorias[index];
          return ListTile(
            title: Text(categoria.nombre),
            subtitle: Text(categoria.descripcion),
          );
        },
      ),
    );
  }
}

class CrearCategoria extends StatefulWidget {
  // ignore: use_key_in_widget_constructors
  const CrearCategoria({Key? key, required String elemento});

  @override
  _CrearCategoriaState createState() => _CrearCategoriaState();
}

class _CrearCategoriaState extends State<CrearCategoria> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  List<Categoria> categorias = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Categoría'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre',
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _descripcionController,
              decoration: const InputDecoration(
                labelText: 'Descripción',
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Aquí puedes implementar la lógica para guardar la categoría
                String nombre = _nombreController.text;
                String descripcion = _descripcionController.text;
                guardarCategoria(nombre, descripcion);
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  void guardarCategoria(String nombre, String descripcion) {
    Categoria nuevaCategoria =
        Categoria(nombre: nombre, descripcion: descripcion);
    categorias.add(nuevaCategoria);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Categoría Guardada'),
          content:
              Text('La categoría "$nombre" ha sido guardada exitosamente.'),
          actions: [
            TextButton(
              child: const Text('Aceptar'),
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ListaCategoriasPage(categorias: categorias),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
