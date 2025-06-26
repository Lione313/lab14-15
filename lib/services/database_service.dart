import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/product_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'productos.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE productos(
        id TEXT PRIMARY KEY,
        nombre TEXT,
        descripcion TEXT,
        fechaVencimiento TEXT,
        precio REAL,
        backgroundImg TEXT
      )
    ''');
  }

  Future<void> insertProducto(ProductModel producto) async {
    final db = await database;
    await db.insert('productos', producto.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<ProductModel>> getProductos() async {
    final db = await database;
    final res = await db.query('productos');
    return res.map((e) => ProductModel.fromJson(e)).toList();
  }

  Future<void> deleteProducto(String id) async {
    final db = await database;
    await db.delete('productos', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateProducto(ProductModel producto) async {
    final db = await database;
    await db.update('productos', producto.toJson(),
        where: 'id = ?', whereArgs: [producto.id]);
  }
}
