import 'package:flutter/material.dart';

class ErrorPage extends StatelessWidget {
  const ErrorPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '¡Oops!',
              style: TextStyle(fontSize: 48, color: Colors.red),
            ),
            const Text(
              'Lo siento, la página que buscas no se encuentra aquí.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                textStyle: const TextStyle(fontSize: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('Volver atrás'),
            ),
            const SizedBox(height: 20),
            Image.asset(
              'assets/404-error.jpg',
              width: MediaQuery.of(context).size.width * 0.8,
            ),
          ],
        ),
      ),
    );
  }
}
