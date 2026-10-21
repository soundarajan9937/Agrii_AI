import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../screens/marketplace/product_details_screen.dart';
import '../core/constants/api_constants.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailsScreen(product: product))),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: const BorderRadius.vertical(top: Radius.circular(15))),
                child: product.image.isNotEmpty
                    ? ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(15)), child: Image.network(ApiConstants.imageBaseUrl + product.image, fit: BoxFit.cover, width: double.infinity))
                    : const Center(child: Icon(Icons.inventory_2, size: 50, color: Colors.green)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text("₹${product.price}", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
