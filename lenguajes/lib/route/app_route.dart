import 'package:lenguajes/home.dart';
import 'package:lenguajes/page_error.dart';
import 'package:lenguajes/pages.dart';
import 'package:lenguajes/proveedores/crear_proveedores.dart';
import 'package:lenguajes/proveedores/editar_proveedores.dart';
import 'package:lenguajes/proveedores/list_proveedores.dart';

class AppRoute {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/home':
        return MaterialPageRoute(builder: (_) => const HomePage());
      case '/login':
        return MaterialPageRoute(builder: (_) => const Login());

      //**PRODUCTO
      case '/listarproducto':
        return MaterialPageRoute(
            builder: (_) => const ListarProducto(
                  elemento: '',
                ));

      case '/nuevoproducto':
        return MaterialPageRoute(
          builder: (_) => const NuevoProducto(),
          fullscreenDialog: true,
        );

      case '/editarproducto':
        final producto = settings.arguments as Producto;
        return MaterialPageRoute(
          builder: (_) => EditarProducto(producto: producto),
          fullscreenDialog: true,
        );
      //** PROVEEDORES
      case '/listaproveedores':
        return MaterialPageRoute(
            builder: (_) => const ListarProveedores(
                  elemento: '',
                ));

      case '/nuevoproveedores':
        return MaterialPageRoute(
          builder: (_) => NuevoProveedores(),
          fullscreenDialog: true,
        );

      case '/editarproveedores':
        final proveedores = settings.arguments as Proveedores;
        return MaterialPageRoute(
            builder: (_) => EditarProveedores(proveedores: proveedores),
            fullscreenDialog: true);

      default:
        return MaterialPageRoute(builder: (_) => const ErrorPage());
    }
  }
}
