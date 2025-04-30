import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/invoice.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/invoice_provider.dart';
import 'invoice_detail_screen.dart';

class NewInvoiceScreen extends StatefulWidget {
  const NewInvoiceScreen({super.key});

  @override
  State<NewInvoiceScreen> createState() => _NewInvoiceScreenState();
}

class _NewInvoiceScreenState extends State<NewInvoiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _customerAddressController = TextEditingController();
  final _customerGstinController = TextEditingController();
  final _discountController = TextEditingController(text: '0');
  final _notesController = TextEditingController();
  
  String _searchQuery = '';
  bool _isCreatingInvoice = false;
  
  @override
  void dispose() {
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _customerAddressController.dispose();
    _customerGstinController.dispose();
    _discountController.dispose();
    _notesController.dispose();
    super.dispose();
  }
  
  void _addProductToCart(Product product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add ${product.name}'),
        content: TextField(
          decoration: const InputDecoration(
            labelText: 'Quantity',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          controller: TextEditingController(text: '1'),
          autofocus: true,
          onSubmitted: (value) {
            if (int.tryParse(value) != null && int.parse(value) > 0) {
              Provider.of<CartProvider>(context, listen: false)
                  .addItem(product, int.parse(value));
              Navigator.of(ctx).pop();
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final value = (TextEditingController().text);
              
              if (value.isNotEmpty && int.tryParse(value) != null && int.parse(value) > 0) {
                Provider.of<CartProvider>(context, listen: false)
                    .addItem(product, int.parse(value));
              } else {
                // Default to 1 if there's an issue with the input
                Provider.of<CartProvider>(context, listen: false)
                    .addItem(product, 1);
              }
              Navigator.of(ctx).pop();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _createInvoice() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    
    if (cartProvider.itemCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add items to the invoice'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() {
      _isCreatingInvoice = true;
    });
    
    try {
      final invoice = Invoice(
        customerName: _customerNameController.text.trim(),
        customerPhone: _customerPhoneController.text.isEmpty
            ? null
            : _customerPhoneController.text.trim(),
        customerAddress: _customerAddressController.text.isEmpty
            ? null
            : _customerAddressController.text.trim(),
        customerGstin: _customerGstinController.text.isEmpty
            ? null
            : _customerGstinController.text.trim(),
        items: cartProvider.itemsList,
        discount: _discountController.text.isEmpty
            ? 0
            : double.parse(_discountController.text),
        notes: _notesController.text.isEmpty
            ? null
            : _notesController.text.trim(),
      );
      
      await Provider.of<InvoiceProvider>(context, listen: false)
          .addInvoice(invoice);
      
      cartProvider.clear();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invoice created successfully'),
            backgroundColor: Colors.green,
          ),
        );
        
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (ctx) => InvoiceDetailScreen(invoice: invoice),
          ),
        );
        
        // Clear form fields after creating invoice
        _customerNameController.clear();
        _customerPhoneController.clear();
        _customerAddressController.clear();
        _customerGstinController.clear();
        _discountController.text = '0';
        _notesController.clear();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating invoice: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCreatingInvoice = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Invoice'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isCreatingInvoice ? null : _createInvoice,
          ),
        ],
      ),
      body: _isCreatingInvoice
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _customerNameController,
                            decoration: const InputDecoration(
                              labelText: 'Customer Name',
                              border: OutlineInputBorder(),
                            ),
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter customer name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _customerPhoneController,
                            decoration: const InputDecoration(
                              labelText: 'Customer Phone (Optional)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _customerAddressController,
                            decoration: const InputDecoration(
                              labelText: 'Customer Address (Optional)',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 2,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _customerGstinController,
                            decoration: const InputDecoration(
                              labelText: 'Customer GSTIN (Optional)',
                              border: OutlineInputBorder(),
                            ),
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _discountController,
                            decoration: const InputDecoration(
                              labelText: 'Discount Amount (₹)',
                              prefixText: '₹ ',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                if (double.tryParse(value) == null) {
                                  return 'Please enter a valid number';
                                }
                                if (double.parse(value) < 0) {
                                  return 'Discount cannot be negative';
                                }
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _notesController,
                            decoration: const InputDecoration(
                              labelText: 'Notes (Optional)',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 3,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Invoice Items',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Consumer<CartProvider>(
                      builder: (ctx, cart, _) {
                        return Card(
                          margin: EdgeInsets.zero,
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (cart.itemCount == 0)
                                  const Padding(
                                    padding: EdgeInsets.all(10),
                                    child: Text('No items added yet'),
                                  )
                                else
                                  ListView.separated(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: cart.items.length,
                                    separatorBuilder: (_, __) => const Divider(),
                                    itemBuilder: (ctx, i) {
                                      final item = cart.items.values.toList()[i];
                                      return ListTile(
                                        title: Text(item.productName),
                                        subtitle: Text(
                                          'Price: ₹${item.price.toStringAsFixed(2)} | GST: ${item.gstRate}% | Qty: ${item.quantity}',
                                        ),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              '₹${item.total.toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete),
                                              color: Colors.red,
                                              onPressed: () {
                                                cart.removeItem(item.productId);
                                              },
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                const Divider(),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text('Subtotal:'),
                                          Text('₹${cart.subtotal.toStringAsFixed(2)}'),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text('CGST:'),
                                          Text('₹${cart.totalCgst.toStringAsFixed(2)}'),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text('SGST:'),
                                          Text('₹${cart.totalSgst.toStringAsFixed(2)}'),
                                        ],
                                      ),
                                      if (_discountController.text.isNotEmpty &&
                                          double.tryParse(_discountController.text) != null &&
                                          double.parse(_discountController.text) > 0)
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text('Discount:'),
                                            Text('- ₹${double.parse(_discountController.text).toStringAsFixed(2)}'),
                                          ],
                                        ),
                                      const Divider(),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Total:',
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            '₹${(cart.totalAmount - (_discountController.text.isEmpty ? 0 : double.parse(_discountController.text))).toStringAsFixed(2)}',
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Add Products',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Search Products',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    Consumer<ProductProvider>(
                      builder: (ctx, productProvider, _) {
                        final products = productProvider.searchProducts(_searchQuery);
                        
                        if (products.isEmpty) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Text('No products found'),
                            ),
                          );
                        }
                        
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: products.length,
                          itemBuilder: (ctx, i) => Card(
                            child: ListTile(
                              title: Text(products[i].name),
                              subtitle: Text(
                                'Price: ₹${products[i].price.toStringAsFixed(2)} | GST: ${products[i].gstRate}%',
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                color: Theme.of(context).primaryColor,
                                onPressed: () => _addProductToCart(products[i]),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
      floatingActionButton: Consumer<CartProvider>(
        builder: (ctx, cart, _) {
          if (cart.itemCount > 0) {
            return FloatingActionButton.extended(
              onPressed: _createInvoice,
              label: const Text('Create Invoice'),
              icon: const Icon(Icons.receipt),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
} 