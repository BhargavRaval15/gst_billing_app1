import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../models/invoice_item.dart';

class CartProvider with ChangeNotifier {
  Map<String, InvoiceItem> _items = {};
  
  Map<String, InvoiceItem> get items => {..._items};
  
  int get itemCount => _items.length;
  
  double get totalAmount {
    double total = 0.0;
    _items.forEach((key, item) {
      total += item.total;
    });
    return total;
  }
  
  double get subtotal {
    double total = 0.0;
    _items.forEach((key, item) {
      total += item.totalBeforeGst;
    });
    return total;
  }
  
  double get totalCgst {
    double total = 0.0;
    _items.forEach((key, item) {
      total += item.cgst;
    });
    return total;
  }
  
  double get totalSgst {
    double total = 0.0;
    _items.forEach((key, item) {
      total += item.sgst;
    });
    return total;
  }
  
  void addItem(Product product, int quantity) {
    if (_items.containsKey(product.id)) {
      _items.update(
        product.id,
        (existingItem) => InvoiceItem(
          id: existingItem.id,
          productId: product.id,
          productName: product.name,
          price: product.price,
          gstRate: product.gstRate,
          quantity: existingItem.quantity + quantity,
          productDescription: product.description,
          unit: product.unit,
        ),
      );
    } else {
      _items.putIfAbsent(
        product.id,
        () => InvoiceItem.fromProduct(product, quantity),
      );
    }
    notifyListeners();
  }
  
  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }
  
  void updateQuantity(String productId, int quantity) {
    if (!_items.containsKey(productId) || quantity <= 0) return;
    
    _items.update(
      productId,
      (existingItem) => InvoiceItem(
        id: existingItem.id,
        productId: existingItem.productId,
        productName: existingItem.productName,
        price: existingItem.price,
        gstRate: existingItem.gstRate,
        quantity: quantity,
        productDescription: existingItem.productDescription,
        unit: existingItem.unit,
      ),
    );
    
    notifyListeners();
  }
  
  void clear() {
    _items = {};
    notifyListeners();
  }
  
  List<InvoiceItem> get itemsList => _items.values.toList();
} 