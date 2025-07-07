import 'package:flutter/material.dart';
import './views/category_form_screen.dart'; // Ensure this path is correct
import './views/category_list_screen.dart'; // Ensure this path is correct
import './views/product_form_screen.dart'; // Ensure this path is correct
import './views/product_list_screen.dart'; // Ensure this path is correct
import './views/order_list_screen.dart'; // Ensure this path is correct

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin Panel',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // Define your routes for navigation
      initialRoute: '/',
      routes: {
        '/': (context) => const MainAdminScreen(), // Main screen with navigation
        '/categories': (context) => const CategoryListScreen(),
        '/add_category': (context) => const CategoryFormScreen(),
        // For editing, you might pass arguments, which is handled in CategoryListScreen's onTap
        '/products': (context) => const ProductListScreen(),
        '/add_product': (context) => const ProductFormScreen(),
        // For editing, handled in ProductListScreen's onTap
        '/orders': (context) => const OrderListScreen(),
        // Order details/edit would be another route if implemented
      },
    );
  }
}

// A simple main screen to navigate to different admin sections
class MainAdminScreen extends StatelessWidget {
  const MainAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _buildAdminButton(context, 'Manage Categories', '/categories'),
            const SizedBox(height: 20),
            _buildAdminButton(context, 'Manage Products', '/products'),
            const SizedBox(height: 20),
            _buildAdminButton(context, 'Manage Orders', '/orders'),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminButton(BuildContext context, String text, String routeName) {
    return SizedBox(
      width: 200,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, routeName);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontSize: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(text),
      ),
    );
  }
}