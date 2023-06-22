// ignore_for_file: unused_field, prefer_const_declarations, avoid_print, duplicate_ignore

import 'package:flutter/material.dart';
import 'package:lenguajes/models/proyecto_models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NuevoProveedores extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final _rutController = TextEditingController();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _giroController = TextEditingController();

  NuevoProveedores({super.key});
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _proveedoresCollection =
      FirebaseFirestore.instance.collection('proveedores');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar proveedores'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Cerrar sesión'),
                    content: const Text(
                        '¿Estás seguro de que quieres cerrar la sesión?'),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Cancelar'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: const Text('Sí'),
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
        toolbarHeight: 70,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _rutController,
                decoration: const InputDecoration(
                  labelText: 'Rut',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'El Rut es obligatorio';
                  }

                  return null;
                },
              ),
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'El nombre es obligatorio';
                  }

                  // Expresión regular para validar que solo contenga letras
                  final lettersRegex = r'^[a-zA-Z]+$';
                  final regExp = RegExp(lettersRegex);

                  if (!regExp.hasMatch(value)) {
                    return 'El nombre solo debe contener letras';
                  }

                  return null;
                },
              ),
              TextFormField(
                controller: _apellidoController,
                decoration: const InputDecoration(
                  labelText: 'Apellido',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'El Apellido es obligatorio';
                  }

                  // Expresión regular para validar que solo contenga letras
                  final lettersRegex = r'^[a-zA-Z]+$';
                  final regExp = RegExp(lettersRegex);

                  if (!regExp.hasMatch(value)) {
                    return 'El Apellido solo debe contener letras';
                  }

                  return null;
                },
              ),
              TextFormField(
                controller: _giroController,
                decoration: const InputDecoration(
                  labelText: 'Ingredientes',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'El Ingrediente es obligatorio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    // ignore: non_constant_identifier_names
                    final NuevoProveedores = Proveedores(
                      nombre: _nombreController.text,
                      apellido: _apellidoController.text,
                      rut: _rutController.text,
                      giro: _giroController.text,
                      id: '',
                    );
                    final snapshot = await _proveedoresCollection
                        .where('nombre', isEqualTo: NuevoProveedores.nombre)
                        .where('apellido', isEqualTo: NuevoProveedores.apellido)
                        .where('rut', isEqualTo: NuevoProveedores.rut)
                        .where('giro', isEqualTo: NuevoProveedores.giro)
                        .get();

                    if (snapshot.docs.isEmpty) {
                      // Si no hay documentos que coincidan, añadir el turno
                      await _proveedoresCollection.add({
                        'nombre': NuevoProveedores.nombre,
                        'apellido': NuevoProveedores.apellido,
                        'rut': NuevoProveedores.rut,
                        'giro': NuevoProveedores.giro,
                      }).then((DocumentReference document) {
                        // Aquí creamos un nuevo objeto Turno con el id generado por Firestore.
                        final nuevoProveedoresConId = Proveedores(
                          id: document.id,
                          nombre: NuevoProveedores.nombre,
                          apellido: NuevoProveedores.apellido,
                          rut: NuevoProveedores.rut,
                          giro: NuevoProveedores.giro,
                        );
                        Navigator.pop(context, nuevoProveedoresConId);
                      }).catchError((error) {
                        // ignore: avoid_print
                        print("Error al añadir el turno: $error");
                      });
                    } else {
                      print(
                          "Este turno ya existe, no se agregará un duplicado.");
                    }
                  }
                },
                child: const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
