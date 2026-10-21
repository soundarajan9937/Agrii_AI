import 'package:flutter/material.dart';

import '../../models/product_model.dart';
import '../../services/cart_service.dart';
import '../../core/constants/api_constants.dart';
import 'cart_screen.dart';

class ProductDetailsScreen extends StatelessWidget {
  final ProductModel product;

  const ProductDetailsScreen({super.key, required this.product});

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

  Widget buildProductImage() {
    if (product.image.isNotEmpty) {
      return Image.network(
        ApiConstants.imageBaseUrl + product.image,
        width: double.infinity,
        height: 260,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const SizedBox(height: 260, child: Center(child: CircularProgressIndicator(color: Color(0xFF1976D2))));
        },
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(getProductImage(product.name), width: double.infinity, height: 260, fit: BoxFit.cover);
        },
      );
    }
    return Image.asset(getProductImage(product.name), width: double.infinity, height: 260, fit: BoxFit.cover);
  }

  Widget infoTile(IconData icon, String title, String value) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(leading: Icon(icon, color: const Color(0xFF1976D2)), title: Text(title), subtitle: Text(value)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F7FD),
      appBar: AppBar(title: Text(product.name), centerTitle: true, backgroundColor: const Color(0xFF1976D2), foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(tag: product.id, child: ClipRRect(borderRadius: BorderRadius.circular(20), child: buildProductImage())),
            const SizedBox(height: 20),
            Text(product.name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text("₹${product.price.toStringAsFixed(0)}", style: const TextStyle(color: Color(0xFF1976D2), fontWeight: FontWeight.bold, fontSize: 28)),
            const SizedBox(height: 20),
            infoTile(Icons.category, "Category", product.category),
            infoTile(Icons.scale, "Quantity", product.quantity),
            infoTile(Icons.person, "Seller", product.sellerName.isNotEmpty ? product.sellerName : "Farmer"),
            infoTile(Icons.phone, "Phone Number", product.sellerPhone.isNotEmpty ? product.sellerPhone : "Not Provided"),
            infoTile(Icons.location_on, "Location", product.location),
            const SizedBox(height: 15),
            const Text("Description", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
            const SizedBox(height: 10),
            Card(child: Padding(padding: const EdgeInsets.all(15), child: Text(product.description.isEmpty ? "No description available." : product.description, style: const TextStyle(fontSize: 16)))),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.shopping_cart),
                label: const Text("Add to Cart", style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
                onPressed: () {
                  CartService.addToCart(product);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${product.name} added to cart"), backgroundColor: const Color(0xFF1976D2)));
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
                },
              ),
            ),
            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }
}
