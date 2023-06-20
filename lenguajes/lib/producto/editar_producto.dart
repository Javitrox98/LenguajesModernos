// ignore_for_file: unused_field, library_private_types_in_public_api, prefer_final_fields
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lenguajes/pages.dart';

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
  int _stock = 0;

  @override
  void initState() {
    super.initState();

    _codigoController.text = widget.producto.codigo;
    _nombreController.text = widget.producto.nombre;
    _descripcionController.text = widget.producto.descripcion;
    _precioController.text = widget.producto.precio;
    _stockController.text = widget.producto.stock.toString();
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
                    icon: Icon(Icons.qr_code),
                    labelText: 'Código',
                  ),
                  style: const TextStyle(
                    color: Color.fromARGB(255, 153, 153, 153),
                  ),
                  enabled: false, // No se puede editar
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
                const SizedBox(height: 16.0),
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final nuevoProducto = Producto(
                          id: widget.producto.id,
                          codigo: _codigoController.text,
                          nombre: _nombreController.text,
                          descripcion: _descripcionController.text,
                          precio: _precioController.text,
                          stock: int.parse(_stockController.text),
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
