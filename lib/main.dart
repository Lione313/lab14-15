import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/products_view_model.dart';
import 'views/products/products_view.dart';
import 'views/products/product_detail_view.dart';
import 'views/products/edit_product_view.dart';
import 'views/products/add_product_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductsViewModel()),
      ],
      child: MaterialApp(
        title: 'Productos App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/': (_) => const ProductsView(),
          '/add': (_) => const AddProductView(),
          // Nota: las rutas que requieren parámetros como ID deben navegar con MaterialPageRoute (no se registran aquí).
        },
      ),
    );
  }
}
