import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/firestore_service.dart';

class ProductProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<Product> _products = [];
  bool _isLoading = false;

  ProductProvider() {
    loadProducts();
  }

  List<Product> get products => [..._products];
  bool get isLoading => _isLoading;
  
  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _products = await _firestoreService.getProducts();
    } catch (e) {
      print('Error loading products: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addProduct(Product product) async {
    try {
      await _firestoreService.addProduct(product);
      _products.add(product);
      notifyListeners();
    } catch (e) {
      print('Error adding product: $e');
      rethrow;
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      await _firestoreService.updateProduct(product);
      final index = _products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _products[index] = product;
        notifyListeners();
      }
    } catch (e) {
      print('Error updating product: $e');
      rethrow;
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _firestoreService.deleteProduct(id);
      _products.removeWhere((product) => product.id == id);
      notifyListeners();
    } catch (e) {
      print('Error deleting product: $e');
      rethrow;
    }
  }
  
  Product? getProductById(String id) {
    try {
      return _products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }
  
  List<Product> searchProducts(String query) {
    if (query.isEmpty) {
      return products;
    }
    
    final lowercaseQuery = query.toLowerCase();
    return _products.where((product) {
      final name = product.name.toLowerCase();
      final description = product.description?.toLowerCase() ?? '';
      final category = product.category?.toLowerCase() ?? '';
      
      return name.contains(lowercaseQuery) || 
             description.contains(lowercaseQuery) || 
             category.contains(lowercaseQuery);
    }).toList();
  }
} 