// lib/screens/product_form_screen.dart
import 'package:flutter/material.dart';
import '../models/product.dart'; // Ensure both Product and ProductCreate are available
import '../service/admin_service.dart'; // Import ApiService for API calls
import '../models/category.dart'; // Import Category for selection

class ProductFormScreen extends StatefulWidget {
  final Product? product;

  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockQuantityController = TextEditingController();
  final TextEditingController _deliveryInfoController = TextEditingController();
  final TextEditingController _sellerInfoController = TextEditingController();
  bool _isActive = true;
  List<Category> _availableCategories = [];
  List<int> _selectedCategoryIds = []; // To hold IDs of selected categories

  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _fetchCategories(); // Fetch categories when the form initializes
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _descriptionController.text = widget.product!.description ?? '';
      _imageUrlController.text = widget.product!.imageURL ?? '';
      _priceController.text = widget.product!.price.toString(); // Convert double to string
      _stockQuantityController.text = widget.product!.stockQuantity.toString();
      _deliveryInfoController.text = widget.product!.deliveryInfo;
      _sellerInfoController.text = widget.product!.sellerInfo;
      _isActive = widget.product!.isActive;
      _selectedCategoryIds = widget.product!.categories.map((c) => c.id).toList(); // Pre-select categories for edit
    }
  }

  void _fetchCategories() async {
    try {
      final categories = await _apiService.getCategories();
      setState(() {
        _availableCategories = categories;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load categories: $e')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _priceController.dispose();
    _stockQuantityController.dispose();
    _deliveryInfoController.dispose();
    _sellerInfoController.dispose();
    super.dispose();
  }

  void _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        if (widget.product == null) {
          // Add new product using ProductCreate
          final productCreate = ProductCreate(
            name: _nameController.text,
            description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
            imageUrl: _imageUrlController.text.isEmpty ? null : _imageUrlController.text,
            price: double.parse(_priceController.text),
            stockQuantity: int.parse(_stockQuantityController.text),
            deliveryInfo: _deliveryInfoController.text.isEmpty ? '' : _deliveryInfoController.text,
            sellerInfo: _sellerInfoController.text.isEmpty ? '' : _sellerInfoController.text,
            isActive: _isActive,
            categoryIds: _selectedCategoryIds, // Send selected category IDs
          );
          await _apiService.createProduct(productCreate);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product added successfully!')),
          );
        } else {
          // Update existing product using full Product model
          final product = Product(
            id: widget.product!.id,
            name: _nameController.text,
            description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
            imageURL: _imageUrlController.text.isEmpty ? null : _imageUrlController.text,
            price: double.parse(_priceController.text),
            stockQuantity: int.parse(_stockQuantityController.text),
            deliveryInfo: _deliveryInfoController.text.isEmpty ? '' : _deliveryInfoController.text,
            sellerInfo: _sellerInfoController.text.isEmpty ? '' : _sellerInfoController.text,
            isActive: _isActive,
            // Keep original values for non-editable fields or fetch them
            soldCount: widget.product!.soldCount,
            rating: widget.product!.rating,
            reviewsCount: widget.product!.reviewsCount,
            categories: _availableCategories.where((cat) => _selectedCategoryIds.contains(cat.id)).toList(), // Reconstruct categories
          );
          await _apiService.updateProduct(product);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product updated successfully!')),
          );
        }
        Navigator.pop(context, true); // Pop and indicate success
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save product: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Add Product' : 'Edit Product'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Product Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a product name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description (Optional)'),
                maxLines: 3,
              ),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(labelText: 'Image URL (Optional)'),
                keyboardType: TextInputType.url,
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number for price';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _stockQuantityController,
                decoration: const InputDecoration(labelText: 'Stock Quantity'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter stock quantity';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number for stock quantity';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _deliveryInfoController,
                decoration: const InputDecoration(labelText: 'Delivery Info (Optional)'),
              ),
              TextFormField(
                controller: _sellerInfoController,
                decoration: const InputDecoration(labelText: 'Seller Info (Optional)'),
              ),
              SwitchListTile(
                title: const Text('Is Active'),
                value: _isActive,
                onChanged: (bool value) {
                  setState(() {
                    _isActive = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              Text('Categories', style: Theme.of(context).textTheme.titleMedium),
              Wrap(
                spacing: 8.0,
                children: _availableCategories.map((category) {
                  final isSelected = _selectedCategoryIds.contains(category.id);
                  return FilterChip(
                    label: Text(category.name),
                    selected: isSelected,
                    onSelected: (bool selected) {
                      setState(() {
                        if (selected) {
                          _selectedCategoryIds.add(category.id);
                        } else {
                          _selectedCategoryIds.removeWhere((id) => id == category.id);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveProduct,
                child: Text(widget.product == null ? 'Add Product' : 'Update Product'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}