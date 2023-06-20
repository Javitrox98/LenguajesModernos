import 'package:lenguajes/home.dart';
import 'package:lenguajes/page_error.dart';
import 'package:lenguajes/pages.dart';

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

      default:
        return MaterialPageRoute(builder: (_) => const ErrorPage());
    }
  }
}
