import 'package:flutter/material.dart';

class FarmerProfile extends StatefulWidget {
  const FarmerProfile({super.key});

  @override
  State<FarmerProfile> createState() => _FarmerProfileState();
}

class _FarmerProfileState extends State<FarmerProfile> {
  final TextEditingController nameController = TextEditingController(
    text: 'Soundar',
  );

  final TextEditingController emailController = TextEditingController(
    text: 'farmer@gmail.com',
  );

  final TextEditingController phoneController = TextEditingController(
    text: '9876543210',
  );

  final TextEditingController locationController = TextEditingController(
    text: 'Coimbatore',
  );

  final TextEditingController farmController = TextEditingController(
    text: '5 Acres',
  );

  bool isEditing = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    locationController.dispose();
    farmController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF7F2),

      // ==========================================
      // APP BAR
      // ==========================================
      appBar: AppBar(
        title: const Text(
          'Farmer Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,

        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.save : Icons.edit),
            tooltip: isEditing ? 'Save' : 'Edit',
            onPressed: () {
              setState(() {
                isEditing = !isEditing;
              });

              if (!isEditing) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profile updated successfully'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
          ),
        ],
      ),

      // ==========================================
      // BODY
      // ==========================================
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            // =====================================
            // PROFILE IMAGE
            // =====================================
            const CircleAvatar(
              radius: 55,
              backgroundColor: Color(0xFFFFF3E0),
              child: Icon(Icons.person, size: 65, color: Colors.orange),
            ),

            const SizedBox(height: 12),

            const Text(
              'Farmer / Seller',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),

            const SizedBox(height: 25),

            // =====================================
            // PROFILE FIELDS
            // =====================================
            _field(
              controller: nameController,
              label: 'Name',
              icon: Icons.person,
            ),

            _field(
              controller: emailController,
              label: 'Email',
              icon: Icons.email,
            ),

            _field(
              controller: phoneController,
              label: 'Phone',
              icon: Icons.phone,
            ),

            _field(
              controller: locationController,
              label: 'Farm Location',
              icon: Icons.location_on,
            ),

            _field(
              controller: farmController,
              label: 'Farm Size',
              icon: Icons.agriculture,
            ),

            const SizedBox(height: 20),

            // =====================================
            // SELLER INFORMATION
            // =====================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),

              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    'Seller Information',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),

                  SizedBox(height: 15),

                  Row(
                    children: [
                      Icon(Icons.inventory_2, color: Colors.orange, size: 20),
                      SizedBox(width: 10),
                      Text('Products Sold: 8'),
                    ],
                  ),

                  SizedBox(height: 12),

                  Row(
                    children: [
                      Icon(Icons.shopping_bag, color: Colors.orange, size: 20),
                      SizedBox(width: 10),
                      Text('Orders Received: 12'),
                    ],
                  ),

                  SizedBox(height: 12),

                  Row(
                    children: [
                      Icon(Icons.local_shipping, color: Colors.orange, size: 20),
                      SizedBox(width: 10),
                      Text('Successful Deliveries: 9'),
                    ],
                  ),

                  SizedBox(height: 12),

                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 20),
                      SizedBox(width: 10),
                      Text('Rating: 4.7'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // =====================================
            // EDIT INFORMATION
            // =====================================
            if (!isEditing)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),

                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(14),
                ),

                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange),

                    SizedBox(width: 10),

                    Expanded(
                      child: Text(
                        'Tap the edit icon above to update your profile.',
                        style: TextStyle(color: Colors.black87, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // PROFILE FIELD
  // ==========================================

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),

      child: TextField(
        controller: controller,
        enabled: isEditing,

        decoration: InputDecoration(
          labelText: label,

          prefixIcon: Icon(icon, color: Colors.orange),

          filled: true,

          fillColor: Colors.white,

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.orange, width: 1.5),
          ),

          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
