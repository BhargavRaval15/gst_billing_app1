import 'package:uuid/uuid.dart';
import 'product.dart';

class InvoiceItem {
  final String id;
  final String productId;
  final String productName;
  final double price;
  final double gstRate;
  final int quantity;
  final String? productDescription;
  final String? unit;

  InvoiceItem({
    String? id,
    required this.productId,
    required this.productName,
    required this.price,
    required this.gstRate,
    required this.quantity,
    this.productDescription,
    this.unit,
  }) : id = id ?? const Uuid().v4();

  factory InvoiceItem.fromProduct(Product product, int quantity) {
    return InvoiceItem(
      productId: product.id,
      productName: product.name,
      price: product.price,
      gstRate: product.gstRate,
      quantity: quantity,
      productDescription: product.description,
      unit: product.unit,
    );
  }

  double get totalBeforeGst => price * quantity;
  
  double get cgst => (price * gstRate / 100) / 2 * quantity;
  
  double get sgst => (price * gstRate / 100) / 2 * quantity;
  
  double get totalGst => cgst + sgst;
  
  double get total => totalBeforeGst + totalGst;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'price': price,
      'gstRate': gstRate,
      'quantity': quantity,
      'productDescription': productDescription,
      'unit': unit,
    };
  }

  factory InvoiceItem.fromMap(Map<String, dynamic> map) {
    return InvoiceItem(
      id: map['id'],
      productId: map['productId'],
      productName: map['productName'],
      price: map['price'],
      gstRate: map['gstRate'],
      quantity: map['quantity'],
      productDescription: map['productDescription'],
      unit: map['unit'],
    );
  }
} 