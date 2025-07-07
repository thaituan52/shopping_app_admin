// lib/models/order.dart
import 'order_item.dart';
class Order {
  final int id;
  final String userUid; // This will now be parsed from JSON
  final int status; // Changed to int
  final double totalAmount; // Changed to double
  final int? shippingAddressId;
  final String? billingMethod;
  final String? contactPhone;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<OrderItem> items; // Ensure this is non-nullable if always present, or handle null

  Order({
    required this.id,
    required this.userUid,
    required this.status,
    required this.totalAmount,
    this.shippingAddressId, // Made nullable as per your model
    this.billingMethod, // Made nullable
    this.contactPhone, // Made nullable
    required this.createdAt,
    required this.updatedAt,
    this.items = const [], // Ensure items is initialized, or handle null
  });

  factory Order.fromJson(Map<String, dynamic> json) { // userUid parameter removed
    final totalAmount = (json['total_amount'] as num?)?.toDouble() ?? 0.0;
    final createdAt = json['created_at'] != null
      ? DateTime.parse(json['created_at'] as String)
      : DateTime.now();
    final updatedAt = json['updated_at'] != null
      ? DateTime.parse(json['updated_at'] as String)
      : DateTime.now();
    final id = json['id'] as int;
    final items = (json['items'] as List<dynamic>?)
        ?.map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
        .toList() ?? [];
    final status = json['status'] as int? ?? 1; // Default to 1 (cart) if null

    return Order(
      id: id,
      userUid: json['user_uid'], // Read user_uid directly from JSON
      status: status,
      totalAmount: totalAmount,
      shippingAddressId: json['shipping_address_id'] as int?, // Corrected field name
      billingMethod: json['billing_method'] as String?,
      contactPhone: json['contact_phone'] as String?,
      createdAt: createdAt,
      updatedAt: updatedAt,
      items: items,
    );
  }

  // toJson for sending general order updates (excluding status for OrderUpdate)
  Map<String, dynamic> toJson() {
    return {
      'id': id, // Include ID for updates
      'user_uid': userUid,
      'status': status, // Include status for general update
      'total_amount': totalAmount,
      'shipping_address_id': shippingAddressId,
      'billing_method': billingMethod,
      'contact_phone': contactPhone,
      // 'created_at': createdAt?.toIso8601String(), // Not typically sent
      // 'updated_at': updatedAt?.toIso8601String(), // Not typically sent
    };
  }
}

class OrderUpdate {
  final int? shippingAddressId;
  final String? billingMethod;
  final String? contactPhone;
  // Note: status is intentionally excluded here for the general update endpoint,
  // as per your backend's PUT /orders/{order_id} logic.
  // Status updates have their own dedicated endpoint.

  OrderUpdate({
    this.shippingAddressId,
    this.billingMethod,
    this.contactPhone,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (shippingAddressId != null) {
      data['shipping_address_id'] = shippingAddressId;
    }
    if (billingMethod != null) {
      data['billing_method'] = billingMethod;
    }
    if (contactPhone != null) {
      data['contact_phone'] = contactPhone;
    }
    return data;
  }
}