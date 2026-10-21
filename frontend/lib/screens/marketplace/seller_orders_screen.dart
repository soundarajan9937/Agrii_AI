import 'package:flutter/material.dart';

import 'seller_order_details.dart';

class SellerOrdersScreen extends StatelessWidget {
  const SellerOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Temporary data.
    // Later these orders will come from MongoDB.
    final List<Map<String, dynamic>> orders = [
      {
        "orderId": "AGR10001",
        "productName": "Rice",
        "buyerName": "Arun",
        "buyerPhone": "9876543210",
        "quantity": 2,
        "amount": 4400,
        "paymentMethod": "Cash on Delivery",
        "deliveryAddress": "Coimbatore",
        "status": "Order Placed",
        "sellerLocation": "Coimbatore",
        "latitude": 11.0168,
        "longitude": 76.9558,
      },
      {
        "orderId": "AGR10003",
        "productName": "Tomato",
        "buyerName": "Kumar",
        "buyerPhone": "9876543211",
        "quantity": 10,
        "amount": 1500,
        "paymentMethod": "UPI",
        "deliveryAddress": "Pollachi",
        "status": "Accepted",
        "sellerLocation": "Pollachi",
        "latitude": 10.6629,
        "longitude": 76.9018,
      },
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        title: const Text("Seller Orders"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),

      body: orders.isEmpty
          ? const Center(
              child: Text("No orders received", style: TextStyle(fontSize: 18)),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(15),

              itemCount: orders.length,

              itemBuilder: (context, index) {
                final order = orders[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 15),

                  child: Padding(
                    padding: const EdgeInsets.all(16),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Row(
                          children: [
                            const CircleAvatar(
                              backgroundColor: Color(0xFFE8F5E9),

                              child: Icon(
                                Icons.shopping_cart,
                                color: Colors.green,
                              ),
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: Text(
                                order["productName"],
                                style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            Text(
                              "₹${order["amount"]}",
                              style: const TextStyle(
                                color: Colors.green,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 15),

                        Text("Order ID: ${order["orderId"]}"),

                        const SizedBox(height: 6),

                        Text("Buyer: ${order["buyerName"]}"),

                        const SizedBox(height: 6),

                        Text("Quantity: ${order["quantity"]}"),

                        const SizedBox(height: 6),

                        Text("Payment: ${order["paymentMethod"]}"),

                        const SizedBox(height: 10),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),

                          decoration: BoxDecoration(
                            color: order["status"] == "Accepted"
                                ? Colors.green.shade50
                                : Colors.orange.shade50,

                            borderRadius: BorderRadius.circular(20),
                          ),

                          child: Text(
                            order["status"],
                            style: TextStyle(
                              color: order["status"] == "Accepted"
                                  ? Colors.green
                                  : Colors.orange,

                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(height: 15),

                        SizedBox(
                          width: double.infinity,

                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      SellerOrderDetails(order: order),
                                ),
                              );
                            },

                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),

                            child: const Text("View Order"),
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
