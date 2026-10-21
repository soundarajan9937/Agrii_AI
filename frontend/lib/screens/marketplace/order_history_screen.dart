import 'package:flutter/material.dart';

import 'track_order_screen.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Temporary data.
    // Later this will come from MongoDB through OrderService.
    final List<Map<String, dynamic>> orders = [
      {
        "orderId": "AGR10001",
        "productName": "Rice",
        "seller": "Soundar",
        "sellerLocation": "Coimbatore",
        "quantity": 2,
        "amount": 4400,
        "paymentMethod": "Cash on Delivery",
        "deliveryAddress": "Coimbatore",
        "phone": "9876543210",
        "status": "Accepted",
        "latitude": 11.0168,
        "longitude": 76.9558,
      },
      {
        "orderId": "AGR10002",
        "productName": "Tomato",
        "seller": "Ravi Farm",
        "sellerLocation": "Pollachi",
        "quantity": 5,
        "amount": 750,
        "paymentMethod": "UPI",
        "deliveryAddress": "Coimbatore",
        "phone": "9876543210",
        "status": "Delivered",
        "latitude": 10.6629,
        "longitude": 76.9018,
      },
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        title: const Text("My Orders"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),

      body: orders.isEmpty
          ? const Center(
              child: Text("No orders yet", style: TextStyle(fontSize: 18)),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(15),

              itemCount: orders.length,

              itemBuilder: (context, index) {
                final order = orders[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 15),

                  child: Padding(
                    padding: const EdgeInsets.all(15),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Row(
                          children: [
                            const Icon(Icons.shopping_bag, color: Colors.green),

                            const SizedBox(width: 10),

                            Expanded(
                              child: Text(
                                order["productName"],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            Text(
                              "₹${order["amount"]}",
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        Text("Order ID: ${order["orderId"]}"),

                        const SizedBox(height: 5),

                        Text("Seller: ${order["seller"]}"),

                        const SizedBox(height: 5),

                        Text("Quantity: ${order["quantity"]}"),

                        const SizedBox(height: 10),

                        Row(
                          children: [
                            const Text(
                              "Status: ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),

                            Text(
                              order["status"],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: order["status"] == "Delivered"
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 15),

                        SizedBox(
                          width: double.infinity,

                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      TrackOrderScreen(order: order),
                                ),
                              );
                            },

                            icon: const Icon(Icons.location_on),

                            label: const Text("Track Order"),

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
              },
            ),
    );
  }
}
