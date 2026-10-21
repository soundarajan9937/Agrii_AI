import 'package:flutter/material.dart';

import '../../models/user_model.dart';
import '../../services/profile_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _farmController = TextEditingController();
  final _locationController = TextEditingController();
  final _sizeController = TextEditingController();
  final _cropController = TextEditingController();
  final _soilController = TextEditingController();

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final user = await ProfileService.getProfile();

    _nameController.text = user.name;
    _emailController.text = user.email;
    _phoneController.text = user.phone;
    _addressController.text = user.address;
    _farmController.text = user.farmName;
    _locationController.text = user.farmLocation;
    _sizeController.text = user.farmSize;
    _cropController.text = user.mainCrop;
    _soilController.text = user.soilType;

    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _farmController.dispose();
    _locationController.dispose();
    _sizeController.dispose();
    _cropController.dispose();
    _soilController.dispose();
    super.dispose();
  }

  Widget buildField(
    String title,
    TextEditingController controller,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.green),
          labelText: title,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),
    );
  }

  Future<void> saveProfile() async {
    final user = UserModel(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      farmName: _farmController.text.trim(),
      farmLocation: _locationController.text.trim(),
      farmSize: _sizeController.text.trim(),
      mainCrop: _cropController.text.trim(),
      soilType: _soilController.text.trim(),
      profileImage: "",
    );

    await ProfileService.saveUser(user);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Profile Updated Successfully"),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F2),
      appBar: AppBar(
        title: const Text("Edit Profile"),
        centerTitle: true,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            buildField("Full Name", _nameController, Icons.person),

            buildField("Email", _emailController, Icons.email),

            buildField("Phone Number", _phoneController, Icons.phone),

            buildField("Address", _addressController, Icons.location_on),

            buildField("Farm Name", _farmController, Icons.agriculture),

            buildField("Farm Location", _locationController, Icons.map),

            buildField("Farm Size", _sizeController, Icons.square_foot),

            buildField("Main Crop", _cropController, Icons.eco),

            buildField("Soil Type", _soilController, Icons.grass),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: saveProfile,
                icon: const Icon(Icons.save),
                label: const Text(
                  "Save Profile",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
