// lib/screens/order_list_screen.dart
import 'package:flutter/material.dart';
import '../models/order.dart';
import '../service/admin_service.dart';
import '../utils/constants.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  late Future<List<Order>> _orders;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  void _fetchOrders() {
    setState(() {
      _orders = _apiService.getOrders();
    });
  }

  String _getOrderStatusText(int status) { // Takes int now
    final statusEnum = orderStatusFromInt(status);
    switch (statusEnum) {
      case OrderStatusEnum.deactivated: return 'Deactivated';
      case OrderStatusEnum.cart: return 'In Cart';
      case OrderStatusEnum.processing: return 'Processing (Shipping)';
      case OrderStatusEnum.completed: return 'Completed (Done)';
      default: return 'Unknown';
    }
  }

  Color _getOrderStatusColor(int status) { // Takes int now
    final statusEnum = orderStatusFromInt(status);
    switch (statusEnum) {
      case OrderStatusEnum.deactivated: return Colors.grey;
      case OrderStatusEnum.cart: return Colors.blue;
      case OrderStatusEnum.processing: return Colors.orange;
      case OrderStatusEnum.completed: return Colors.green;
      default: return Colors.black;
    }
  }

  void _updateOrderStatusToCompleted(Order order) async {
    try {
      // Check if current status is processing (2)
      if (order.status == orderStatusToInt(OrderStatusEnum.processing)) {
        await _apiService.updateOrderStatus(order.id, OrderStatusEnum.completed);
        _fetchOrders(); // Refresh list
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order status updated to Completed!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order is not in "Processing" status to be completed.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update order status: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Order>>(
        future: _orders,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No orders found.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Order order = snapshot.data![index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text('Order #${order.id} (User: ${order.userUid.substring(0, 8)}...)'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total: \$${order.totalAmount}'), // Double used directly
                        Text(
                          'Status: ${_getOrderStatusText(order.status)}',
                          style: TextStyle(color: _getOrderStatusColor(order.status), fontWeight: FontWeight.bold),
                        ),
                        Text('Created: ${order.createdAt.toLocal().toString().split('.')[0]}'),
                      ],
                    ),
                    trailing: order.status == orderStatusToInt(OrderStatusEnum.processing)
                        ? ElevatedButton(
                            onPressed: () {
                              _updateOrderStatusToCompleted(order);
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                            child: const Text('Mark Done', style: TextStyle(color: Colors.white)),
                          )
                        : null,
                    onTap: () {
                      // You could navigate to an Order detail screen here if needed
                      // Navigator.push(context, MaterialPageRoute(builder: (context) => OrderDetailScreen(order: order)));
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}