import 'package:flutter/material.dart';

import '../../models/product_model.dart';
import '../../services/cart_service.dart';
import '../../core/constants/api_constants.dart';
import 'cart_screen.dart';
import 'checkout_screen.dart';

class ProductDetailsScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
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

  Widget buildProductImage() {
    if (widget.product.image.isNotEmpty) {
      final String fullUrl = widget.product.image.startsWith("http")
          ? widget.product.image
          : ApiConstants.imageBaseUrl + widget.product.image;

      return Image.network(
        fullUrl,
        width: double.infinity,
        height: 270,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const SizedBox(
            height: 270,
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Color(0xFF059669),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            getProductImage(widget.product.name),
            width: double.infinity,
            height: 270,
            fit: BoxFit.cover,
          );
        },
      );
    }
    return Image.asset(
      getProductImage(widget.product.name),
      width: double.infinity,
      height: 270,
      fit: BoxFit.cover,
    );
  }

  Widget _specTile({
    required IconData icon,
    required String title,
    required String value,
    Color iconColor = const Color(0xFF059669),
    Color iconBg = const Color(0xFFECFDF5),
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final int cartCount = CartService.cartItems.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          product.name,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 19,
            letterSpacing: -0.3,
          ),
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
        actions: [
          IconButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartScreen()),
              );
              setState(() {});
            },
            icon: Stack(
              children: [
                const Icon(Icons.shopping_cart_outlined, size: 24),
                if (cartCount > 0)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(3.5),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEA580C),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        "$cartCount",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- PRODUCT IMAGE CONTAINER ---
            Hero(
              tag: product.id,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.08),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    buildProductImage(),
                    Positioned(
                      top: 14,
                      left: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.eco_rounded, size: 14, color: Color(0xFF34D399)),
                            const SizedBox(width: 5),
                            Text(
                              product.category.isNotEmpty ? product.category : "Fresh Harvest",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // --- TITLE & PRICE STRIP ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.1),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                            letterSpacing: -0.4,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFA7F3D0)),
                        ),
                        child: const Text(
                          "Direct Farm",
                          style: TextStyle(
                            color: Color(0xFF059669),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        "₹${product.price.toStringAsFixed(0)}",
                        style: const TextStyle(
                          color: Color(0xFF059669),
                          fontWeight: FontWeight.w900,
                          fontSize: 28,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        " / ${product.unit.isNotEmpty ? product.unit : 'Kg'}",
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // --- SPECIFICATIONS HEADER ---
            Row(
              children: const [
                Icon(Icons.tune_rounded, size: 17, color: Color(0xFF059669)),
                SizedBox(width: 8),
                Text(
                  "Product Details",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            _specTile(
              icon: Icons.category_rounded,
              title: "Category",
              value: product.category.isNotEmpty ? product.category : "General Produce",
            ),
            _specTile(
              icon: Icons.inventory_2_outlined,
              title: "Quantity Available",
              value: "${product.quantity} ${product.unit}",
            ),
            _specTile(
              icon: Icons.person_outline_rounded,
              title: "Farmer / Grower",
              value: product.sellerName.isNotEmpty ? product.sellerName : "Local Grower",
            ),
            _specTile(
              icon: Icons.phone_outlined,
              title: "Contact Number",
              value: product.sellerPhone.isNotEmpty ? product.sellerPhone : "Available after order",
            ),
            _specTile(
              icon: Icons.location_on_outlined,
              title: "Farm Location",
              value: product.location.isNotEmpty ? product.location : "Direct Local Farm",
            ),

            const SizedBox(height: 16),

            // --- DESCRIPTION ---
            Row(
              children: const [
                Icon(Icons.description_outlined, size: 17, color: Color(0xFF059669)),
                SizedBox(width: 8),
                Text(
                  "Produce Description",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.1),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                product.description.isEmpty
                    ? "Freshly harvested natural crop sourced directly from registered regional farms. Quality inspected for optimal taste and nutrition."
                    : product.description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF475569),
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),

      // --- BOTTOM ACTION BAR ---
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
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
          child: Row(
            children: [
              // Add to Cart
              Expanded(
                flex: 1,
                child: SizedBox(
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      CartService.addToCart(product);
                      setState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("${product.name} added to cart!"),
                          backgroundColor: const Color(0xFF059669),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add_shopping_cart_rounded, size: 18, color: Color(0xFF059669)),
                    label: const Text(
                      "Add to Cart",
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF059669),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF059669), width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Buy Now
              Expanded(
                flex: 1,
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CheckoutScreen(product: product, initialQuantity: 1),
                        ),
                      );
                    },
                    icon: const Icon(Icons.bolt_rounded, size: 20),
                    label: const Text(
                      "Buy Now",
                      style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF059669),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
