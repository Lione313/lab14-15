import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/products_view_model.dart';
import 'edit_product_view.dart';

class ProductDetailView extends StatelessWidget {
  final String productId;

  const ProductDetailView({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Provider.of<ProductsViewModel>(context, listen: false)
          .getProductoById(productId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final producto = snapshot.data;

        if (producto == null) {
          return const Scaffold(
            body: Center(child: Text('Producto no encontrado')),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF8F8F8),
          appBar: AppBar(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            title: Text(producto.nombre),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditProductView(producto: producto),
                    ),
                  );
                  // Actualiza y regresa al listado
                  Provider.of<ProductsViewModel>(context, listen: false)
                      .fetchProductos();
                  Navigator.pop(context);
                },
              )
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: producto.backgroundImg.isNotEmpty
                        ? Image.network(
                            producto.backgroundImg,
                            height: 220,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.broken_image, size: 50),
                          )
                        : Container(
                            height: 220,
                            width: double.infinity,
                            color: Colors.grey[300],
                            child: const Icon(Icons.image_not_supported,
                                size: 50),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  producto.nombre,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'S/ ${producto.precio.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 22,
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Descripción:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  producto.descripcion,
                  style: const TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Fecha de vencimiento:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  producto.fechaVencimiento
                      .toLocal()
                      .toString()
                      .split(' ')[0],
                  style: const TextStyle(fontSize: 15),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
