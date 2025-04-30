import 'package:uuid/uuid.dart';
import 'invoice_item.dart';

class Invoice {
  final String id;
  final String customerName;
  final String? customerPhone;
  final String? customerAddress;
  final String? customerGstin;
  final DateTime date;
  final List<InvoiceItem> items;
  final double discount;
  final String? notes;
  final String invoiceNumber;

  Invoice({
    String? id,
    required this.customerName,
    this.customerPhone,
    this.customerAddress,
    this.customerGstin,
    DateTime? date,
    required this.items,
    this.discount = 0,
    this.notes,
    String? invoiceNumber,
  })  : id = id ?? const Uuid().v4(),
        date = date ?? DateTime.now(),
        invoiceNumber = invoiceNumber ?? DateTime.now().millisecondsSinceEpoch.toString();

  double get subtotal => items.fold(0, (sum, item) => sum + item.totalBeforeGst);
  
  double get totalCgst => items.fold(0, (sum, item) => sum + item.cgst);
  
  double get totalSgst => items.fold(0, (sum, item) => sum + item.sgst);
  
  double get totalGst => totalCgst + totalSgst;
  
  double get total => subtotal + totalGst - discount;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'customerAddress': customerAddress,
      'customerGstin': customerGstin,
      'date': date.toIso8601String(),
      'items': items.map((item) => item.toMap()).toList(),
      'discount': discount,
      'notes': notes,
      'invoiceNumber': invoiceNumber,
    };
  }

  factory Invoice.fromMap(Map<String, dynamic> map) {
    return Invoice(
      id: map['id'],
      customerName: map['customerName'],
      customerPhone: map['customerPhone'],
      customerAddress: map['customerAddress'],
      customerGstin: map['customerGstin'],
      date: DateTime.parse(map['date']),
      items: List<InvoiceItem>.from(
        map['items']?.map((item) => InvoiceItem.fromMap(item)),
      ),
      discount: map['discount'],
      notes: map['notes'],
      invoiceNumber: map['invoiceNumber'],
    );
  }
} 