import 'package:flutter/foundation.dart';
import '../models/invoice.dart';
import '../models/invoice_item.dart';
import '../services/database_service.dart';

class InvoiceProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
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
      _invoices = await _databaseService.getInvoices();
    } catch (e) {
      print('Error loading invoices: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addInvoice(Invoice invoice) async {
    try {
      await _databaseService.insertInvoice(invoice);
      _invoices.add(invoice);
      notifyListeners();
    } catch (e) {
      print('Error adding invoice: $e');
      rethrow;
    }
  }

  Future<void> deleteInvoice(String id) async {
    try {
      await _databaseService.deleteInvoice(id);
      _invoices.removeWhere((invoice) => invoice.id == id);
      notifyListeners();
    } catch (e) {
      print('Error deleting invoice: $e');
      rethrow;
    }
  }
  
  Future<Invoice> getInvoiceById(String id) async {
    try {
      return await _databaseService.getInvoice(id);
    } catch (e) {
      rethrow;
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