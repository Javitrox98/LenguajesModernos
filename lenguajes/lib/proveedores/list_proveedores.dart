// ignore_for_file: library_private_types_in_public_api

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lenguajes/pages.dart';

class ListarProveedores extends StatefulWidget {
  const ListarProveedores({Key? key, required String elemento})
      : super(key: key);

  @override
  _ListarProveedoresState createState() => _ListarProveedoresState();
}

class _ListarProveedoresState extends State<ListarProveedores> {
  final CollectionReference proveedoresCollection =
      FirebaseFirestore.instance.collection('proveedores');

  String? _filtroNombre;

  Future<void> _confirmarEliminar(String id) async {
    final confirmado = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar Proveedores'),
          content:
              const Text('¿Está seguro que desea eliminar este Proveedores?'),
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

    if (confirmado) {
      await proveedoresCollection.doc(id).delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Proveedores'),
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
                      hintText: 'Buscar por nombre del proveedor',
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
        stream: proveedoresCollection.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final proveedoresDocs = snapshot.data!.docs.where((doc) {
            final proveedoresData = doc.data() as Map<String, dynamic>;
            if (_filtroNombre != null) {
              final nombre = proveedoresData['nombre'] ?? '';
              final apellido = proveedoresData['apellido'] ?? '';
              final nombreCompleto = '$nombre $apellido'.toLowerCase();
              return nombreCompleto.contains(_filtroNombre!.toLowerCase());
            }
            return true;
          }).toList();
          return ListView.separated(
            itemCount: proveedoresDocs.length,
            separatorBuilder: (BuildContext context, int index) =>
                const Divider(),
            itemBuilder: (context, index) {
              final proveedoresDoc = proveedoresDocs[index];
              final proveedoresData =
                  proveedoresDoc.data() as Map<String, dynamic>;
              final proveedores = Proveedores(
                id: proveedoresDoc.id,
                nombre: proveedoresData['nombre'] ?? '',
                rut: proveedoresData['rut'] != null
                    ? proveedoresData['rut'].toString()
                    : '',
                apellido: proveedoresData['apellido'] ?? '',
                giro: proveedoresData['giro'] != null
                    ? proveedoresData['giro'].toString()
                    : '',
              );
              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: ListTile(
                    title: Text(
                      ' ${proveedores.nombre}  ${proveedores.apellido} ',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rut: ${proveedores.rut}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        Text(
                          'giro : ${proveedores.giro} ',
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 3),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () async {
                            final EditarProveedores = await Navigator.pushNamed(
                              context,
                              '/editarproveedores',
                              arguments: proveedores,
                            ) as Proveedores?;
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            _confirmarEliminar(proveedoresDoc.id);
                          },
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
          final NuevoProveedores = await Navigator.pushNamed(
            context,
            '/nuevoproveedores',
          ) as Proveedores?;
        },
        child: const Icon(Icons.person_add),
      ),
    );
  }
}
