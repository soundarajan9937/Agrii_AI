import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/auth_service.dart';
import '../../services/marketplace_api_service.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController nameController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  // ============================================================
  // SERVICES
  // ============================================================

  final MarketplaceApiService apiService = MarketplaceApiService();
  final ImagePicker picker = ImagePicker();

  // ============================================================
  // VARIABLES
  // ============================================================

  File? selectedImage;
  bool isUploading = false;

  // Product unit
  String selectedUnit = "Kg";

  final List<String> units = [
    "Kg",
    "Gram",
    "Quintal",
    "Ton",
    "Litre",
    "Piece",
    "Dozen",
  ];

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

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (image != null && mounted) {
        setState(() {
          selectedImage = File(image.path);
        });
      }
    } catch (e) {
      debugPrint("IMAGE PICK ERROR: $e");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Image selection failed: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ============================================================
  // SHOW IMAGE PICKER
  // ============================================================

  void showImagePicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.green),
                title: const Text("Camera"),
                onTap: () {
                  Navigator.pop(context);
                  pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.blue),
                title: const Text("Gallery"),
                onTap: () {
                  Navigator.pop(context);
                  pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // SUBMIT PRODUCT
  // ============================================================

  Future<void> submitProduct() async {
    // ----------------------------------------------------------
    // VALIDATE FIELDS
    // ----------------------------------------------------------

    if (nameController.text.trim().isEmpty ||
        categoryController.text.trim().isEmpty ||
        priceController.text.trim().isEmpty ||
        quantityController.text.trim().isEmpty ||
        locationController.text.trim().isEmpty ||
        descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all product details"),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    // ----------------------------------------------------------
    // VALIDATE IMAGE
    // ----------------------------------------------------------

    if (selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a product image"),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    // ----------------------------------------------------------
    // VALIDATE PRICE
    // ----------------------------------------------------------

    final double? price = double.tryParse(priceController.text.trim());

    if (price == null || price < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a valid price"),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    // ----------------------------------------------------------
    // VALIDATE QUANTITY
    // ----------------------------------------------------------

    final double? quantity = double.tryParse(quantityController.text.trim());

    if (quantity == null || quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Quantity must be greater than 0"),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    // ----------------------------------------------------------
    // GET LOGGED-IN USER ID
    // ----------------------------------------------------------

    final String? userId = await AuthService.getUserId();

    if (userId == null || userId.isEmpty) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("User ID not found. Please logout and login again."),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    debugPrint("==========================================");
    debugPrint("LOGGED-IN USER ID");
    debugPrint(userId);
    debugPrint("SELECTED UNIT");
    debugPrint(selectedUnit);
    debugPrint("==========================================");

    // ----------------------------------------------------------
    // START UPLOAD
    // ----------------------------------------------------------

    if (!mounted) return;

    setState(() {
      isUploading = true;
    });

    try {
      final bool success = await apiService.addProduct(
        name: nameController.text.trim(),
        category: categoryController.text.trim(),
        price: priceController.text.trim(),
        quantity: quantityController.text.trim(),

        // IMPORTANT
        // Send selected unit.
        unit: selectedUnit,

        // Send MongoDB USER ID.
        seller: userId,

        location: locationController.text.trim(),
        description: descriptionController.text.trim(),

        // Product image.
        image: selectedImage,
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "✅ Product uploaded successfully!\n"
              "Waiting for admin approval.",
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Return true so My Products screen can refresh.
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "❌ Product upload failed.\n"
              "Check that your account is a farmer.",
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint("UPLOAD ERROR: $e");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Upload error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isUploading = false;
        });
      }
    }
  }

  // ============================================================
  // TEXT FIELD
  // ============================================================

  Widget buildField(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType keyboard = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        maxLines: maxLines,
        enabled: !isUploading,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.green),
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
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
      padding: const EdgeInsets.only(bottom: 18),
      child: DropdownButtonFormField<String>(
        initialValue: selectedUnit,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.straighten, color: Colors.green),
          labelText: "Unit",
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.green, width: 2),
          ),
        ),
        items: units.map((String unit) {
          return DropdownMenuItem<String>(value: unit, child: Text(unit));
        }).toList(),
        onChanged: isUploading
            ? null
            : (String? value) {
                if (value == null) return;

                setState(() {
                  selectedUnit = value;
                });
              },
      ),
    );
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
          "Sell Product",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),

      // ========================================================
      // BODY
      // ========================================================
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            // ==================================================
            // PRODUCT IMAGE
            // ==================================================
            GestureDetector(
              onTap: isUploading ? null : showImagePicker,

              child: Container(
                width: 180,
                height: 180,

                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green, width: 1.5),
                ),

                child: selectedImage == null
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate,
                            size: 65,
                            color: Colors.green,
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Add Product Image",
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.file(selectedImage!, fit: BoxFit.cover),
                      ),
              ),
            ),

            const SizedBox(height: 15),

            // ==================================================
            // CAMERA / GALLERY BUTTONS
            // ==================================================
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: isUploading
                      ? null
                      : () {
                          pickImage(ImageSource.camera);
                        },
                  icon: const Icon(Icons.camera_alt),
                  label: const Text("Camera"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),

                const SizedBox(width: 15),

                ElevatedButton.icon(
                  onPressed: isUploading
                      ? null
                      : () {
                          pickImage(ImageSource.gallery);
                        },
                  icon: const Icon(Icons.photo),
                  label: const Text("Gallery"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            // ==================================================
            // PRODUCT NAME
            // ==================================================
            buildField("Product Name", nameController, Icons.shopping_bag),

            // ==================================================
            // CATEGORY
            // ==================================================
            buildField("Category", categoryController, Icons.category),

            // ==================================================
            // PRICE
            // ==================================================
            buildField(
              "Price",
              priceController,
              Icons.currency_rupee,
              keyboard: TextInputType.number,
            ),

            // ==================================================
            // QUANTITY
            // ==================================================
            buildField(
              "Quantity",
              quantityController,
              Icons.scale,
              keyboard: const TextInputType.numberWithOptions(decimal: true),
            ),

            // ==================================================
            // UNIT
            // ==================================================
            buildUnitDropdown(),

            // ==================================================
            // LOCATION
            // ==================================================
            buildField("Location", locationController, Icons.location_on),

            // ==================================================
            // DESCRIPTION
            // ==================================================
            buildField(
              "Description",
              descriptionController,
              Icons.description,
              maxLines: 3,
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

              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: Colors.orange),

                  SizedBox(width: 10),

                  Expanded(
                    child: Text(
                      "After uploading, your product "
                      "will be reviewed by the admin. "
                      "It will appear in the Marketplace "
                      "only after admin approval.",
                      style: TextStyle(color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ==================================================
            // UPLOAD BUTTON
            // ==================================================
            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton.icon(
                onPressed: isUploading ? null : submitProduct,

                icon: isUploading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.cloud_upload),

                label: Text(
                  isUploading ? "Uploading..." : "Upload Product",
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

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
