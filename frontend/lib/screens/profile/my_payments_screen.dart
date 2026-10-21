import 'package:flutter/material.dart';

class MyPaymentsScreen extends StatefulWidget {
  const MyPaymentsScreen({super.key});

  @override
  State<MyPaymentsScreen> createState() => _MyPaymentsScreenState();
}

class _MyPaymentsScreenState extends State<MyPaymentsScreen> {
  final List<Map<String, dynamic>> paymentMethods = [
    {
      "id": "1",
      "type": "UPI",
      "name": "Google Pay",
      "details": "soundar@upi",
      "isDefault": true,
    },
    {
      "id": "2",
      "type": "Card",
      "name": "Debit Card",
      "details": "**** **** **** 4582",
      "isDefault": false,
    },
  ];

  // ==========================================
  // ADD PAYMENT
  // ==========================================

  void showAddPaymentDialog() {
    String selectedType = "UPI";

    final nameController = TextEditingController();
    final detailsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Add Payment Method"),

              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: selectedType,
                      decoration: const InputDecoration(
                        labelText: "Payment Type",
                        prefixIcon: Icon(Icons.payment),
                      ),
                      items: const [
                        DropdownMenuItem(value: "UPI", child: Text("UPI")),
                        DropdownMenuItem(
                          value: "Card",
                          child: Text("Debit / Credit Card"),
                        ),
                      ],
                      onChanged: (value) {
                        setDialogState(() {
                          selectedType = value!;
                        });
                      },
                    ),

                    const SizedBox(height: 15),

                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: selectedType == "UPI"
                            ? "UPI App / Name"
                            : "Card Holder Name",
                        prefixIcon: const Icon(Icons.person),
                        border: const OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 12),

                    TextField(
                      controller: detailsController,
                      decoration: InputDecoration(
                        labelText: selectedType == "UPI"
                            ? "UPI ID"
                            : "Card Number",
                        prefixIcon: Icon(
                          selectedType == "UPI"
                              ? Icons.account_balance_wallet
                              : Icons.credit_card,
                        ),
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: selectedType == "UPI"
                          ? TextInputType.text
                          : TextInputType.number,
                    ),
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
                        detailsController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please fill all fields")),
                      );
                      return;
                    }

                    setState(() {
                      paymentMethods.add({
                        "id": DateTime.now().millisecondsSinceEpoch.toString(),
                        "type": selectedType,
                        "name": nameController.text.trim(),
                        "details": detailsController.text.trim(),
                        "isDefault": paymentMethods.isEmpty,
                      });
                    });

                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Payment method added")),
                    );
                  },
                  child: const Text("Add"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ==========================================
  // DELETE PAYMENT
  // ==========================================

  void deletePayment(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Payment Method"),

          content: const Text(
            "Are you sure you want to remove this payment method?",
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
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  paymentMethods.removeAt(index);
                });

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Payment method removed")),
                );
              },
              child: const Text("Remove"),
            ),
          ],
        );
      },
    );
  }

  // ==========================================
  // SET DEFAULT
  // ==========================================

  void setDefaultPayment(int index) {
    setState(() {
      for (int i = 0; i < paymentMethods.length; i++) {
        paymentMethods[i]["isDefault"] = i == index;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Default payment method updated")),
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
          "My Payments",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==================================
            // SECURITY MESSAGE
            // ==================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lock, color: Colors.green),

                  SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      "Your payment information is securely handled.",
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Saved Payment Methods",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            if (paymentMethods.isEmpty)
              _emptyPaymentView()
            else
              ...List.generate(paymentMethods.length, (index) {
                return _paymentCard(paymentMethods[index], index);
              }),

            const SizedBox(height: 20),

            // ==================================
            // CASH ON DELIVERY
            // ==================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: const Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Color(0xFFFFE5C2),
                    child: Icon(Icons.payments, color: Colors.orange),
                  ),

                  SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Cash on Delivery",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),

                        SizedBox(height: 5),

                        Text(
                          "Pay the farmer when your order is delivered.",
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        onPressed: showAddPaymentDialog,
        icon: const Icon(Icons.add),
        label: const Text("Add Payment"),
      ),
    );
  }

  // ==========================================
  // PAYMENT CARD
  // ==========================================

  Widget _paymentCard(Map<String, dynamic> payment, int index) {
    final bool isUpi = payment["type"] == "UPI";

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: isUpi
                      ? Colors.purple.shade100
                      : Colors.blue.shade100,
                  child: Icon(
                    isUpi ? Icons.account_balance_wallet : Icons.credit_card,
                    color: isUpi ? Colors.purple : Colors.blue,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        payment["name"],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        payment["details"],
                        style: const TextStyle(color: Colors.grey),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        payment["type"],
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                if (payment["isDefault"] == true)
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

            const SizedBox(height: 10),

            Row(
              children: [
                if (payment["isDefault"] != true)
                  TextButton.icon(
                    onPressed: () {
                      setDefaultPayment(index);
                    },
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: const Text("Set Default"),
                  ),

                const Spacer(),

                IconButton(
                  tooltip: "Delete",
                  onPressed: () {
                    deletePayment(index);
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

  Widget _emptyPaymentView() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      child: const Column(
        children: [
          Icon(Icons.payment, size: 60, color: Colors.grey),

          SizedBox(height: 12),

          Text(
            "No saved payment methods",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),

          SizedBox(height: 5),

          Text(
            "Add a payment method for faster checkout.",
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
