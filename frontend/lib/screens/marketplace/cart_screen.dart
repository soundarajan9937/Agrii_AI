import 'package:flutter/material.dart';

import '../../models/product_model.dart';
import '../../services/cart_service.dart';
import '../../core/constants/api_constants.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Default Images
  String getProductImage(String productName) {
    switch (productName.toLowerCase().trim()) {
      case "rice": return "assets/products/rice.jpg";
      case "tomato": return "assets/products/tomato.jpg";
      case "mango": return "assets/products/mango.jpg";
      case "coconut": return "assets/products/coconut.jpg";
      case "groundnut": return "assets/products/groundnut.jpg";
      case "banana": return "assets/products/banana.jpg";
      case "potato": return "assets/products/potato.jpg";
      case "onion": return "assets/products/onion.jpg";
      case "chilli": return "assets/products/chilli.jpg";
      case "fertilizer":
      case "urea fertilizer": return "assets/products/fertilizer.jpg";
      default: return "assets/products/rice.jpg";
    }
  }

  Widget buildProductImage(ProductModel product) {
    if (product.image.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          ApiConstants.imageBaseUrl + product.image,
          width: 75,
          height: 75,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Image.asset(getProductImage(product.name), width: 75, height: 75, fit: BoxFit.cover),
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.asset(getProductImage(product.name), width: 75, height: 75, fit: BoxFit.cover),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<ProductModel> cartItemsList = CartService.cartItems;
    final double totalAmount = CartService.getTotalPrice();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F7FD),
      appBar: AppBar(title: const Text("My Cart"), centerTitle: true, backgroundColor: const Color(0xFF1976D2), foregroundColor: Colors.white),
      body: cartItemsList.isEmpty
          ? const Center(child: Text("Your cart is empty", style: TextStyle(fontSize: 18)))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(15),
                    itemCount: cartItemsList.length,
                    itemBuilder: (context, index) {
                      final product = cartItemsList[index];
                      return Card(
                        child: ListTile(
                          leading: buildProductImage(product),
                          title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("₹${product.price.toStringAsFixed(0)}"),
                          trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => setState(() => CartService.removeFromCart(product))),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                  child: Column(
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Total Amount", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), Text("₹${totalAmount.toStringAsFixed(0)}", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1976D2)))]),
                      const SizedBox(height: 20),
                      SizedBox(width: double.infinity, height: 55, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1976D2), foregroundColor: Colors.white), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CheckoutScreen(product: cartItemsList[0]))), child: const Text("Proceed to Checkout", style: TextStyle(fontSize: 18)))),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
