import 'package:uuid/uuid.dart';

class Product {
  final String id;
  final String name;
  final double price;
  final double gstRate;
  final String? description;
  final String? category;
  final String? unit;
  final String? barcode;

  Product({
    String? id,
    required this.name,
    required this.price,
    required this.gstRate,
    this.description,
    this.category,
    this.unit,
    this.barcode,
  }) : id = id ?? const Uuid().v4();

  double get cgst => (price * gstRate / 100) / 2;
  double get sgst => (price * gstRate / 100) / 2;
  double get totalGst => cgst + sgst;
  double get totalPrice => price + totalGst;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'gstRate': gstRate,
      'description': description,
      'category': category,
      'unit': unit,
      'barcode': barcode,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      price: map['price'],
      gstRate: map['gstRate'],
      description: map['description'],
      category: map['category'],
      unit: map['unit'],
      barcode: map['barcode'],
    );
  }

  Product copyWith({
    String? id,
    String? name,
    double? price,
    double? gstRate,
    String? description,
    String? category,
    String? unit,
    String? barcode,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      gstRate: gstRate ?? this.gstRate,
      description: description ?? this.description,
      category: category ?? this.category,
      unit: unit ?? this.unit,
      barcode: barcode ?? this.barcode,
    );
  }
} 