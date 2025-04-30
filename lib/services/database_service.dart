import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/product.dart';
import '../models/invoice.dart';
import '../models/invoice_item.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'gst_billing.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE products (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        price REAL NOT NULL,
        gstRate REAL NOT NULL,
        description TEXT,
        category TEXT,
        unit TEXT,
        barcode TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE invoices (
        id TEXT PRIMARY KEY,
        customerName TEXT NOT NULL,
        customerPhone TEXT,
        customerAddress TEXT,
        customerGstin TEXT,
        date TEXT NOT NULL,
        discount REAL NOT NULL DEFAULT 0,
        notes TEXT,
        invoiceNumber TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE invoice_items (
        id TEXT PRIMARY KEY,
        invoiceId TEXT NOT NULL,
        productId TEXT NOT NULL,
        productName TEXT NOT NULL,
        price REAL NOT NULL,
        gstRate REAL NOT NULL,
        quantity INTEGER NOT NULL,
        productDescription TEXT,
        unit TEXT,
        FOREIGN KEY (invoiceId) REFERENCES invoices (id) ON DELETE CASCADE
      )
    ''');
  }

  // Product operations
  Future<List<Product>> getProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('products');
    return List.generate(maps.length, (i) => Product.fromMap(maps[i]));
  }

  Future<Product> getProduct(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
    return Product.fromMap(maps.first);
  }

  Future<void> insertProduct(Product product) async {
    final db = await database;
    await db.insert(
      'products',
      product.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateProduct(Product product) async {
    final db = await database;
    await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<void> deleteProduct(String id) async {
    final db = await database;
    await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Invoice operations
  Future<List<Invoice>> getInvoices() async {
    final db = await database;
    final List<Map<String, dynamic>> invoiceMaps = await db.query('invoices');
    
    List<Invoice> invoices = [];
    for (var invoiceMap in invoiceMaps) {
      List<Map<String, dynamic>> itemMaps = await db.query(
        'invoice_items',
        where: 'invoiceId = ?',
        whereArgs: [invoiceMap['id']],
      );
      
      List<InvoiceItem> items = itemMaps.map((item) => InvoiceItem.fromMap(item)).toList();
      
      invoiceMap['items'] = items;
      invoices.add(Invoice.fromMap(invoiceMap));
    }
    
    return invoices;
  }

  Future<Invoice> getInvoice(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> invoiceMaps = await db.query(
      'invoices',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (invoiceMaps.isEmpty) {
      throw Exception('Invoice not found');
    }
    
    Map<String, dynamic> invoiceMap = invoiceMaps.first;
    
    List<Map<String, dynamic>> itemMaps = await db.query(
      'invoice_items',
      where: 'invoiceId = ?',
      whereArgs: [id],
    );
    
    List<InvoiceItem> items = itemMaps.map((item) => InvoiceItem.fromMap(item)).toList();
    
    invoiceMap['items'] = items;
    return Invoice.fromMap(invoiceMap);
  }

  Future<void> insertInvoice(Invoice invoice) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.insert(
        'invoices',
        {
          'id': invoice.id,
          'customerName': invoice.customerName,
          'customerPhone': invoice.customerPhone,
          'customerAddress': invoice.customerAddress,
          'customerGstin': invoice.customerGstin,
          'date': invoice.date.toIso8601String(),
          'discount': invoice.discount,
          'notes': invoice.notes,
          'invoiceNumber': invoice.invoiceNumber,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      
      for (var item in invoice.items) {
        await txn.insert(
          'invoice_items',
          {
            'id': item.id,
            'invoiceId': invoice.id,
            'productId': item.productId,
            'productName': item.productName,
            'price': item.price,
            'gstRate': item.gstRate,
            'quantity': item.quantity,
            'productDescription': item.productDescription,
            'unit': item.unit,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<void> deleteInvoice(String id) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete(
        'invoice_items',
        where: 'invoiceId = ?',
        whereArgs: [id],
      );
      
      await txn.delete(
        'invoices',
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }
} 