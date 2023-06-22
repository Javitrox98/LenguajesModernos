// ignore_for_file: library_private_types_in_public_api

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lenguajes/pages.dart';

class DetalleCategoriaPage extends StatefulWidget {
  final Categoria categoria;

  const DetalleCategoriaPage({
    Key? key,
    required this.categoria,
  }) : super(key: key);

  @override
  _DetalleCategoriaPageState createState() => _DetalleCategoriaPageState();
}

class _DetalleCategoriaPageState extends State<DetalleCategoriaPage> {
  final CollectionReference productosCollection =
      FirebaseFirestore.instance.collection('productos');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoria.nombre),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: productosCollection.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No hay productos para esta categoría.'),
            );
          }

          final productoDocs = snapshot.data!.docs.where((doc) {
            final productoData = doc.data() as Map<String, dynamic>;
            return productoData['categoria'] == widget.categoria.nombre;
          }).toList();

          if (productoDocs.isEmpty) {
            return const Center(
              child: Text('No hay productos para esta categoría.'),
            );
          }

          return ListView.builder(
            itemCount: productoDocs.length,
            itemBuilder: (context, index) {
              final productoDoc = productoDocs[index];
              final productoData = productoDoc.data() as Map<String, dynamic>;
              final producto = Producto(
                id: productoDoc.id,
                codigo: productoData['codigo'],
                nombre: productoData['nombre'],
                descripcion: productoData['descripcion'],
                precio: productoData['precio'].toString(),
                stock: productoData['stock'],
                imageUrl: productoData['imageUrl'],
                categoria: productoData['categoria'],
              );
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: producto.imageUrl != null
                            ? Image.network(
                                producto.imageUrl!,
                                width: 115,
                                height: 115,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: 115,
                                height: 115,
                                color: Colors.grey,
                                child: const Icon(
                                  Icons.image,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              producto.nombre,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 25,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Stock: ${producto.stock}',
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '\$${producto.precio}', // Display price with 2 decimal places
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
