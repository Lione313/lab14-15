import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product_model.dart';

abstract class BaseDatabaseService {
  Future<void> insertProducto(ProductModel producto);
  Future<List<ProductModel>> getProductos();
  Future<void> deleteProducto(String id);
  Future<void> updateProducto(ProductModel producto);
}

class DatabaseService extends BaseDatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  final String _key = 'productos_list';

  Future<SharedPreferences> get _prefs async => await SharedPreferences.getInstance();

  @override
  Future<void> insertProducto(ProductModel producto) async {
    final prefs = await _prefs;
    final productos = await getProductos();
    productos.removeWhere((p) => p.id == producto.id); // evita duplicados
    productos.add(producto);
    await prefs.setString(_key, jsonEncode(productos.map((e) => e.toJson()).toList()));
  }

  @override
  Future<List<ProductModel>> getProductos() async {
    final prefs = await _prefs;
    final data = prefs.getString(_key);
    if (data == null) return [];
    final decoded = jsonDecode(data) as List<dynamic>;
    return decoded.map((e) => ProductModel.fromJson(e)).toList();
  }

  @override
  Future<void> deleteProducto(String id) async {
    final prefs = await _prefs;
    final productos = await getProductos();
    productos.removeWhere((p) => p.id == id);
    await prefs.setString(_key, jsonEncode(productos.map((e) => e.toJson()).toList()));
  }

  @override
  Future<void> updateProducto(ProductModel producto) async {
    final prefs = await _prefs;
    final productos = await getProductos();
    final index = productos.indexWhere((p) => p.id == producto.id);
    if (index != -1) {
      productos[index] = producto;
      await prefs.setString(_key, jsonEncode(productos.map((e) => e.toJson()).toList()));
    }
  }
}
