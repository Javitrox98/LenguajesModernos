// ignore_for_file: library_private_types_in_public_api, unused_local_variable, duplicate_ignore
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lenguajes/pages.dart';

class ListarProducto extends StatefulWidget {
  const ListarProducto({Key? key, required String elemento}) : super(key: key);

  @override
  _ListarProductoState createState() => _ListarProductoState();
}

class _ListarProductoState extends State<ListarProducto> {
  final CollectionReference productosCollection =
      FirebaseFirestore.instance.collection('productos');
  String _filtroNombre = "";

  Future<void> _confirmarEliminar(String id) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar producto'),
          content: const Text('¿Está seguro que desea eliminar este producto?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmado ?? false) {
      await productosCollection.doc(id).delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Buscar por nombre del producto',
                      prefixIcon: Icon(Icons.filter_alt_rounded),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                    keyboardType: TextInputType.name,
                    onChanged: (value) {
                      setState(() {
                        _filtroNombre = value;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: productosCollection.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final productoDocs = snapshot.data!.docs.where((doc) {
            final productoData = doc.data() as Map<String, dynamic>;
            if (_filtroNombre.isNotEmpty) {
              return productoData['nombre']
                  .toLowerCase()
                  .contains(_filtroNombre.toLowerCase());
            }
            return true;
          }).toList();

          if (productoDocs.isEmpty) {
            return const Center(child: Text('Producto no encontrado.'));
          }
          return ListView.separated(
            itemCount: productoDocs.length,
            separatorBuilder: (BuildContext context, int index) =>
                const Divider(),
            itemBuilder: (context, index) {
              final productoDoc = productoDocs[index];
              final productoData = productoDoc.data() as Map<String, dynamic>;
              final producto = Producto(
                id: productoDoc.id,
                codigo: productoData['codigo'],
                nombre: productoData['nombre'],
                descripcion: productoData['descripcion'],
                precio: productoData['precio'],
                stock: productoData['stock'],
              );

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VerProducto(producto: producto),
                    ),
                  );
                },
                child: Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                producto.nombre,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Stock: ${producto.stock}',
                                style: const TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                '\$${producto.precio}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () async {
                            final nuevoProducto = await Navigator.pushNamed(
                              context,
                              '/editarproducto',
                              arguments: producto,
                            ) as Producto?;
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _confirmarEliminar(productoDoc.id),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // ignore: unused_local_variable
          final nuevoProducto = await Navigator.pushNamed(
            context,
            '/nuevoproducto',
          ) as Producto?;
        },
        tooltip: 'Nuevo Producto',
        child: const Icon(Icons.add),
      ),
    );
  }
}
