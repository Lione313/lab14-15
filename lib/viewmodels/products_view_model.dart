import 'dart:io';
import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/database_service.dart';
import '../services/cloudinary_service.dart';
import 'package:uuid/uuid.dart';

class ProductsViewModel extends ChangeNotifier {
  final _dbService = DatabaseService();
  final _cloudService = CloudinaryService();

  List<ProductModel> _productos = [];
  List<ProductModel> get productos => _productos;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Cargar productos desde la base de datos
  Future<void> fetchProductos() async {
    _isLoading = true;
    notifyListeners();

    _productos = await _dbService.getProductos();

    _isLoading = false;
    notifyListeners();
  }

  // Agregar un producto nuevo
  Future<void> addProducto({
    required String nombre,
    required String descripcion,
    required DateTime fechaVencimiento,
    required double precio,
    required File? imageFile,
  }) async {
    _isLoading = true;
    notifyListeners();

    String imageUrl = '';

    // Subir imagen si existe
    if (imageFile != null) {
      final uploadedUrl = await _cloudService.uploadImage(imageFile);
      if (uploadedUrl != null) {
        imageUrl = uploadedUrl;
      }
    }

    final newProduct = ProductModel(
      id: const Uuid().v4(), // genera ID único
      nombre: nombre,
      descripcion: descripcion,
      fechaVencimiento: fechaVencimiento,
      precio: precio,
      backgroundImg: imageUrl,
    );

    await _dbService.insertProducto(newProduct);
    _productos.add(newProduct);

    _isLoading = false;
    notifyListeners();
  }

  // Eliminar producto
  Future<void> deleteProducto(String id) async {
    await _dbService.deleteProducto(id);
    _productos.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  // Editar producto (opcional si haces pantalla de editar)
  Future<void> updateProducto(ProductModel producto) async {
    await _dbService.updateProducto(producto);
    int index = _productos.indexWhere((p) => p.id == producto.id);
    if (index != -1) {
      _productos[index] = producto;
      notifyListeners();
    }
  }
}
