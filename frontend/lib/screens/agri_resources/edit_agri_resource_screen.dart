import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/agri_resource_model.dart';
import '../../services/agri_resource_service.dart';
import '../../core/constants/api_constants.dart';

class EditAgriResourceScreen extends StatefulWidget {
  final AgriResourceModel resource;
  const EditAgriResourceScreen({super.key, required this.resource});

  @override
  State<EditAgriResourceScreen> createState() => _EditAgriResourceScreenState();
}

class _EditAgriResourceScreenState extends State<EditAgriResourceScreen> {
  final _formKey = GlobalKey<FormState>();
  final AgriResourceService _service = AgriResourceService();
  final ImagePicker _picker = ImagePicker();

  late String name;
  late String? selectedCategory;
  late double price;
  late String phoneNumber;
  late String description;
  File? _newImage;
  bool isUpdating = false;

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

  @override
  void initState() {
    super.initState();
    name = widget.resource.name;
    selectedCategory = widget.resource.category;
    price = widget.resource.price;
    phoneNumber = widget.resource.phoneNumber;
    description = widget.resource.description ?? '';
  }

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
    );
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _newImage = File(picked.path));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => isUpdating = true);

    final success = await _service.updateResource(
      id: widget.resource.id,
      name: name,
      category: selectedCategory!,
      price: price,
      phoneNumber: phoneNumber,
      image: _newImage,
      description: description,
    );

    setState(() => isUpdating = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Resource updated successfully. Pending re-approval.")));
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Update failed. Try again.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Agri Resource"), backgroundColor: Colors.orange),
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
                  child: _newImage != null
                      ? ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.file(_newImage!, fit: BoxFit.cover))
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.network(
                            "${ApiConstants.serverBaseUrl}/uploads/${widget.resource.image}",
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 50),
                          ),
                        ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text("Click image to change", style: TextStyle(color: Colors.grey, fontSize: 12)),
              ),
              const SizedBox(height: 25),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: _inputDecoration("Select Category"),
                items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) => setState(() => selectedCategory = val),
              ),
              const SizedBox(height: 18),
              TextFormField(
                initialValue: name,
                decoration: _inputDecoration("Material Name"),
                onSaved: (v) => name = v!,
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 18),
              TextFormField(
                initialValue: price.toString(),
                decoration: _inputDecoration("Price (₹)"),
                keyboardType: TextInputType.number,
                onSaved: (v) => price = double.parse(v!),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 18),
              TextFormField(
                initialValue: phoneNumber,
                decoration: _inputDecoration("Phone Number"),
                keyboardType: TextInputType.phone,
                onSaved: (v) => phoneNumber = v!,
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 18),
              TextFormField(
                initialValue: description,
                decoration: _inputDecoration("Description (Optional)"),
                maxLines: 3,
                onSaved: (v) => description = v ?? '',
              ),
              const SizedBox(height: 30),
              isUpdating
                  ? const CircularProgressIndicator(color: Colors.orange)
                  : SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        child: const Text("SAVE CHANGES", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
