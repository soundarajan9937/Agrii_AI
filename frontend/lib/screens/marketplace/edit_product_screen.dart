import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/product_model.dart';
import '../../services/marketplace_api_service.dart';

class EditProductScreen extends StatefulWidget {
  final ProductModel product;

  const EditProductScreen({super.key, required this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();

  final MarketplaceApiService api = MarketplaceApiService();
  final ImagePicker picker = ImagePicker();

  late TextEditingController nameController;
  late TextEditingController categoryController;
  late TextEditingController priceController;
  late TextEditingController quantityController;
  late TextEditingController locationController;
  late TextEditingController descriptionController;

  late String selectedUnit;

  File? selectedImage;

  bool isLoading = false;

  // ============================================================
  // UNITS
  // ============================================================

  final List<String> units = [
    'Kg',
    'Quintal',
    'Ton',
    'Gram',
    'Liter',
    'Piece',
    'Dozen',
    'Bag',
  ];

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.product.name);

    categoryController = TextEditingController(text: widget.product.category);

    priceController = TextEditingController(
      text: widget.product.price.toString(),
    );

    quantityController = TextEditingController(text: widget.product.quantity);

    locationController = TextEditingController(text: widget.product.location);

    descriptionController = TextEditingController(
      text: widget.product.description,
    );

    // Use existing product unit.
    // If the old product has an unknown/empty unit,
    // default to Kg.
    final existingUnit = widget.product.unit.trim();

    if (existingUnit.isNotEmpty && units.contains(existingUnit)) {
      selectedUnit = existingUnit;
    } else {
      selectedUnit = 'Kg';
    }
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    nameController.dispose();
    categoryController.dispose();
    priceController.dispose();
    quantityController.dispose();
    locationController.dispose();
    descriptionController.dispose();

    super.dispose();
  }

  // ============================================================
  // PICK IMAGE
  // ============================================================

