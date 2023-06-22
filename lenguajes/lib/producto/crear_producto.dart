// ignore_for_file: library_private_types_in_public_api, unused_element, use_build_context_synchronously, avoid_print, no_leading_underscores_for_local_identifiers, unused_local_variable, unused_field, deprecated_member_use
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lenguajes/pages.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

class NuevoProducto extends StatefulWidget {
  const NuevoProducto({Key? key}) : super(key: key);

  @override
  _NuevoProductoState createState() => _NuevoProductoState();
}

class _NuevoProductoState extends State<NuevoProducto> {
  final _formKey = GlobalKey<FormState>();
  final _codigoController = TextEditingController();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _precioController = TextEditingController();
  final _stockController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _imagenFile;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final CollectionReference _productosCollection =
      FirebaseFirestore.instance.collection('productos');

  int _ultimoId = 0;

  // Categorias
  List<String> _categorias = [];
  String? _selectedCategoria;

  @override
  void initState() {
    super.initState();
    loadCategorias();
  }

  void loadCategorias() async {
    final querySnapshot = await _firestore.collection('categorias').get();
    _categorias = querySnapshot.docs.map((doc) {
      final docData = doc.data();
      final nombre = docData['nombre'].toString();
      // ignore: unnecessary_string_interpolations
      return '$nombre';
    }).toList();
    setState(() {});
  }

  Future<void> _seleccionarImagen() async {
    final pickedFile = await _picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _imagenFile = File(pickedFile.path);
      }
    });
  }

  Future<String> _subirImagen(File imageFile) async {
    final ref = _storage
        .ref()
        .child('productos')
        .child('${DateTime.now().toIso8601String()}.jpg');
    final uploadTask = ref.putFile(imageFile);
    final taskSnapshot = await uploadTask.whenComplete(() {});
    final url = await taskSnapshot.ref.getDownloadURL();
    return url;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar producto'),
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _codigoController,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.code),
                    labelText: 'Código producto',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'El código es obligatorio';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<String>(
                  value: _selectedCategoria,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.category),
                    labelText: 'Categoria',
                  ),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedCategoria = newValue;
                    });
                  },
                  items:
                      _categorias.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'La categoria es obligatoria';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _nombreController,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.fastfood),
                    labelText: 'Nombre producto',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'El nombre es obligatorio';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _descripcionController,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.description),
                    labelText: 'Descripción producto',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'La descripción es obligatoria';
                    }
                    if (value.length > 150) {
                      return 'La descripción no puede tener más de 300 caracteres';
                    }
                    return null;
                  },
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 18),
                  child: TextFormField(
                    controller: _precioController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.monetization_on),
                      labelText: 'Precio producto',
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'El precio es obligatorio';
                      }
                      final double? parsedValue = double.tryParse(value);
                      if (parsedValue == null) {
                        return 'El precio debe ser un número';
                      }
                      if (parsedValue < 0) {
                        return 'El precio no puede ser negativo';
                      }
                      return null;
                    },
                  ),
                ),
                TextFormField(
                  controller: _stockController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.inventory),
                    labelText: 'Stock producto',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'El stock es obligatorio';
                    }
                    final int? parsedValue = int.tryParse(value);
                    if (parsedValue == null) {
                      return 'El stock debe ser un número entero';
                    }
                    if (parsedValue < 0) {
                      return 'El stock no puede ser negativo';
                    }
                    if (parsedValue == 0) {
                      return 'El stock no puede ser 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                GestureDetector(
                  onTap: _seleccionarImagen,
                  child: Container(
                    width: double.infinity,
                    height: 200,
                    color: Colors.grey.shade200,
                    child: _imagenFile != null
                        ? Image.file(
                            _imagenFile!,
                            fit: BoxFit.cover,
                          )
                        : const Icon(Icons.add_a_photo),
                  ),
                ),
                const SizedBox(height: 16.0),
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate() &&
                          _imagenFile != null) {
                        _formKey.currentState!.save();

                        final String imageUrl =
                            await _subirImagen(_imagenFile!);

                        final producto = {
                          'codigo': _codigoController.text,
                          'categoria': _selectedCategoria!,
                          'nombre': _nombreController.text,
                          'descripcion': _descripcionController.text,
                          'precio': _precioController.text,
                          'stock': int.parse(_stockController.text),
                          'imageUrl': imageUrl,
                        };

                        await _productosCollection.add(producto);

                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text('Agregar Producto'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
