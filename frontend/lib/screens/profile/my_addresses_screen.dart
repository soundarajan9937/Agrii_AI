import 'package:flutter/material.dart';

class MyAddressesScreen extends StatefulWidget {
  const MyAddressesScreen({super.key});

  @override
  State<MyAddressesScreen> createState() => _MyAddressesScreenState();
}

class _MyAddressesScreenState extends State<MyAddressesScreen> {
  final List<Map<String, dynamic>> addresses = [
    {
      "id": "1",
      "type": "Home",
      "name": "Soundarajan",
      "phone": "9876543210",
      "address": "123, Main Road",
      "city": "Coimbatore",
      "state": "Tamil Nadu",
      "pincode": "641001",
      "isDefault": true,
    },
  ];

  // ==========================================
  // ADD / EDIT ADDRESS
  // ==========================================

  void showAddressDialog({Map<String, dynamic>? existingAddress}) {
    final nameController = TextEditingController(
      text: existingAddress?["name"] ?? "",
    );

    final phoneController = TextEditingController(
      text: existingAddress?["phone"] ?? "",
    );

    final addressController = TextEditingController(
      text: existingAddress?["address"] ?? "",
    );

    final cityController = TextEditingController(
      text: existingAddress?["city"] ?? "",
    );

    final stateController = TextEditingController(
      text: existingAddress?["state"] ?? "",
    );

    final pincodeController = TextEditingController(
      text: existingAddress?["pincode"] ?? "",
    );

    String selectedType = existingAddress?["type"] ?? "Home";

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                existingAddress == null ? "Add Address" : "Edit Address",
              ),

              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Address Type
                    DropdownButtonFormField<String>(
                      initialValue: selectedType,
                      decoration: const InputDecoration(
                        labelText: "Address Type",
                        prefixIcon: Icon(Icons.home),
                      ),
                      items: const [
                        DropdownMenuItem(value: "Home", child: Text("Home")),
                        DropdownMenuItem(value: "Work", child: Text("Work")),
                        DropdownMenuItem(value: "Other", child: Text("Other")),
                      ],
                      onChanged: (value) {
                        setDialogState(() {
                          selectedType = value!;
                        });
                      },
                    ),

                    const SizedBox(height: 12),

                    _textField(nameController, "Full Name", Icons.person),

                    _textField(phoneController, "Phone Number", Icons.phone),

                    _textField(addressController, "Address", Icons.location_on),

                    _textField(cityController, "City", Icons.location_city),

                    _textField(stateController, "State", Icons.map),

                    _textField(pincodeController, "Pincode", Icons.pin_drop),
                  ],
                ),
              ),

              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel"),
                ),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    if (nameController.text.trim().isEmpty ||
                        phoneController.text.trim().isEmpty ||
                        addressController.text.trim().isEmpty ||
                        cityController.text.trim().isEmpty ||
                        stateController.text.trim().isEmpty ||
                        pincodeController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please fill all fields")),
                      );
                      return;
                    }

                    setState(() {
                      if (existingAddress == null) {
                        addresses.add({
                          "id": DateTime.now().millisecondsSinceEpoch
                              .toString(),
                          "type": selectedType,
                          "name": nameController.text.trim(),
                          "phone": phoneController.text.trim(),
                          "address": addressController.text.trim(),
                          "city": cityController.text.trim(),
                          "state": stateController.text.trim(),
                          "pincode": pincodeController.text.trim(),
                          "isDefault": addresses.isEmpty,
                        });
                      } else {
                        existingAddress["type"] = selectedType;
                        existingAddress["name"] = nameController.text.trim();
                        existingAddress["phone"] = phoneController.text.trim();
                        existingAddress["address"] = addressController.text
                            .trim();
                        existingAddress["city"] = cityController.text.trim();
                        existingAddress["state"] = stateController.text.trim();
                        existingAddress["pincode"] = pincodeController.text
                            .trim();
                      }
                    });

                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          existingAddress == null
                              ? "Address added successfully"
                              : "Address updated successfully",
                        ),
                      ),
                    );
                  },
                  child: Text(
                    existingAddress == null ? "Add Address" : "Update",
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ==========================================
  // DELETE ADDRESS
  // ==========================================

  void deleteAddress(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Address"),
          content: const Text("Are you sure you want to delete this address?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  addresses.removeAt(index);
                });

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Address deleted")),
                );
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  // ==========================================
  // SET DEFAULT
  // ==========================================

  void setDefaultAddress(int index) {
    setState(() {
      for (int i = 0; i < addresses.length; i++) {
        addresses[i]["isDefault"] = i == index;
      }
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Default address updated")));
  }

  // ==========================================
  // TEXT FIELD
  // ==========================================

  static Widget _textField(
    TextEditingController controller,
    String label,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  // ==========================================
  // BUILD
  // ==========================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F2),

      appBar: AppBar(
        title: const Text(
          "My Addresses",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),

      body: addresses.isEmpty
          ? _emptyAddressView()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: addresses.length,
              itemBuilder: (context, index) {
                return _addressCard(addresses[index], index);
              },
            ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        onPressed: () {
          showAddressDialog();
        },
        icon: const Icon(Icons.add),
        label: const Text("Add Address"),
      ),
    );
  }

  // ==========================================
  // ADDRESS CARD
  // ==========================================

  Widget _addressCard(Map<String, dynamic> address, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.green.shade100,
                  child: Icon(
                    address["type"] == "Home"
                        ? Icons.home
                        : address["type"] == "Work"
                        ? Icons.work
                        : Icons.location_on,
                    color: Colors.green,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    address["type"],
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                if (address["isDefault"] == true)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "Default",
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),

            const Divider(height: 25),

            Text(
              address["name"],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 5),

            Text(address["phone"]),

            const SizedBox(height: 8),

            Text(
              "${address["address"]}, "
              "${address["city"]}, "
              "${address["state"]} - "
              "${address["pincode"]}",
              style: const TextStyle(color: Colors.black87),
            ),

            const SizedBox(height: 15),

            Row(
              children: [
                if (address["isDefault"] != true)
                  TextButton.icon(
                    onPressed: () {
                      setDefaultAddress(index);
                    },
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: const Text("Set Default"),
                  ),

                const Spacer(),

                IconButton(
                  tooltip: "Edit",
                  onPressed: () {
                    showAddressDialog(existingAddress: address);
                  },
                  icon: const Icon(Icons.edit, color: Colors.blue),
                ),

                IconButton(
                  tooltip: "Delete",
                  onPressed: () {
                    deleteAddress(index);
                  },
                  icon: const Icon(Icons.delete, color: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyAddressView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off, size: 70, color: Colors.grey.shade400),

          const SizedBox(height: 15),

          const Text(
            "No addresses saved",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          const Text(
            "Add an address for faster checkout",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
