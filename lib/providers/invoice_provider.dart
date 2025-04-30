import 'package:flutter/foundation.dart';
import '../models/invoice.dart';
import '../models/invoice_item.dart';
import '../services/firestore_service.dart';

class InvoiceProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<Invoice> _invoices = [];
  bool _isLoading = false;

  InvoiceProvider() {
    loadInvoices();
  }

  List<Invoice> get invoices => [..._invoices];
  bool get isLoading => _isLoading;

  Future<void> loadInvoices() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _invoices = await _firestoreService.getInvoices();
    } catch (e) {
      print('Error loading invoices: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addInvoice(Invoice invoice) async {
    try {
      await _firestoreService.addInvoice(invoice);
      _invoices.add(invoice);
      notifyListeners();
    } catch (e) {
      print('Error adding invoice: $e');
      rethrow;
    }
  }

  Future<void> deleteInvoice(String id) async {
    try {
      await _firestoreService.deleteInvoice(id);
      _invoices.removeWhere((invoice) => invoice.id == id);
      notifyListeners();
    } catch (e) {
      print('Error deleting invoice: $e');
      rethrow;
    }
  }
  
  Invoice? getInvoiceById(String id) {
    try {
      return _invoices.firstWhere((invoice) => invoice.id == id);
    } catch (e) {
      return null;
    }
  }
  
  List<Invoice> searchInvoices(String query) {
    if (query.isEmpty) {
      return invoices;
    }
    
    final lowercaseQuery = query.toLowerCase();
    return _invoices.where((invoice) {
      final customerName = invoice.customerName.toLowerCase();
      final invoiceNumber = invoice.invoiceNumber.toLowerCase();
      
      return customerName.contains(lowercaseQuery) || 
             invoiceNumber.contains(lowercaseQuery);
    }).toList();
  }
  
  List<Invoice> filterInvoicesByDate(DateTime start, DateTime end) {
    return _invoices.where((invoice) {
      return invoice.date.isAfter(start.subtract(const Duration(days: 1))) && 
             invoice.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }
} 