import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/invoice_provider.dart';
import '../models/invoice.dart';
import 'invoice_detail_screen.dart';

class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({super.key});

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
  String _searchQuery = '';
  bool _isInit = true;
  DateTime? _startDate;
  DateTime? _endDate;
  
  final dateFormat = DateFormat('dd-MM-yyyy');

  @override
  void didChangeDependencies() {
    if (_isInit) {
      Provider.of<InvoiceProvider>(context, listen: false).loadInvoices();
      _isInit = false;
    }
    super.didChangeDependencies();
  }

  void _viewInvoice(Invoice invoice) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => InvoiceDetailScreen(invoice: invoice),
      ),
    );
  }

  void _showDeleteConfirmation(Invoice invoice) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Invoice'),
        content: Text('Are you sure you want to delete invoice #${invoice.invoiceNumber}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<InvoiceProvider>(context, listen: false)
                  .deleteInvoice(invoice.id);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Invoice #${invoice.invoiceNumber} deleted'),
                ),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );
    
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _startDate = null;
      _endDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoices'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: _selectDateRange,
          ),
          if (_startDate != null && _endDate != null)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clearFilters,
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search Invoices',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          if (_startDate != null && _endDate != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  const Text('Date Range: '),
                  Text('${dateFormat.format(_startDate!)} - ${dateFormat.format(_endDate!)}'),
                ],
              ),
            ),
          Expanded(
            child: Consumer<InvoiceProvider>(
              builder: (ctx, invoiceProvider, _) {
                if (invoiceProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                List<Invoice> filteredInvoices = invoiceProvider.searchInvoices(_searchQuery);
                
                if (_startDate != null && _endDate != null) {
                  filteredInvoices = invoiceProvider.filterInvoicesByDate(
                    _startDate!,
                    _endDate!,
                  );
                  
                  if (_searchQuery.isNotEmpty) {
                    final lowercaseQuery = _searchQuery.toLowerCase();
                    filteredInvoices = filteredInvoices.where((invoice) {
                      final customerName = invoice.customerName.toLowerCase();
                      final invoiceNumber = invoice.invoiceNumber.toLowerCase();
                      
                      return customerName.contains(lowercaseQuery) || 
                             invoiceNumber.contains(lowercaseQuery);
                    }).toList();
                  }
                }
                
                if (filteredInvoices.isEmpty) {
                  return const Center(
                    child: Text('No invoices found.'),
                  );
                }
                
                return ListView.builder(
                  itemCount: filteredInvoices.length,
                  itemBuilder: (ctx, i) => Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 5,
                    ),
                    child: ListTile(
                      title: Text(
                        'Invoice #${filteredInvoices[i].invoiceNumber}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Customer: ${filteredInvoices[i].customerName}'),
                          Text(
                            'Date: ${dateFormat.format(filteredInvoices[i].date)}',
                          ),
                          Text(
                            'Amount: ₹${filteredInvoices[i].total.toStringAsFixed(2)}',
                          ),
                        ],
                      ),
                      isThreeLine: true,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.visibility),
                            onPressed: () => _viewInvoice(filteredInvoices[i]),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _showDeleteConfirmation(filteredInvoices[i]),
                          ),
                        ],
                      ),
                      onTap: () => _viewInvoice(filteredInvoices[i]),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 