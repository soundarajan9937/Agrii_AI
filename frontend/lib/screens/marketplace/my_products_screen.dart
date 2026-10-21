import 'package:flutter/material.dart';

import '../../core/constants/api_constants.dart';
import '../../models/product_model.dart';
import '../../services/marketplace_api_service.dart';
import 'edit_product_screen.dart';

class MyProductsScreen extends StatefulWidget {
  const MyProductsScreen({super.key});

  @override
  State<MyProductsScreen> createState() => _MyProductsScreenState();
}

class _MyProductsScreenState extends State<MyProductsScreen> {
  final MarketplaceApiService api = MarketplaceApiService();

  List<ProductModel> products = [];

  bool isLoading = true;
  bool isDeleting = false;

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  // ============================================================
  // LOAD PRODUCTS
  // ============================================================

  Future<void> loadProducts() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    try {
      final data = await api.getProducts();

      final loadedProducts = data
          .map<ProductModel>(
            (e) => ProductModel.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList();

      for (final product in loadedProducts) {
        debugPrint('PRODUCT IMAGE = ${product.image}');
      }

      if (!mounted) return;

      setState(() {
        products = loadedProducts;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('GET MY PRODUCTS ERROR: $e');

      if (!mounted) return;

      setState(() {
        products = [];
        isLoading = false;
      });

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('Failed to load products: $e'),
            backgroundColor: Colors.red,
          ),
        );
    }
  }

  // ============================================================
  // DELETE PRODUCT
  // ============================================================

  Future<void> deleteProduct(String id) async {
    if (isDeleting) return;

    setState(() {
      isDeleting = true;
    });

    try {
      final success = await api.deleteProduct(id);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text('Product Deleted Successfully'),
              backgroundColor: Colors.green,
            ),
          );

        await loadProducts();
      } else {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text('Failed to delete product'),
              backgroundColor: Colors.red,
            ),
          );
      }
    } catch (e) {
      debugPrint('DELETE PRODUCT ERROR: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('Delete error: $e'),
            backgroundColor: Colors.red,
          ),
        );
    } finally {
      if (mounted) {
        setState(() {
          isDeleting = false;
        });
      }
    }
  }

  // ============================================================
  // CONFIRM DELETE
  // ============================================================

  Future<void> confirmDelete(ProductModel product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Product'),
          content: Text('Are you sure you want to delete "${product.name}"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm != true || !mounted) return;

    await deleteProduct(product.id);
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F2),

      // ========================================================
      // APP BAR
      // ========================================================
      appBar: AppBar(
        title: const Text(
          'My Products',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),

      // ========================================================
      // BODY
      // ========================================================
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : products.isEmpty
          ? RefreshIndicator(
              onRefresh: loadProducts,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 220),
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: Text(
                      'No Products Added',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Your uploaded products will appear here.',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              color: Colors.green,
              onRefresh: loadProducts,
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(15),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];

                  return _buildProductCard(product);
                },
              ),
            ),
    );
  }

  // ============================================================
  // PRODUCT CARD
  // ============================================================

  Widget _buildProductCard(ProductModel product) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==================================================
            // IMAGE + BASIC DETAILS
            // ==================================================
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildProductImage(product),

                const SizedBox(width: 15),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        product.category,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        '₹${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        'Quantity: ${product.quantity} ${product.unit}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            // ==================================================
            // APPROVAL STATUS
            // ==================================================
            _buildApprovalStatus(product),

            const SizedBox(height: 15),

            // ==================================================
            // LOCATION
            // ==================================================
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.location_on,
                  size: 20,
                  color: Colors.redAccent,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    product.location.isEmpty
                        ? 'Location not provided'
                        : 'Location: ${product.location}',
                    style: const TextStyle(color: Colors.black87),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // ==================================================
            // SELLER
            // ==================================================
            Row(
              children: [
                const Icon(Icons.person, size: 20, color: Colors.blueGrey),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    product.sellerName.isNotEmpty
                        ? 'Seller: ${product.sellerName}'
                        : 'Seller ID: ${product.seller}',
                    style: const TextStyle(color: Colors.black87),
                  ),
                ),
              ],
            ),

            // ==================================================
            // DESCRIPTION
            // ==================================================
            if (product.description.trim().isNotEmpty) ...[
              const SizedBox(height: 15),

              const Text(
                'Description',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),

              const SizedBox(height: 5),

              Text(
                product.description,
                style: const TextStyle(color: Colors.black87, height: 1.4),
              ),
            ],

            const SizedBox(height: 20),

            // ==================================================
            // EDIT + DELETE
            // ==================================================
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: isDeleting
                        ? null
                        : () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    EditProductScreen(product: product),
                              ),
                            );

                            if (!mounted) return;

                            if (result == true) {
                              await loadProducts();
                            }
                          },
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: isDeleting ? null : () => confirmDelete(product),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // APPROVAL STATUS
  // ============================================================

  Widget _buildApprovalStatus(ProductModel product) {
    final status = product.approvalStatus.trim().toLowerCase();

    Color backgroundColor;
    Color textColor;
    IconData icon;
    String text;

    switch (status) {
      case 'approved':
        backgroundColor = Colors.green.shade50;
        textColor = Colors.green.shade700;
        icon = Icons.check_circle;
        text = 'Approved';
        break;

      case 'rejected':
        backgroundColor = Colors.red.shade50;
        textColor = Colors.red.shade700;
        icon = Icons.cancel;
        text = 'Rejected';
        break;

      case 'pending':
      default:
        backgroundColor = Colors.orange.shade50;
        textColor = Colors.orange.shade800;
        icon = Icons.pending;
        text = 'Waiting for Admin Approval';
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor, size: 21),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PRODUCT IMAGE
  // ============================================================

  Widget buildProductImage(ProductModel product) {
    String imageUrl = '';

    if (product.image.trim().isNotEmpty) {
      final image = product.image.trim();

      // If backend already returned a complete URL.
      if (image.startsWith('http://') || image.startsWith('https://')) {
        imageUrl = image;
      } else {
        // Backend normally stores only the filename.
        imageUrl = '${ApiConstants.imageBaseUrl}$image';
      }
    }

    debugPrint('PRODUCT IMAGE URL = $imageUrl');

    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.green.shade100,
      ),
      child: imageUrl.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                width: 90,
                height: 90,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  }

                  return const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.green,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  debugPrint('IMAGE LOAD ERROR: $error');

                  return const Center(
                    child: Icon(
                      Icons.broken_image,
                      color: Colors.red,
                      size: 40,
                    ),
                  );
                },
              ),
            )
          : const Center(
              child: Icon(Icons.agriculture, color: Colors.green, size: 40),
            ),
    );
  }
}
