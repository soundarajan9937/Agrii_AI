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
      case "rice":
        return "assets/products/rice.jpg";
      case "tomato":
        return "assets/products/tomato.jpg";
      case "mango":
        return "assets/products/mango.jpg";
      case "coconut":
        return "assets/products/coconut.jpg";
      case "groundnut":
        return "assets/products/groundnut.jpg";
      case "banana":
        return "assets/products/banana.jpg";
      case "potato":
        return "assets/products/potato.jpg";
      case "onion":
        return "assets/products/onion.jpg";
      case "chilli":
        return "assets/products/chilli.jpg";
      case "fertilizer":
      case "urea fertilizer":
        return "assets/products/fertilizer.jpg";
      default:
        return "assets/products/rice.jpg";
    }
  }

  Widget buildProductImage(ProductModel product) {
    if (product.image.isNotEmpty) {
      final String fullUrl = product.image.startsWith("http")
          ? product.image
          : ApiConstants.imageBaseUrl + product.image;

      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          fullUrl,
          width: 72,
          height: 72,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Image.asset(
            getProductImage(product.name),
            width: 72,
            height: 72,
            fit: BoxFit.cover,
          ),
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.asset(
        getProductImage(product.name),
        width: 72,
        height: 72,
        fit: BoxFit.cover,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<ProductModel> cartItemsList = CartService.cartItems;
    final double totalAmount = CartService.getTotalPrice();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          "My Produce Cart",
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 19, letterSpacing: -0.3),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF0F766E), // Deep Teal
                Color(0xFF059669), // Emerald
                Color(0xFF0284C7), // Sky Azure
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: cartItemsList.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: const BoxDecoration(
                        color: Color(0xFFECFDF5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.shopping_cart_outlined,
                        size: 44,
                        color: Color(0xFF059669),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Your Cart is Empty",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Explore fresh crops directly from local farmers and add them to your cart.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13.5, color: Color(0xFF64748B), height: 1.4),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.storefront_rounded, size: 18),
                      label: const Text(
                        "Explore Marketplace",
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF059669),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: cartItemsList.length,
                    itemBuilder: (context, index) {
                      final product = cartItemsList[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.1),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0F172A).withValues(alpha: 0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            buildProductImage(product),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    "Grower: ${product.sellerName.isNotEmpty ? product.sellerName : 'Local Farmer'}",
                                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "₹${product.price.toStringAsFixed(0)} / ${product.unit.isNotEmpty ? product.unit : 'Kg'}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 15,
                                      color: Color(0xFF059669),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFDC2626)),
                              tooltip: "Remove Item",
                              onPressed: () {
                                setState(() {
                                  CartService.removeFromCart(product);
                                });
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.08),
                        blurRadius: 16,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Total Produce Amount",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF64748B),
                              ),
                            ),
                            Text(
                              "₹${totalAmount.toStringAsFixed(0)}",
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF059669),
                                letterSpacing: -0.4,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CheckoutScreen(product: cartItemsList[0]),
                                ),
                              );
                            },
                            icon: const Icon(Icons.shopping_bag_outlined, size: 20),
                            label: const Text(
                              "Proceed to Checkout",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF059669),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
