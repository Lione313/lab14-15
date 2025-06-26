import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/products_view_model.dart';
import 'views/products/products_view.dart';

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
        home: const ProductsView(),
      ),
    );
  }
}