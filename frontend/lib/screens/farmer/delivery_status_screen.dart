import 'package:flutter/material.dart';

class DeliveryStatusScreen extends StatelessWidget {
  const DeliveryStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF7F2),

      // ==========================================
      // APP BAR
      // ==========================================
      appBar: AppBar(
        title: const Text(
          'Delivery Status',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),

      // ==========================================
      // DELIVERY LIST
      // ==========================================
      body: ListView(
        padding: const EdgeInsets.all(16),

        children: [
          _deliveryCard(
            context,
            orderId: '#ORD1001',
            product: 'Rice - 50 Kg',
            customer: 'Customer 1',
            location: 'Coimbatore',
            status: 'Out for Delivery',
            statusColor: Colors.deepOrange,
            progress: 0.75,
          ),

          _deliveryCard(
            context,
            orderId: '#ORD1002',
            product: 'Tomato - 20 Kg',
            customer: 'Customer 2',
            location: 'Pollachi',
            status: 'Processing',
            statusColor: Colors.blue,
            progress: 0.40,
          ),

          _deliveryCard(
            context,
            orderId: '#ORD1003',
            product: 'Mango - 30 Kg',
            customer: 'Customer 3',
            location: 'Coimbatore',
            status: 'Delivered',
            statusColor: Colors.green,
            progress: 1.0,
          ),

          _deliveryCard(
            context,
            orderId: '#ORD1004',
            product: 'Coconut - 50 Nos',
            customer: 'Customer 4',
            location: 'Tiruppur',
            status: 'Accepted',
            statusColor: Colors.purple,
            progress: 0.25,
          ),
        ],
      ),
    );
  }

  // ==========================================
  // DELIVERY CARD
  // ==========================================

  static Widget _deliveryCard(
    BuildContext context, {
    required String orderId,
    required String product,
    required String customer,
    required String location,
    required String status,
    required Color statusColor,
    required double progress,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 2,

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =====================================
            // ORDER HEADER
            // =====================================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  orderId,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),

                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            // =====================================
            // PRODUCT
            // =====================================
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0xFFFFF3E0),

                  child: Icon(Icons.agriculture, color: Colors.orange),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        'Buyer: $customer',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // =====================================
            // LOCATION
            // =====================================
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.red, size: 20),

                const SizedBox(width: 6),

                Expanded(
                  child: Text(
                    location,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            // =====================================
            // PROGRESS
            // =====================================
            LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              borderRadius: BorderRadius.circular(10),
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
            ),

            const SizedBox(height: 8),

            // Progress percentage
            Text(
              '${(progress * 100).toInt()}% completed',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),

            const SizedBox(height: 15),

            // =====================================
            // TRACK BUTTON
            // =====================================
            SizedBox(
              width: double.infinity,

              child: OutlinedButton.icon(
                onPressed: () {
                  _showTrackingMessage(context, orderId, location);
                },

                icon: const Icon(Icons.location_on),

                label: const Text('Track Delivery'),

                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.orange,
                  side: const BorderSide(color: Colors.orange),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TRACK MESSAGE
  // ==========================================

  static void _showTrackingMessage(
    BuildContext context,
    String orderId,
    String location,
  ) {
    showDialog(
      context: context,

      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.location_on, color: Colors.orange),

              SizedBox(width: 8),

              Text('Track Delivery'),
            ],
          ),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Text(
                'Order: $orderId',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              Text('Current Location: $location'),

              const SizedBox(height: 15),

              const Text(
                'Live tracking will be connected to the tracking service later.',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },

              child: const Text('Close', style: TextStyle(color: Colors.orange)),
            ),
          ],
        );
      },
    );
  }
}
