import 'package:flutter/material.dart';

class SellerOrderDetails extends StatefulWidget {
  final Map<String, dynamic> order;

  const SellerOrderDetails({super.key, required this.order});

  @override
  State<SellerOrderDetails> createState() => _SellerOrderDetailsState();
}

class _SellerOrderDetailsState extends State<SellerOrderDetails> {
  late String status;

  @override
  void initState() {
    super.initState();

    status = widget.order["status"] ?? "Order Placed";
  }

  void updateStatus(String newStatus) {
    setState(() {
      status = newStatus;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Order status updated to $newStatus"),
        backgroundColor: Colors.green,
      ),
    );
  }

  void rejectOrder() {
    showDialog(
      context: context,

      builder: (context) {
        return AlertDialog(
          title: const Text("Reject Order"),

          content: const Text("Are you sure you want to reject this order?"),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },

              child: const Text("No"),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);

                updateStatus("Rejected");
              },

              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),

              child: const Text("Reject"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        title: const Text("Order Details"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),

                child: Column(
                  children: [
                    const Icon(
                      Icons.shopping_bag,
                      size: 65,
                      color: Colors.green,
                    ),

                    const SizedBox(height: 10),

                    Text(
                      widget.order["productName"] ?? "",
                      style: const TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text("Order ID: ${widget.order["orderId"]}"),

                    const SizedBox(height: 10),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 8,
                      ),

                      decoration: BoxDecoration(
                        color: status == "Rejected"
                            ? Colors.red.shade50
                            : Colors.green.shade50,

                        borderRadius: BorderRadius.circular(20),
                      ),

                      child: Text(
                        status,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: status == "Rejected"
                              ? Colors.red
                              : Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 15),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    const Text(
                      "Buyer Information",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),

                    detailRow("Name", widget.order["buyerName"]),

                    detailRow("Phone", widget.order["buyerPhone"]),

                    detailRow("Address", widget.order["deliveryAddress"]),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 15),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    const Text(
                      "Order Information",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),

                    detailRow("Product", widget.order["productName"]),

                    detailRow("Quantity", "${widget.order["quantity"]}"),

                    detailRow("Amount", "₹${widget.order["amount"]}"),

                    detailRow("Payment", widget.order["paymentMethod"]),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            if (status == "Order Placed") ...[
              SizedBox(
                width: double.infinity,
                height: 52,

                child: ElevatedButton.icon(
                  onPressed: () {
                    updateStatus("Accepted");
                  },

                  icon: const Icon(Icons.check),

                  label: const Text(
                    "Accept Order",
                    style: TextStyle(fontSize: 17),
                  ),

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 52,

                child: OutlinedButton.icon(
                  onPressed: rejectOrder,

                  icon: const Icon(Icons.close, color: Colors.red),

                  label: const Text(
                    "Reject Order",
                    style: TextStyle(color: Colors.red, fontSize: 17),
                  ),

                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
            ],

            if (status == "Accepted") ...[
              SizedBox(
                width: double.infinity,
                height: 52,

                child: ElevatedButton.icon(
                  onPressed: () {
                    updateStatus("Shipped");
                  },

                  icon: const Icon(Icons.local_shipping),

                  label: const Text("Mark as Shipped"),

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],

            if (status == "Shipped") ...[
              SizedBox(
                width: double.infinity,
                height: 52,

                child: ElevatedButton.icon(
                  onPressed: () {
                    updateStatus("Out for Delivery");
                  },

                  icon: const Icon(Icons.delivery_dining),

                  label: const Text("Out for Delivery"),

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],

            if (status == "Out for Delivery") ...[
              SizedBox(
                width: double.infinity,
                height: 52,

                child: ElevatedButton.icon(
                  onPressed: () {
                    updateStatus("Delivered");
                  },

                  icon: const Icon(Icons.done_all),

                  label: const Text("Mark as Delivered"),

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],

            if (status == "Accepted" ||
                status == "Shipped" ||
                status == "Out for Delivery") ...[
              const SizedBox(height: 15),

              Card(
                color: Colors.blue.shade50,

                child: const Padding(
                  padding: EdgeInsets.all(15),

                  child: Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.blue),

                      SizedBox(width: 10),

                      Expanded(
                        child: Text(
                          "Order location can be updated here. Later we will connect GPS and Google Maps.",
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget detailRow(String title, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          SizedBox(
            width: 120,

            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

          Expanded(child: Text(value?.toString() ?? "")),
        ],
      ),
    );
  }
}