  Future<void> pickImage() async {
    try {
      final XFile? picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (picked == null || !mounted) {
        return;
      }

      setState(() {
        selectedImage = File(picked.path);
      });
    } catch (e) {
      debugPrint('IMAGE PICK ERROR: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to select image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ============================================================
  // TEXT FIELD
  // ============================================================

  Widget buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboard = TextInputType.text,
    int maxLines = 1,
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        enabled: enabled && !isLoading,
        keyboardType: keyboard,
        maxLines: maxLines,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Enter $label';
          }

          return null;
        },
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.green),
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.green, width: 2),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // UNIT DROPDOWN
  // ============================================================

  Widget buildUnitDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        initialValue: selectedUnit,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.straighten, color: Colors.green),
          labelText: 'Unit',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.green, width: 2),
          ),
        ),
        items: units.map((unit) {
          return DropdownMenuItem<String>(value: unit, child: Text(unit));
        }).toList(),
        onChanged: isLoading
            ? null
            : (value) {
                if (value == null) return;

                setState(() {
                  selectedUnit = value;
                });
              },
      ),
    );
  }

  // ============================================================
  // UPDATE PRODUCT
  // ============================================================

  Future<void> updateProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // ----------------------------------------------------------
    // PRICE VALIDATION
    // ----------------------------------------------------------

    final double? price = double.tryParse(priceController.text.trim());

    if (price == null || price < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid price'),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    // ----------------------------------------------------------
    // QUANTITY VALIDATION
    // ----------------------------------------------------------

    final double? quantity = double.tryParse(quantityController.text.trim());

    if (quantity == null || quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Quantity must be greater than 0'),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    // ----------------------------------------------------------
    // START UPDATE
    // ----------------------------------------------------------

    setState(() {
      isLoading = true;
    });

    try {
      final bool success = await api.updateProduct(
        id: widget.product.id,

        name: nameController.text.trim(),

        category: categoryController.text.trim(),

        price: priceController.text.trim(),

        quantity: quantityController.text.trim(),

        // FIX:
        // unit is required by MarketplaceApiService.
        unit: selectedUnit,

        // Seller is retained in the service signature for
        // compatibility, but the backend should use the
        // authenticated farmer.
        seller: widget.product.seller,

        location: locationController.text.trim(),

        description: descriptionController.text.trim(),

        image: selectedImage,
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product updated successfully.'),
            backgroundColor: Colors.green,
          ),
        );

        // Tell My Products screen to refresh.
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update product.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint('UPDATE PRODUCT ERROR: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Update error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
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
          'Edit Product',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),

      // ========================================================
      // BODY
      // ========================================================
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Form(
            key: _formKey,

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,

              children: [
                // ==================================================
                // IMAGE
                // ==================================================
                Center(
                  child: GestureDetector(
                    onTap: isLoading ? null : pickImage,

                    child: Container(
                      width: 180,
                      height: 180,

                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.green, width: 1.5),
                      ),

                      child: selectedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.file(
                                selectedImage!,
                                width: 180,
                                height: 180,
                                fit: BoxFit.cover,
                              ),
                            )
                          : widget.product.image.trim().isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.network(
                                widget.product.image,
                                width: 180,
                                height: 180,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return _imagePlaceholder();
                                },
                              ),
                            )
                          : _imagePlaceholder(),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Center(
                  child: TextButton.icon(
                    onPressed: isLoading ? null : pickImage,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Change Product Image'),
                  ),
                ),

                const SizedBox(height: 15),

                // ==================================================
                // PRODUCT NAME
                // ==================================================
                buildTextField(
                  label: 'Product Name',
                  controller: nameController,
                  icon: Icons.shopping_bag,
                ),

                // ==================================================
                // CATEGORY
                // ==================================================
                buildTextField(
                  label: 'Category',
                  controller: categoryController,
                  icon: Icons.category,
                ),

                // ==================================================
                // PRICE
                // ==================================================
                buildTextField(
                  label: 'Price',
                  controller: priceController,
                  icon: Icons.currency_rupee,
                  keyboard: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),

                // ==================================================
                // QUANTITY
                // ==================================================
                buildTextField(
                  label: 'Quantity',
                  controller: quantityController,
                  icon: Icons.scale,
                  keyboard: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),

                // ==================================================
                // UNIT
                // ==================================================
                buildUnitDropdown(),

                // ==================================================
                // SELLER INFORMATION
                // ==================================================
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(15),

                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.green.shade200),
                  ),

                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      const Icon(Icons.person, color: Colors.green),

                      const SizedBox(width: 10),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            const Text(
                              'Seller',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),

                            const SizedBox(height: 3),

                            Text(
                              widget.product.sellerName.isNotEmpty
                                  ? widget.product.sellerName
                                  : 'Current farmer',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            if (widget.product.seller.isNotEmpty)
                              const SizedBox(height: 3),

                            if (widget.product.seller.isNotEmpty)
                              Text(
                                'Seller ID: ${widget.product.seller}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ==================================================
                // LOCATION
                // ==================================================
                buildTextField(
                  label: 'Location',
                  controller: locationController,
                  icon: Icons.location_on,
                ),

                // ==================================================
                // DESCRIPTION
                // ==================================================
                buildTextField(
                  label: 'Description',
                  controller: descriptionController,
                  icon: Icons.description,
                  maxLines: 4,
                ),

                const SizedBox(height: 5),

                // ==================================================
                // APPROVAL INFORMATION
                // ==================================================
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),

                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.orange.shade200),
                  ),

                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      const Icon(Icons.info_outline, color: Colors.orange),

                      const SizedBox(width: 10),

                      Expanded(
                        child: Text(
                          widget.product.approvalStatus == 'approved'
                              ? 'Editing this product may require '
                                    'admin review again depending on '
                                    'your backend approval rules.'
                              : 'This product is currently '
                                    '${widget.product.approvalStatus}. '
                                    'After updating, it may need '
                                    'admin approval.',
                          style: const TextStyle(color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // ==================================================
                // UPDATE BUTTON
                // ==================================================
                SizedBox(
                  width: double.infinity,
                  height: 55,

                  child: ElevatedButton.icon(
                    onPressed: isLoading ? null : updateProduct,

                    icon: isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.save),

                    label: Text(
                      isLoading ? 'Updating...' : 'Update Product',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // IMAGE PLACEHOLDER
  // ============================================================

  Widget _imagePlaceholder() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_photo_alternate, size: 60, color: Colors.green),
          SizedBox(height: 8),
          Text(
            'Product Image',
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
