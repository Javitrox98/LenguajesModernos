// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

class CrearCategoria extends StatefulWidget {
  // ignore: use_key_in_widget_constructors
  const CrearCategoria({Key? key, required String elemento});

  @override
  _CrearCategoriaState createState() => _CrearCategoriaState();
}

class _CrearCategoriaState extends State<CrearCategoria> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();

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
    // Aquí puedes implementar la lógica para guardar la categoría en tu base de datos o en algún otro lugar
    // Por ejemplo, puedes llamar a una función en tu API para enviar los datos al servidor
    // O puedes guardar los datos localmente usando algún gestor de estado o una base de datos local

    // Aquí solo mostramos un mensaje de confirmación
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
                // Cerrar el diálogo y la pantalla de creación de categorías
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
