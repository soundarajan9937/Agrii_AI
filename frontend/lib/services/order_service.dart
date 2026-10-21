import '../models/product_model.dart';

class OrderService {
  static final List<ProductModel> _orders = [];

  // Get all orders
  static List<ProductModel> get orders => _orders;

  // Add a single order
  static void addOrder(ProductModel product) {
    _orders.add(product);
  }

  // Add all cart items as orders
  static void addOrders(List<ProductModel> products) {
    _orders.addAll(products);
  }

  // Remove an order
  static void removeOrder(ProductModel product) {
    _orders.remove(product);
  }

  // Clear all orders
  static void clearOrders() {
    _orders.clear();
  }

  // Total orders
  static int get orderCount => _orders.length;

  // Check empty
  static bool get isEmpty => _orders.isEmpty;
}
