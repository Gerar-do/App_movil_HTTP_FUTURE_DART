import 'dart:convert'; // Para decodificar y codificar JSON
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List products = [];
  final String apiUrl = 'http://192.168.1.64:5000/api/productos'; // Reemplaza con la IP si es necesario

  @override
  void initState() {
    super.initState();
    _fetchProducts(); // Carga los productos al iniciar
  }

  Future<void> _fetchProducts() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        setState(() {
          products = json.decode(response.body);
        });
      } else {
        throw Exception('Error al cargar los productos');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _addProduct({
    required String nombre,
    required double precio,
    required bool enStock,
    required String descripcion,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode(<String, dynamic>{
          'nombre': nombre,
          'precio': precio,
          'enStock': enStock,
          'descripcion': descripcion,
        }),
      );

      if (response.statusCode == 201) {
        _fetchProducts(); // Vuelve a cargar los productos después de agregar uno nuevo
      } else {
        throw Exception('Error al agregar el producto');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _showAddProductDialog() {
    final TextEditingController nombreController = TextEditingController();
    final TextEditingController precioController = TextEditingController();
    final TextEditingController descripcionController = TextEditingController();
    bool enStock = true;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Agregar Producto'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                controller: precioController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Precio'),
              ),
              TextField(
                controller: descripcionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
              ),
              Row(
                children: [
                  const Text('En Stock'),
                  Checkbox(
                    value: enStock,
                    onChanged: (bool? value) {
                      setState(() {
                        enStock = value ?? true;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                if (nombreController.text.isNotEmpty &&
                    precioController.text.isNotEmpty &&
                    descripcionController.text.isNotEmpty) {
                  _addProduct(
                    nombre: nombreController.text,
                    precio: double.parse(precioController.text),
                    enStock: enStock,
                    descripcion: descripcionController.text,
                  ).then((_) {
                    Navigator.of(context).pop();
                  });
                } else {
                  // Aquí puedes manejar el caso en que algún campo esté vacío.
                  print('Por favor complete todos los campos');
                }
              },
              child: const Text('Agregar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home productos'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Productos Disponibles',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _showAddProductDialog,
              child: const Text('Agregar Producto'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: products.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Text(products[index]['nombre']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Precio: \$${products[index]['precio']}'),
                          const SizedBox(height: 4),
                          Text('Descripción: ${products[index]['descripcion']}'),
                        ],
                      ),
                      trailing: Icon(
                        products[index]['enStock']
                            ? Icons.check_circle
                            : Icons.cancel,
                        color: products[index]['enStock']
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
