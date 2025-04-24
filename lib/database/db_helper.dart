import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/product.dart';
import '../models/sale.dart';
import '../models/sale_item.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('stock_scan.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onConfigure: (db) async => await db.execute('PRAGMA foreign_keys = ON'),
    );
  }

  Future _createDB(Database db, int version) async {
    // Tabela de Produtos
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        description TEXT NOT NULL,
        barcode TEXT NOT NULL UNIQUE,
        purchasePrice REAL NOT NULL,
        salePrice REAL NOT NULL,
        quantity INTEGER NOT NULL,
        lastPurchase TEXT NOT NULL,
        lastSale TEXT NOT NULL
      )
    ''');

    // Tabela de Vendas
    await db.execute('''
      CREATE TABLE sales (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sellerName TEXT NOT NULL,
        companyName TEXT NOT NULL,
        cnpj TEXT NOT NULL,
        saleDate TEXT NOT NULL,
        totalAmount REAL NOT NULL
      )
    ''');

    // Tabela de Itens de Venda
    await db.execute('''
      CREATE TABLE sale_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        saleId INTEGER NOT NULL,
        productId INTEGER NOT NULL,
        description TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        unitPrice REAL NOT NULL,
        totalPrice REAL NOT NULL,
        FOREIGN KEY (saleId) REFERENCES sales (id) ON DELETE CASCADE,
        FOREIGN KEY (productId) REFERENCES products (id)
      )
    ''');
  }

  // ========== CRUD Produtos ==========
  Future<int> insertProduct(Product product) async {
  final db = await instance.database;
  
  // Verifica se o código de barras foi fornecido
  if (product.barcode.isEmpty) {
    throw Exception('O código de barras não pode estar vazio');
  }

  // Verifica se já existe
  final existing = await db.query(
    'products',
    where: 'barcode = ?',
    whereArgs: [product.barcode],
    limit: 1,
  );

  if (existing.isNotEmpty) {
    throw Exception('Já existe um produto com este código de barras');
  }

  return await db.insert('products', product.toMap());
}

  Future<int> updateProductQuantity(int productId, int quantityChange) async {
  final db = await instance.database;
  return await db.rawUpdate(
    'UPDATE products SET quantity = quantity + ? WHERE id = ?',
    [quantityChange, productId],
  );
}

  Future<List<Product>> getAllProducts() async {
    final db = await instance.database;
    final result = await db.query('products');
    return result.map((json) => Product.fromMap(json)).toList();
  }

  Future<Product?> getProductByBarcode(String barcode) async {
    final db = await instance.database;
    final result = await db.query(
      'products',
      where: 'barcode = ?',
      whereArgs: [barcode],
      limit: 1,
    );
    return result.isNotEmpty ? Product.fromMap(result.first) : null;
  }

  Future<int> updateProduct(Product product) async {
    final db = await instance.database;
    return await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<int> deleteProduct(int id) async {
    final db = await instance.database;
    return await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ========== CRUD Vendas ==========
  Future<int> insertSale(Sale sale) async {
    final db = await instance.database;
    return await db.insert('sales', sale.toMap());
  }

  Future<int> insertSaleItem(SaleItem item) async {
    final db = await instance.database;
    return await db.insert('sale_items', item.toMap());
  }

  Future<List<Sale>> getAllSales() async {
    final db = await instance.database;
    final result = await db.query('sales', orderBy: 'saleDate DESC');
    return result.map((json) => Sale.fromMap(json)).toList();
  }

  Future<List<SaleItem>> getSaleItems(int saleId) async {
    final db = await instance.database;
    final result = await db.query(
      'sale_items',
      where: 'saleId = ?',
      whereArgs: [saleId],
    );
    return result.map((json) => SaleItem.fromMap(json)).toList();
  }

  

  // ========== Métodos Transacionais ==========
  Future<void> executeSaleWithItems(Sale sale, List<SaleItem> items) async {
    final db = await instance.database;
    await db.transaction((txn) async {
      final saleId = await txn.insert('sales', sale.toMap());
      
      for (var item in items) {
        await txn.insert('sale_items', SaleItem(
          saleId: saleId,
          productId: item.productId,
          description: item.description,
          quantity: item.quantity,
          unitPrice: item.unitPrice,
          totalPrice: item.totalPrice,
        ).toMap());

        // Atualiza estoque
        await txn.rawUpdate(
          'UPDATE products SET quantity = quantity - ?, lastSale = ? WHERE id = ?',
          [item.quantity, DateTime.now().toIso8601String(), item.productId],
        );
      }
    });
  }

  Future close() async {
    final db = await instance.database;
    _database = null;
    return db.close();
  }
}