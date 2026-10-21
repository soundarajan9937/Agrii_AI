import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/agri_resource_service.dart';

class AddAgriResourceScreen extends StatefulWidget {
  const AddAgriResourceScreen({super.key});

  @override
  State<AddAgriResourceScreen> createState() => _AddAgriResourceScreenState();
}

class _AddAgriResourceScreenState extends State<AddAgriResourceScreen> {
  final _formKey = GlobalKey<FormState>();
  final AgriResourceService _service = AgriResourceService();
  final ImagePicker _picker = ImagePicker();

  String name = '';
  String? selectedCategory;
  double price = 0;
  String phoneNumber = '';
  String description = '';
  File? _image;
  bool isUploading = false;

  final List<String> categories = [
    'Crop Residues',
    'Vegetable Waste',
    'Fruit Waste',
    'Animal Waste',
    'Coconut Waste',
    'Sugarcane Waste',
    'Oilseed & Nut Waste',
    'Weed & Green Waste',
    'Agri-Processing Waste',
    'Other Organic Farm Waste',
    'Agri Tools & Equipment'
  ];

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.orange),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.orange, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.orangeAccent, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2.0),
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
        requestFullMetadata: false, // Prevents hanging on cloud images
      );
      if (picked != null) {
        setState(() => _image = File(picked.path));
      }
    } catch (e) {
      debugPrint("PICK IMAGE ERROR: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error selecting image: $e")),
      );
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _image == null) {
      if (_image == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select a photo")));
      }
      return;
    }
    _formKey.currentState!.save();

    setState(() => isUploading = true);

    final prefs = await SharedPreferences.getInstance();
    final sellerName = prefs.getString("name") ?? "Farmer";

    final success = await _service.addResource(
      name: name,
      category: selectedCategory!,
      sellerName: sellerName,
      price: price,
      phoneNumber: phoneNumber,
      image: _image!,
      description: description,
    );

    setState(() => isUploading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Resource uploaded successfully. Waiting for admin approval.")));
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Upload failed. Try again.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload Agri Resource"), backgroundColor: Colors.orange),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(15)),
                  child: _image == null
                      ? const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.camera_alt, size: 50), Text("Click to upload photo")])
                      : ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.file(_image!, fit: BoxFit.cover)),
                ),
              ),
              const SizedBox(height: 25),
              DropdownButtonFormField<String>(
                decoration: _inputDecoration("Select Category"),
                items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) => setState(() => selectedCategory = val),
                validator: (v) => v == null ? "Required" : null,
              ),
              const SizedBox(height: 18),
              TextFormField(
                decoration: _inputDecoration("Material Name"),
                onSaved: (v) => name = v!,
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 18),
              TextFormField(
                decoration: _inputDecoration("Price (₹)"),
                keyboardType: TextInputType.number,
                onSaved: (v) => price = double.parse(v!),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 18),
              TextFormField(
                decoration: _inputDecoration("Phone Number"),
                keyboardType: TextInputType.phone,
                onSaved: (v) => phoneNumber = v!,
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 18),
              TextFormField(
                decoration: _inputDecoration("Description (Optional)"),
                maxLines: 3,
                onSaved: (v) => description = v ?? '',
              ),
              const SizedBox(height: 30),
              isUploading
                  ? const CircularProgressIndicator(color: Colors.orange)
                  : SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        child: const Text("UPLOAD FOR APPROVAL", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
