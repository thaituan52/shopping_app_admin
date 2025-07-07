// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category.dart';
import '../models/product.dart';
import '../models/order.dart';
import '../utils/constants.dart'; // Assuming you have this for apiBaseUrl

class ApiService {
  static const String _baseUrl = apiBaseUrl;

  // --- Category Endpoints ---

  Future<List<Category>> getCategories({int skip = 0, int limit = 100}) async {
    final response = await http.get(Uri.parse('$_baseUrl/categories/?skip=$skip&limit=$limit'));
    if (response.statusCode == 200) {
      Iterable list = json.decode(response.body);
      return list.map((model) => Category.fromJson(model)).toList();
    } else {
      throw Exception('Failed to load categories: ${response.body}');
    }
  }

  Future<Category> getCategoryById(int categoryId) async {
    final response = await http.get(Uri.parse('$_baseUrl/categories/$categoryId'));
    if (response.statusCode == 200) {
      return Category.fromJson(json.decode(response.body));
    } else if (response.statusCode == 404) {
      throw Exception('Category not found');
    } else {
      throw Exception('Failed to load category: ${response.body}');
    }
  }

  Future<Category> createCategory(Category category) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/categories/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(category.toJson()),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return Category.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create category: ${response.body}');
    }
  }

  // NOTE: These PUT/DELETE category endpoints were not explicitly provided in your backend snippet.
  // Ensure they exist in your FastAPI backend if you intend to use them.
  Future<Category> updateCategory(Category category) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/categories/${category.id}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(category.toJson()),
    );
    if (response.statusCode == 200) {
      return Category.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update category: ${response.body}');
    }
  }

  Future<void> deleteCategory(int id) async {
    final response = await http.delete(Uri.parse('$_baseUrl/categories/$id'));
    if (response.statusCode != 204) {
      throw Exception('Failed to delete category: ${response.body}');
    }
  }

  // --- Product Endpoints ---

  Future<List<Product>> getProducts({int skip = 0, int limit = 100, int? categoryId, String? query}) async {
    String url = '$_baseUrl/products/?skip=$skip&limit=$limit';
    if (categoryId != null) {
      url += '&category_id=$categoryId';
    }
    if (query != null && query.isNotEmpty) {
      url += '&q=${Uri.encodeComponent(query)}';
    }

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      Iterable list = json.decode(response.body);
      return list.map((model) => Product.fromJson(model)).toList();
    } else {
      throw Exception('Failed to load products: ${response.body}');
    }
  }

  Future<Product> getProductById(int productId) async {
    final response = await http.get(Uri.parse('$_baseUrl/products/$productId'));
    if (response.statusCode == 200) {
      return Product.fromJson(json.decode(response.body));
    } else if (response.statusCode == 404) {
      throw Exception('Product not found');
    } else {
      throw Exception('Failed to load product: ${response.body}');
    }
  }

  Future<Product> createProduct(ProductCreate productCreate) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/products/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(productCreate.toJson()),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return Product.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create product: ${response.body}');
    }
  }

  Future<Product> updateProduct(Product product) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/products/${product.id}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      // Note: For update, you might want to send only changed fields or use a ProductUpdate schema if your backend expects it.
      // Current implementation sends the full Product model's toJson.
      body: jsonEncode(product.toJson()),
    );
    if (response.statusCode == 200) {
      return Product.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update product: ${response.body}');
    }
  }

  Future<void> deleteProduct(int id) async {
    final response = await http.delete(Uri.parse('$_baseUrl/products/$id'));
    if (response.statusCode != 204) { // Backend returns 200 with message on soft delete
      throw Exception('Failed to delete product: ${response.body}');
    }
  }

  // --- Order Endpoints ---

  Future<List<Order>> getOrders({int skip = 0, int limit = 100, int? status}) async {
    String url = '$_baseUrl/orders/?skip=$skip&limit=$limit';
    if (status != null) {
      url += '&status=$status';
    }
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      Iterable list = json.decode(response.body);
      return list.map((model) => Order.fromJson(model)).toList(); // No need to pass userUid anymore
    } else {
      throw Exception('Failed to load orders: ${response.body}');
    }
  }

  Future<Order> getOrderById(int id) async {
    final response = await http.get(Uri.parse('$_baseUrl/orders/$id'));
    if (response.statusCode == 200) {
      return Order.fromJson(json.decode(response.body)); // No need to pass userUid anymore
    } else if (response.statusCode == 404) {
      throw Exception('Order not found');
    } else {
      throw Exception('Failed to load order: ${response.body}');
    }
  }

  Future<Order> updateOrderStatus(int orderId, OrderStatusEnum newStatus) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/orders/$orderId/status/${orderStatusToInt(newStatus)}'),
      headers: <String, String>{
        'Content-Type': 'application/json', // Backend doesn't expect body for this endpoint
      },
    );
    if (response.statusCode == 200) {
      return Order.fromJson(json.decode(response.body)); // No need to pass userUid anymore
    } else if (response.statusCode == 404) {
      throw Exception('Order not found');
    } else {
      throw Exception('Failed to update order status: ${response.statusCode} - ${response.body}');
    }
  }

  Future<Order> updateOrder(int orderId, OrderUpdate orderUpdateData) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/orders/$orderId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(orderUpdateData.toJson()),
    );
    if (response.statusCode == 200) {
      return Order.fromJson(json.decode(response.body)); // No need to pass userUid anymore
    } else if (response.statusCode == 404) {
      throw Exception('Order not found');
    } else {
      throw Exception('Failed to update order: ${response.statusCode} - ${response.body}');
    }
  }

  Future<void> deleteOrder(int id) async {
    final response = await http.delete(Uri.parse('$_baseUrl/orders/$id'));
    if (response.statusCode != 200) { // Backend returns 200 with message on soft delete
      throw Exception('Failed to delete order: ${response.body}');
    }
  }
}