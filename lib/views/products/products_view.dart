import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/products_view_model.dart';
import 'add_product_view.dart';

class ProductsView extends StatefulWidget {
  const ProductsView({super.key});

  @override
  State<ProductsView> createState() => _ProductsViewState();
}

class _ProductsViewState extends State<ProductsView> {
  @override
  void initState() {
    super.initState();
    // Carga los productos solo una vez
    Future.microtask(() =>
        Provider.of<ProductsViewModel>(context, listen: false)
            .fetchProductos());
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ProductsViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : viewModel.productos.isEmpty
              ? const Center(child: Text('No hay productos aún.'))
              : ListView.builder(
                  itemCount: viewModel.productos.length,
                  itemBuilder: (context, index) {
                    final producto = viewModel.productos[index];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        leading: producto.backgroundImg.isNotEmpty
                            ? ClipRRect(
  borderRadius: BorderRadius.circular(8),
  child: Image.network(
    producto.backgroundImg,
    width: 50,
    height: 50,
    fit: BoxFit.cover,
    loadingBuilder: (context, child, loadingProgress) {
      if (loadingProgress == null) return child;
      return const SizedBox(
        width: 50,
        height: 50,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    },
    errorBuilder: (context, error, stackTrace) {
      print('❌ Error al cargar imagen: $error');
      return const Icon(Icons.broken_image, size: 50);
    },
  ),
)

                            : const Icon(Icons.image_not_supported),
                        title: Text(producto.nombre),
                        subtitle: Text(
                            'S/ ${producto.precio.toStringAsFixed(2)}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            viewModel.deleteProducto(producto.id);
                          },
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddProductView()),
          );
          // Al volver, recargar productos
          Provider.of<ProductsViewModel>(context, listen: false)
              .fetchProductos();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
