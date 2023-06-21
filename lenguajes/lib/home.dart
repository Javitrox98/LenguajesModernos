import 'package:lenguajes/categorias/list_categorias.dart';
import 'package:lenguajes/pages.dart';
import 'package:lenguajes/proveedores/list_proveedores.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: const Text('Cerrar sesión'),
                  content:
                      const Text('¿Estás seguro de que quieres cerrar sesión?'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      child: const Text('Si'),
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: const Center(child: Text('¡Bienvenido!')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              // ignore: sort_child_properties_last
              child: Text('Menu'),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              title: const Text('Productos'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ListarProducto(
                            elemento: '',
                          )),
                );
              },
            ),
            ListTile(
              title: const Text('Categorías'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CrearCategoria(
                            elemento: '',
                          )),
                );
              },
              // Aquí puedes navegar a la página de categorías
            ),
            ListTile(
              title: const Text('Proveedores'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ListarProveedores(
                            elemento: '',
                          )),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
