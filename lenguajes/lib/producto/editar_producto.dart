// ignore_for_file: unused_field, library_private_types_in_public_api, prefer_final_fields, unnecessary_null_comparison
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lenguajes/pages.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class EditarProducto extends StatefulWidget {
  final Producto producto;

  const EditarProducto({Key? key, required this.producto}) : super(key: key);

  @override
  _EditarProductoState createState() => _EditarProductoState();
}

class _EditarProductoState extends State<EditarProducto> {
  final _formKey = GlobalKey<FormState>();
  final _codigoController = TextEditingController();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _precioController = TextEditingController();
  final _stockController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _imagenFile;
  String? _imageUrl;
  int _stock = 0;

  List<String> _categorias = [];
  String? _selectedCategoria;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadCategorias();
    });
  }

  void loadCategorias() async {
    final querySnapshot = await _firestore.collection('categorias').get();
    _categorias = querySnapshot.docs.map((doc) {
      final docData = doc.data();
      final nombre = docData['nombre'].toString();
      // ignore: unnecessary_string_interpolations
      return '$nombre';
    }).toList();

    _selectedCategoria = widget.producto.categoria;

    setState(() {});

    _codigoController.text = widget.producto.codigo;
    _nombreController.text = widget.producto.nombre;
    _descripcionController.text = widget.producto.descripcion;
    _precioController.text = widget.producto.precio;
    _stockController.text = widget.producto.stock.toString();
    _imagenFile = widget.producto.imagenFile;
    _imageUrl = widget.producto.imageUrl;
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
        .child('productos')
        .child('${DateTime.now().toIso8601String()}.jpg');
    final uploadTask = ref.putFile(imageFile);
    final taskSnapshot = await uploadTask.whenComplete(() {});
    final url = await taskSnapshot.ref.getDownloadURL();
    return url;
  }

  Future<void> _updateProducto(Producto producto) async {
    FirebaseFirestore.instance
        .collection('productos')
        .doc(producto.id)
        .update(producto.toMap());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar producto'),
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
                    icon: Icon(Icons.qr_code),
                    labelText: 'Código',
                  ),
                  style: const TextStyle(
                    color: Color.fromARGB(255, 153, 153, 153),
                  ),
                  enabled: false, // No se puede editar
                ),
                DropdownButtonFormField<String>(
                  value: _selectedCategoria,
                  icon: const Icon(Icons.arrow_downward),
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
                    labelText: 'Nombre producto ',
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
                  maxLength: 50,
                  decoration: InputDecoration(
                    icon: const Icon(Icons.description),
                    labelText: 'Descripción producto',
                    counterText: '${_descripcionController.text.length} / 50',
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'La descripción es obligatoria';
                    }
                    if (value.length > 50) {
                      return 'La descripción no puede tener más de 50 caracteres';
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
                      if (parsedValue == 0) {
                        return 'El precio no puede ser 0';
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
                    labelText: 'Stock',
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
                    child: _imageUrl != null
                        ? Image.network(
                            _imageUrl!,
                            fit: BoxFit.cover,
                          )
                        : widget.producto.imageUrl != null
                            ? Image.network(
                                widget.producto.imageUrl!,
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
                              widget.producto.imageUrl != null) &&
                          (_selectedCategoria != null ||
                              widget.producto.categoria != null)) {
                        final nuevoProducto = Producto(
                          id: widget.producto.id,
                          categoria: _selectedCategoria!,
                          codigo: _codigoController.text,
                          nombre: _nombreController.text,
                          descripcion: _descripcionController.text,
                          precio: _precioController.text,
                          stock: int.parse(_stockController.text),
                          // ignore: prefer_if_null_operators
                          imageUrl: _imageUrl != null
                              ? _imageUrl
                              : widget.producto.imageUrl,
                        );
                        _updateProducto(nuevoProducto).then((_) {
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
