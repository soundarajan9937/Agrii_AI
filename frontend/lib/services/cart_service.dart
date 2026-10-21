import '../models/product_model.dart';

class CartService {
  static final List<ProductModel> _cartItems = [];

  // Get all cart items
  static List<ProductModel> get cartItems => _cartItems;

  // Add product
  static void addToCart(ProductModel product) {
    _cartItems.add(product);
  }

  // Remove product
  static void removeFromCart(ProductModel product) {
    _cartItems.remove(product);
  }

  // Clear cart
  static void clearCart() {
    _cartItems.clear();
  }

  // Total price
  static double getTotalPrice() {
    double total = 0;

    for (var item in _cartItems) {
      total += item.price;
    }

    return total;
  }

  // Number of products
  static int get itemCount {
    return _cartItems.length;
  }

  // Check empty
  static bool get isEmpty {
    return _cartItems.isEmpty;
  }
}
