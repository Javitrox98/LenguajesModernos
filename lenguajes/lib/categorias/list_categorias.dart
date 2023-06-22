// ignore_for_file: unused_local_variable, library_private_types_in_public_api

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lenguajes/pages.dart';

class ListarCategoria extends StatefulWidget {
  const ListarCategoria({Key? key, required String elemento}) : super(key: key);

  @override
  _ListarCategoriaState createState() => _ListarCategoriaState();
}

class _ListarCategoriaState extends State<ListarCategoria> {
  final CollectionReference categoriasCollection =
      FirebaseFirestore.instance.collection('categorias');
  String _filtroNombre = "";

  Future<void> _confirmarEliminar(String id) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar Categoria'),
          content:
              const Text('¿Está seguro que desea eliminar esta categoria?'),
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
      await categoriasCollection.doc(id).delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorias'),
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
                      hintText: 'Buscar por categoria',
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
        stream: categoriasCollection.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final categoriaDocs = snapshot.data!.docs.where((doc) {
            final categoriaData = doc.data() as Map<String, dynamic>;
            if (_filtroNombre.isNotEmpty) {
              return categoriaData['nombre']
                  .toLowerCase()
                  .contains(_filtroNombre.toLowerCase());
            }
            return true;
          }).toList();

          if (categoriaDocs.isEmpty) {
            return const Center(child: Text('Categoria no encontrada.'));
          }

          return Padding(
              padding: const EdgeInsets.only(top: 20),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                itemCount: categoriaDocs.length,
                itemBuilder: (context, index) {
                  final categoriaDoc = categoriaDocs[index];
                  final categoriaData =
                      categoriaDoc.data() as Map<String, dynamic>;
                  final categoria = Categoria(
                    id: categoriaDoc.id,
                    nombre: categoriaData['nombre'],
                    imageUrl: categoriaData['imageUrl'],
                  );
                  return GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/detallecategoria',
                          arguments: categoria);
                    },
                    onLongPress: () {
                      showModalBottomSheet<void>(
                        context: context,
                        builder: (BuildContext context) {
                          // ignore: avoid_unnecessary_containers
                          return Container(
                            child: Wrap(
                              children: <Widget>[
                                ListTile(
                                  leading: const Icon(Icons.edit),
                                  title: const Text('Editar'),
                                  onTap: () async {
                                    Navigator.pop(context);
                                    final nuevoCategoria =
                                        await Navigator.pushNamed(
                                            context, '/editarcategoria',
                                            arguments: categoria) as Categoria?;
                                    if (nuevoCategoria != null) {
                                      setState(() {});
                                    }
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.delete),
                                  title: const Text('Eliminar'),
                                  onTap: () =>
                                      _confirmarEliminar(categoriaDoc.id),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    child: Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 1, horizontal: 1),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: Colors.black,
                                      width: 1,
                                    ),
                                  ),
                                  child: categoria.imageUrl != null
                                      ? Image.network(
                                          categoria.imageUrl!,
                                          width: 105,
                                          height: 105,
                                          fit: BoxFit.cover,
                                        )
                                      : Container(
                                          width: 130,
                                          height: 130,
                                          color: Colors.blue,
                                          child: const Icon(
                                            Icons.image,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                categoria.nombre,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final nuevoCategoria = await Navigator.pushNamed(
            context,
            '/nuevocategoria',
          ) as Categoria?;
        },
        tooltip: 'Nueva Categoria',
        child: const Icon(Icons.add),
      ),
    );
  }
}
