import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/marketplace_api_service.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  // ==========================================================
  // CONTROLLERS
  // ==========================================================

  final TextEditingController nameController = TextEditingController();

  final TextEditingController priceController = TextEditingController();

  final TextEditingController quantityController = TextEditingController();

  final TextEditingController descriptionController = TextEditingController();

  final TextEditingController locationController = TextEditingController();

  String selectedUnit = "Kg";

  final List<String> units = ["Kg", "Gram", "Litre", "Nos", "Bundle", "Box"];

  String? selectedCategory;

  final List<String> categories = [
    "Vegetables",
    "Fruits",
    "Grains",
    "Seeds",
    "Fertilizers",
    "Tools"
  ];

  // ==========================================================
  // STATE
  // ==========================================================

  File? _selectedImage;

  bool isLoading = false;

  final MarketplaceApiService _apiService = MarketplaceApiService();

  // ==========================================================
  // PICK IMAGE
  // ==========================================================

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();

    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
        requestFullMetadata: false,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      debugPrint("PICK IMAGE ERROR: $e");
    }
  }

  // ==========================================================
  // ADD PRODUCT
  // ==========================================================

  Future<void> _submitProduct() async {
    final String name = nameController.text.trim();

    final String price = priceController.text.trim();

    final String quantity = quantityController.text.trim();

    final String description = descriptionController.text.trim();

    final String location = locationController.text.trim();

    // ========================================================
    // VALIDATE
    // ========================================================

    if (name.isEmpty ||
        selectedCategory == null ||
        price.isEmpty ||
        quantity.isEmpty ||
        description.isEmpty ||
        _selectedImage == null) {
      _showMessage("Please fill all mandatory fields and select a photo", Colors.red);

      return;
    }

    if (double.tryParse(price) == null) {
      _showMessage("Price must be a number", Colors.red);
      return;
    }

    if (double.tryParse(quantity) == null) {
      _showMessage("Stock must be a number", Colors.red);
      return;
    }

    // ========================================================
    // START
    // ========================================================

    setState(() {
      isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final String sellerId = prefs.getString("userId") ?? "unknown";

      final Map<String, dynamic> result = await _apiService.addProduct(
        name: name,
        category: selectedCategory!,
        price: price,
        quantity: quantity,
        unit: selectedUnit,
        seller: sellerId,
        location: location,
        description: description,
        image: _selectedImage,
      );

      if (!mounted) return;

      if (result["success"] == true) {
        _showMessage(result["message"] ?? "Product uploaded!", Colors.orange);
        Navigator.pop(context, true);
      } else {
        _showMessage(result["message"] ?? "Upload failed", Colors.red);
      }
    } catch (e) {
      _showMessage("An error occurred: $e", Colors.red);
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
  // HELPERS
  // ==========================================================

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.orange),
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.orange, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.orangeAccent, width: 2.0),
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
          "Upload Product",
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
                  // IMAGE PREVIEW
                  // ==================================================
                  const Text(
                    "Product Image *",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 12),

                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: double.infinity,
                      height: 180,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.orange, width: 1.5),
                      ),
                      child: _selectedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.file(
                                _selectedImage!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_a_photo,
                                  size: 40,
                                  color: Colors.orange,
                                ),
                                SizedBox(height: 10),
                                Text(
                                  "Click to pick image",
                                  style: TextStyle(color: Colors.orange),
                                ),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // ==================================================
                  // FORM
                  // ==================================================
                  TextFormField(
                    controller: nameController,
                    decoration: _inputDecoration("Product Name *"),
                  ),

                  const SizedBox(height: 18),

                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: _inputDecoration("Category *"),
                    items: categories.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        selectedCategory = newValue;
                      });
                    },
                  ),

                  const SizedBox(height: 18),

                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: priceController,
                          decoration: _inputDecoration("Price (₹) *"),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        flex: 1,
                        child: DropdownButtonFormField<String>(
                          value: selectedUnit,
                          decoration: _inputDecoration("Unit *"),
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
                    ],
                  ),

                  const SizedBox(height: 18),

                  TextFormField(
                    controller: quantityController,
                    decoration: _inputDecoration("Available Stock *"),
                    keyboardType: TextInputType.number,
                  ),

                  const SizedBox(height: 18),

                  TextFormField(
                    controller: locationController,
                    decoration: _inputDecoration("Farm Location"),
                  ),

                  const SizedBox(height: 18),

                  TextFormField(
                    controller: descriptionController,
                    decoration: _inputDecoration("Description *"),
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
                      onPressed: isLoading ? null : _submitProduct,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Upload Product",
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
}
