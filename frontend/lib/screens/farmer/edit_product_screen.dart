import 'package:flutter/material.dart';

import '../../services/marketplace_api_service.dart';

class EditProductScreen extends StatefulWidget {
  const EditProductScreen({super.key, required this.product});

  final Map<String, dynamic> product;

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  // ==========================================================
  // CONTROLLERS
  // ==========================================================

  late TextEditingController nameController;
  late TextEditingController categoryController;
  late TextEditingController priceController;
  late TextEditingController quantityController;
  late TextEditingController descriptionController;
  late TextEditingController locationController;

  String selectedUnit = "Kg";

  final List<String> units = ["Kg", "Gram", "Litre", "Nos", "Bundle", "Box"];

  // ==========================================================
  // STATE
  // ==========================================================

  bool isLoading = false;

  final MarketplaceApiService _apiService = MarketplaceApiService();

  // ==========================================================
  // INIT
  // ==========================================================

  @override
  void initState() {
    super.initState();

    final p = widget.product;

    nameController = TextEditingController(text: p["name"]?.toString() ?? "");

    categoryController =
        TextEditingController(text: p["category"]?.toString() ?? "");

    priceController =
        TextEditingController(text: p["price"]?.toString() ?? "");

    quantityController =
        TextEditingController(text: p["quantity"]?.toString() ?? "");

    descriptionController =
        TextEditingController(text: p["description"]?.toString() ?? "");

    locationController =
        TextEditingController(text: p["location"]?.toString() ?? "");

    selectedUnit = p["unit"]?.toString() ?? "Kg";

    // Ensure selectedUnit is valid
    if (!units.contains(selectedUnit)) {
      selectedUnit = "Kg";
    }
  }

  // ==========================================================
  // UPDATE PRODUCT
  // ==========================================================

  Future<void> _updateProduct() async {
    final String name = nameController.text.trim();

    final String category = categoryController.text.trim();

    final String price = priceController.text.trim();

    final String quantity = quantityController.text.trim();

    final String description = descriptionController.text.trim();

    final String location = locationController.text.trim();

    // ========================================================
    // VALIDATE
    // ========================================================

    if (name.isEmpty ||
        category.isEmpty ||
        price.isEmpty ||
        quantity.isEmpty ||
        description.isEmpty) {
      _showMessage("Please fill all mandatory fields", Colors.red);

      return;
    }

    // ========================================================
    // START
    // ========================================================

    setState(() {
      isLoading = true;
    });

    try {
      final String productId = widget.product["_id"]?.toString() ?? "";

      if (productId.isEmpty) {
        throw Exception("Product ID is missing");
      }

      final bool success = await _apiService.updateProduct(
        id: productId,
        name: name,
        category: category,
        price: price,
        quantity: quantity,
        unit: selectedUnit,
        seller: "Current User",
        location: location,
        description: description,
      );

      if (!mounted) return;

      if (success) {
        _showMessage("Product updated successfully", Colors.orange);

        Navigator.pop(context, true);
      } else {
        _showMessage("Failed to update product", Colors.red);
      }
    } catch (e) {
      _showMessage("An error occurred", Colors.red);
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // ==========================================================
  // MESSAGE
  // ==========================================================

  void _showMessage(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF7F2),

      appBar: AppBar(
        title: const Text(
          "Edit Product",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ==================================================
                  // FORM
                  // ==================================================
                  _buildLabel("Product Name *"),
                  _buildTextField(nameController, "e.g. Organic Tomatoes"),

                  const SizedBox(height: 18),

                  _buildLabel("Category *"),
                  _buildTextField(categoryController, "e.g. Vegetables"),

                  const SizedBox(height: 18),

                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel("Price (₹) *"),
                            _buildTextField(
                              priceController,
                              "0.00",
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel("Unit *"),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: selectedUnit,
                                  isExpanded: true,
                                  items: units.map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  onChanged: (newValue) {
                                    setState(() {
                                      selectedUnit = newValue!;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  _buildLabel("Available Stock *"),
                  _buildTextField(
                    quantityController,
                    "0",
                    keyboardType: TextInputType.number,
                  ),

                  const SizedBox(height: 18),

                  _buildLabel("Farm Location"),
                  _buildTextField(locationController, "e.g. Punjab, India"),

                  const SizedBox(height: 18),

                  _buildLabel("Description *"),
                  _buildTextField(
                    descriptionController,
                    "Describe your product...",
                    maxLines: 4,
                  ),

                  const SizedBox(height: 35),

                  // ==================================================
                  // SUBMIT
                  // ==================================================
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _updateProduct,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Save Changes",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  // ==========================================================
  // HELPERS
  // ==========================================================

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.orange, width: 2),
        ),
      ),
    );
  }
}
