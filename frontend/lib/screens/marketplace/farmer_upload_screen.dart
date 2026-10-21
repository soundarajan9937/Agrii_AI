import 'package:flutter/material.dart';

import '../../models/product_model.dart';
import '../../services/marketplace_api_service.dart';
import 'add_product_screen.dart';
import 'product_details_screen.dart';

class FarmerUploadScreen extends StatefulWidget {
  const FarmerUploadScreen({super.key});

  @override
  State<FarmerUploadScreen> createState() => _FarmerUploadScreenState();
}

class _FarmerUploadScreenState extends State<FarmerUploadScreen> {
  final MarketplaceApiService api = MarketplaceApiService();

  List<ProductModel> products = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  // ============================================================
  // LOAD FARMER PRODUCTS
  // ============================================================

  Future<void> loadProducts() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    try {
      /*
       * IMPORTANT:
       *
       * This currently gets products from your API.
       *
       * Later we will change this to:
       *
       * GET /api/products/my/:userId
       *
       * so that a farmer sees ONLY their own products.
       */

      final response = await api.getProducts();

      final List<ProductModel> loadedProducts = response
          .map<ProductModel>((item) => ProductModel.fromJson(item))
          .toList();

      if (!mounted) return;

      setState(() {
        products = loadedProducts;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Farmer Upload Error: $e");

      if (!mounted) return;

      setState(() {
        products = [];
        isLoading = false;
      });
    }
  }

  // ============================================================
  // OPEN ADD PRODUCT
  // ============================================================

  Future<void> openAddProduct() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddProductScreen()),
    );

    if (result == true && mounted) {
      await loadProducts();
    }
  }

  // ============================================================
  // GET STATUS COLOR
  // ============================================================

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "approved":
        return Colors.green;

      case "rejected":
        return Colors.red;

      case "pending":
      default:
        return Colors.orange;
    }
  }

  // ============================================================
  // STATUS TEXT
  // ============================================================

  String getStatusText(ProductModel product) {
    /*
     * If your ProductModel does not currently have approvalStatus,
     * we will add it in the next step.
     */

    try {
      final dynamic value = product.approvalStatus;

      if (value == null || value.toString().isEmpty) {
        return "Pending";
      }

      return value.toString();
    } catch (_) {
      return "Pending";
    }
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
          "Farmer Upload",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),

      // ========================================================
      // ADD PRODUCT
      // ========================================================
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        onPressed: openAddProduct,
        icon: const Icon(Icons.add),
        label: const Text("Upload Product"),
      ),

      // ========================================================
      // BODY
      // ========================================================
      body: RefreshIndicator(
        onRefresh: loadProducts,
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.green),
              )
            : products.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 150),

                  Icon(
                    Icons.cloud_upload_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),

                  SizedBox(height: 20),

                  Center(
                    child: Text(
                      "No Products Uploaded",
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  SizedBox(height: 8),

                  Center(
                    child: Text(
                      "Upload your agricultural products\n"
                      "for admin approval.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 15),
                    ),
                  ),
                ],
              )
            : ListView.builder(
                padding: const EdgeInsets.all(15),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];

                  final status = getStatusText(product);

                  final statusColor = getStatusColor(status);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 15),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --------------------------------
                          // PRODUCT HEADER
                          // --------------------------------
                          Row(
                            children: [
                              Container(
                                width: 65,
                                height: 65,
                                decoration: BoxDecoration(
                                  color: Colors.green.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.inventory_2_outlined,
                                  color: Colors.green,
                                  size: 32,
                                ),
                              ),

                              const SizedBox(width: 15),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(height: 5),

                                    Text(
                                      product.category,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // STATUS
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  status,
                                  style: TextStyle(
                                    color: statusColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 15),

                          const Divider(),

                          const SizedBox(height: 8),

                          // --------------------------------
                          // PRODUCT DETAILS
                          // --------------------------------
                          Row(
                            children: [
                              const Icon(
                                Icons.currency_rupee,
                                size: 20,
                                color: Colors.green,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                "₹${product.price}",
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const Spacer(),

                              const Icon(
                                Icons.scale_outlined,
                                size: 20,
                                color: Colors.grey,
                              ),

                              const SizedBox(width: 5),

                              Text(
                                "${product.quantity} ${product.unit}",
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          Text(
                            "Location: ${product.location}",
                            style: const TextStyle(color: Colors.grey),
                          ),

                          if (status.toLowerCase() == "rejected" && product.rejectionReason.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Rejection Reason:",
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      product.rejectionReason,
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 13,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                          const SizedBox(height: 15),

                          // --------------------------------
                          // VIEW DETAILS
                          // --------------------------------
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ProductDetailsScreen(product: product),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.visibility),
                              label: const Text("View Product"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
