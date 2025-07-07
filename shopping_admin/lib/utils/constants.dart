// import '../utils/constants.dart';
const String apiBaseUrl = 'http://10.0.2.2:8000';

// Helper for OrderStatus as int
enum OrderStatusEnum {
  deactivated, // 0
  cart,        // 1
  processing,  // 2
  completed,   // 3
}

// Helper to convert int to OrderStatusEnum enum
OrderStatusEnum orderStatusFromInt(int value) {
  switch (value) {
    case 0: return OrderStatusEnum.deactivated;
    case 1: return OrderStatusEnum.cart;
    case 2: return OrderStatusEnum.processing;
    case 3: return OrderStatusEnum.completed;
    default: return OrderStatusEnum.cart; // Default or handle error
  }
}

// Helper to convert OrderStatusEnum enum to int
int orderStatusToInt(OrderStatusEnum status) {
  switch (status) {
    case OrderStatusEnum.deactivated: return 0;
    case OrderStatusEnum.cart: return 1;
    case OrderStatusEnum.processing: return 2;
    case OrderStatusEnum.completed: return 3;
  }
}