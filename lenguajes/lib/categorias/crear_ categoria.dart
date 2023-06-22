// ignore_for_file: library_private_types_in_public_api, deprecated_member_use, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lenguajes/pages.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class NuevoCategoria extends StatefulWidget {
  const NuevoCategoria({Key? key}) : super(key: key);

  @override
  _NuevoCategoriaState createState() => _NuevoCategoriaState();
}

class _NuevoCategoriaState extends State<NuevoCategoria> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _imagenFile;

  // ignore: unused_field
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final CollectionReference _categoriasCollection =
      FirebaseFirestore.instance.collection('categorias');

  int _ultimoId = 0;
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
        .child('categorias')
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
        title: const Text('Agregar categoria'),
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
                  controller: _nombreController,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.cake_sharp),
                    labelText: 'Nombre Categoria',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'El nombre es obligatorio';
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
                      if (_formKey.currentState!.validate()) {
                        if (_imagenFile == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Debe subir una imagen.')));
                          return;
                        }
                        final imageUrl = await _subirImagen(_imagenFile!);
                        final nuevoId = (_ultimoId + 1).toString();
                        _ultimoId++;
                        final nuevoCategoria = Categoria(
                          id: nuevoId,
                          nombre: _nombreController.text,
                          imageUrl: imageUrl,
                        );

                        final snapshot = await _categoriasCollection
                            .where('id', isEqualTo: nuevoCategoria.id)
                            .get();

                        if (snapshot.docs.isEmpty) {
                          await _categoriasCollection
                              .add(nuevoCategoria.toMap())
                              .then((document) {
                            final nuevoCategoriaConId = Categoria(
                              id: nuevoId,
                              nombre: nuevoCategoria.nombre,
                              imageUrl: nuevoCategoria.imageUrl,
                            );

                            Navigator.pop(context, nuevoCategoriaConId);
                          }).catchError((error) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Error al añadir el categoria: $error'),
                              ),
                            );
                          }).catchError((error) {
                            // ignore: avoid_print
                            print('Error al añadir La categoria: $error');
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Esta categoria ya existe, no se agregará un duplicado.'),
                            ),
                          );
                        }
                      }
                    },
                    child: const Text('Guardar'),
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
