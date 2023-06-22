// ignore_for_file: library_private_types_in_public_api, avoid_print, duplicate_ignore

import 'package:flutter/material.dart';
import 'package:lenguajes/models/proyecto_models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lenguajes/pages.dart';

class EditarProveedores extends StatefulWidget {
  final Proveedores proveedores;

  const EditarProveedores({Key? key, required this.proveedores})
      : super(key: key);

  @override
  _EditarProveedoresState createState() => _EditarProveedoresState();
}

class _EditarProveedoresState extends State<EditarProveedores> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _rutController;
  late final TextEditingController _nombreController;
  late final TextEditingController _apellidoController;
  late final TextEditingController _giroController;

  @override
  void initState() {
    super.initState();
    _rutController = TextEditingController(text: widget.proveedores.rut);
    _nombreController = TextEditingController(text: widget.proveedores.nombre);
    _apellidoController =
        TextEditingController(text: widget.proveedores.apellido);
    _giroController = TextEditingController(text: widget.proveedores.giro);
  }

  Future<void> _updateProveedores(Proveedores proveedores) async {
    try {
      final documentReference = FirebaseFirestore.instance
          .collection('proveedores')
          .doc(proveedores.id);

      final documentSnapshot = await documentReference.get();

      if (documentSnapshot.exists) {
        await documentReference.update(proveedores.toMap());
        // ignore: avoid_print
        print('Proveedor actualizado correctamente');
      } else {
        // ignore: avoid_print
        print('El proveedor no existe');
      }
    } catch (e) {
      print('Error al editar proveedor: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar proveedores'),
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
                  icon: Icon(Icons.perm_identity),
                  labelText: 'Rut',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'El Rut es obligatorio';
                  }
                  const rutRegex = r'^\d{7,8}-[kK\d]{1}$';
                  final regExp = RegExp(rutRegex);

                  if (!regExp.hasMatch(value)) {
                    return 'Rut inválido';
                  }

                  return null;
                },
              ),
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  icon: Icon(Icons.person),
                  labelText: 'Nombre',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'El nombre es obligatorio';
                  }

                  const lettersRegex = r'^[a-zA-Z]+$';
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
                  icon: Icon(Icons.perm_identity),
                  labelText: 'Apellido',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'El Apellido es obligatorio';
                  }

                  const lettersRegex = r'^[a-zA-Z]+$';
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
                  icon: Icon(Icons.food_bank),
                  labelText: 'Ingredientes',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'El ingrediente es obligatorio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final proveedoresEditado = Proveedores(
                        rut: _rutController.text,
                        nombre: _nombreController.text,
                        apellido: _apellidoController.text,
                        giro: _giroController.text,
                        id: widget.proveedores
                            .id, // Usamos el ID existente del proveedor
                      );
                      _updateProveedores(proveedoresEditado).then((_) {
                        Navigator.pop(context);
                      });
                    }
                  },
                  child: const Text('Guardar cambios'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
