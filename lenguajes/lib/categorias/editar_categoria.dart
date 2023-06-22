// ignore_for_file: library_private_types_in_public_api

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lenguajes/pages.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class EditarCategoria extends StatefulWidget {
  final Categoria categoria;

  const EditarCategoria({Key? key, required this.categoria}) : super(key: key);

  @override
  _EditarCategoriaState createState() => _EditarCategoriaState();
}

class _EditarCategoriaState extends State<EditarCategoria> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  // ignore: unused_field
  File? _imagenFile;
  String? _imageUrl;
  // ignore: unused_field
  final int _stock = 0;

  @override
  void initState() {
    super.initState();

    _nombreController.text = widget.categoria.nombre;
    _imagenFile = widget.categoria.imagenFile;
    _imageUrl = widget.categoria.imageUrl;
  }

  Future<void> _seleccionarImagen() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      _imageUrl = await _subirImagen(File(pickedFile.path));
    }
  }

  Future<String> _subirImagen(File imageFile) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('categoria')
        .child('${DateTime.now().toIso8601String()}.jpg');
    final uploadTask = ref.putFile(imageFile);
    final taskSnapshot = await uploadTask.whenComplete(() {});
    final url = await taskSnapshot.ref.getDownloadURL();
    return url;
  }

  Future<void> _updateCategoria(Categoria categoria) async {
    FirebaseFirestore.instance
        .collection('productos')
        .doc(categoria.id)
        .update(categoria.toMap());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Categoria'),
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
                    icon: Icon(Icons.fastfood),
                    labelText: 'Nombre Categoria ',
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
                    child: _imageUrl != null
                        ? Image.network(
                            _imageUrl!,
                            fit: BoxFit.cover,
                          )
                        : widget.categoria.imageUrl != null
                            ? Image.network(
                                widget.categoria.imageUrl!,
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
                          (_imageUrl != null ||
                              widget.categoria.imageUrl != null)) {
                        final nuevoCategoria = Categoria(
                          id: widget.categoria.id,
                          nombre: _nombreController.text,
                          imageUrl: _imageUrl ?? widget.categoria.imageUrl,
                        );
                        _updateCategoria(nuevoCategoria).then((_) {
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
      ),
    );
  }
}
