import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
import '../models/invoice.dart';
import '../models/invoice_item.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Collections
  final CollectionReference _productsCollection = 
      FirebaseFirestore.instance.collection('products');
  
  final CollectionReference _invoicesCollection = 
      FirebaseFirestore.instance.collection('invoices');
  
  // Product Operations
  Future<List<Product>> getProducts() async {
    final snapshot = await _productsCollection.get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Product.fromMap({
        'id': doc.id,
        ...data,
      });
    }).toList();
  }
  
  Future<Product> getProduct(String id) async {
    final doc = await _productsCollection.doc(id).get();
    final data = doc.data() as Map<String, dynamic>;
    return Product.fromMap({
      'id': doc.id,
      ...data,
    });
  }
  
  Future<void> addProduct(Product product) async {
    await _productsCollection.doc(product.id).set({
      'name': product.name,
      'price': product.price,
      'gstRate': product.gstRate,
      'description': product.description,
      'category': product.category,
      'unit': product.unit,
      'barcode': product.barcode,
    });
  }
  
  Future<void> updateProduct(Product product) async {
    await _productsCollection.doc(product.id).update({
      'name': product.name,
      'price': product.price,
      'gstRate': product.gstRate,
      'description': product.description,
      'category': product.category,
      'unit': product.unit,
      'barcode': product.barcode,
    });
  }
  
  Future<void> deleteProduct(String id) async {
    await _productsCollection.doc(id).delete();
  }
  
  // Invoice Operations
  Future<List<Invoice>> getInvoices() async {
    final snapshot = await _invoicesCollection.orderBy('date', descending: true).get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      
      // Convert Timestamp to DateTime
      final date = (data['date'] as Timestamp).toDate();
      
      // Convert items from list of maps to list of InvoiceItem
      final itemsList = (data['items'] as List).map((item) {
        return InvoiceItem.fromMap(Map<String, dynamic>.from(item));
      }).toList();
      
      return Invoice(
        id: doc.id,
        invoiceNumber: data['invoiceNumber'],
        date: date,
        customerName: data['customerName'],
        customerPhone: data['customerPhone'],
        customerAddress: data['customerAddress'],
        customerGstin: data['customerGstin'],
        items: itemsList,
        discount: data['discount'],
        notes: data['notes'],
      );
    }).toList();
  }
  
  Future<void> addInvoice(Invoice invoice) async {
    // Convert items to list of maps
    final itemsList = invoice.items.map((item) => item.toMap()).toList();
    
    await _invoicesCollection.doc(invoice.id).set({
      'invoiceNumber': invoice.invoiceNumber,
      'date': Timestamp.fromDate(invoice.date),
      'customerName': invoice.customerName,
      'customerPhone': invoice.customerPhone,
      'customerAddress': invoice.customerAddress,
      'customerGstin': invoice.customerGstin,
      'items': itemsList,
      'discount': invoice.discount,
      'notes': invoice.notes,
    });
  }
  
  Future<void> deleteInvoice(String id) async {
    await _invoicesCollection.doc(id).delete();
  }
} 