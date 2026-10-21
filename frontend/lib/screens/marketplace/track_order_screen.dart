import 'package:flutter/material.dart';

import '../../core/constants/api_constants.dart';
import '../../services/order_api_service.dart';

class TrackOrderScreen extends StatefulWidget {
  final Map<String, dynamic> order;

  const TrackOrderScreen({super.key, required this.order});

  @override
  State<TrackOrderScreen> createState() => _TrackOrderScreenState();
}

class _TrackOrderScreenState extends State<TrackOrderScreen> {
  late String status;

  final OrderApiService _orderApiService = OrderApiService();

  @override
  void initState() {
    super.initState();

    status = widget.order["status"]?.toString() ?? "Pending";
  }

  // ============================================================
  // CANCEL ORDER
  // ============================================================

  Future<void> cancelOrder() async {
    final String currentStatus = status.toLowerCase();

    if (currentStatus == "delivered" ||
        currentStatus == "cancelled" ||
        currentStatus == "rejected") {
      return;
    }

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Cancel Order"),
          content: const Text("Are you sure you want to cancel this order?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text("No"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text("Yes, Cancel"),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    final dynamic orderId = widget.order["_id"];

    if (orderId == null || orderId.toString().isEmpty) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Order ID not found"),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    try {
      final success = await _orderApiService.cancelOrder(orderId.toString());

      if (!mounted) return;

      if (success) {
        setState(() {
          status = "Cancelled";
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Order cancelled successfully"),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to cancel order"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint("CANCEL ORDER ERROR: $e");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Cancel order error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    // ==========================================================
    // SELLER
    // ==========================================================

    final String sellerName =
        widget.order["sellerName"]?.toString() ??
        widget.order["seller"]?["name"]?.toString() ??
        widget.order["farmer"]?["name"]?.toString() ??
        "N/A";

    // ==========================================================
    // PRODUCT
    // ==========================================================

    final String productName =
        widget.order["productName"]?.toString() ??
        widget.order["product"]?["name"]?.toString() ??
        "N/A";

    // ==========================================================
    // AMOUNT
    // ==========================================================

    final dynamic amountValue =
        widget.order["totalAmount"] ?? widget.order["amount"] ?? 0;

    final double amount = double.tryParse(amountValue.toString()) ?? 0.0;

    // ==========================================================
    // PHONE
    // ==========================================================

    final String phone =
        widget.order["buyerPhone"]?.toString() ??
        widget.order["phone"]?.toString() ??
        "N/A";

    // ==========================================================
    // ADDRESS
    // ==========================================================

    final String address = widget.order["deliveryAddress"]?.toString() ?? "N/A";

    // ==========================================================
    // QUANTITY
    // ==========================================================

    final String quantity =
        "${widget.order["quantity"] ?? 0} "
        "${widget.order["unit"] ?? ""}";

    // ==========================================================
    // IMAGE
    // ==========================================================

    final String rawImageUrl =
        widget.order["productImage"]?.toString() ??
        widget.order["product"]?["image"]?.toString() ??
        "";

    final String imageUrl = _buildImageUrl(rawImageUrl);

    // ==========================================================
    // CURRENT STATUS
    // ==========================================================

    final String currentStatus = status.toLowerCase();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F7FD),

      // ========================================================
      // APP BAR
      // ========================================================
      appBar: AppBar(
        title: const Text("Track Order"),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),

      // ========================================================
      // BODY
      // ========================================================
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==================================================
            // DELIVERY STATUS
            // ==================================================
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 25,
                  horizontal: 20,
                ),
                child: Column(
                  children: [
                    const Text(
                      "Delivery Status",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 25),

                    _buildFlipkartTimeline(currentStatus),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 15),

            // ==================================================
            // ORDER INFORMATION
            // ==================================================
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ==========================================
                    // PRODUCT IMAGE + NAME + AMOUNT
                    // ==========================================
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 90,
                          height: 90,

                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF1976D2,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),

                          clipBehavior: Clip.antiAlias,

                          child: imageUrl.isNotEmpty
                              ? Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,

                                  errorBuilder: (context, error, stackTrace) {
                                    debugPrint("PRODUCT IMAGE ERROR: $error");

                                    return const Icon(
                                      Icons.inventory_2,
                                      color: Color(0xFF1976D2),
                                      size: 45,
                                    );
                                  },

                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        }

                                        return const Center(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Color(0xFF1976D2),
                                          ),
                                        );
                                      },
                                )
                              : const Icon(
                                  Icons.inventory_2,
                                  color: Color(0xFF1976D2),
                                  size: 45,
                                ),
                        ),

                        const SizedBox(width: 15),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                productName,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),

                              const SizedBox(height: 5),

                              Text(
                                "Amount: ₹${amount.toStringAsFixed(0)}",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1976D2),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const Divider(height: 35),

                    // ==========================================
                    // ORDER DETAILS
                    // ==========================================
                    const Text(
                      "Order Details",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),

                    detailRow(Icons.person, "Seller", sellerName),

                    detailRow(Icons.phone, "Phone", phone),

                    detailRow(Icons.location_on, "Address", address),

                    detailRow(Icons.scale, "Quantity", quantity),

                    detailRow(
                      Icons.receipt_long,
                      "Order ID",
                      widget.order["_id"],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ==================================================
            // CANCEL BUTTON
            // ==================================================
            if (currentStatus != "delivered" &&
                currentStatus != "cancelled" &&
                currentStatus != "rejected")
              SizedBox(
                width: double.infinity,
                height: 55,

                child: OutlinedButton.icon(
                  onPressed: cancelOrder,

                  icon: const Icon(Icons.cancel, color: Colors.red),

                  label: const Text(
                    "Cancel Order",
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // BUILD IMAGE URL
  // ============================================================

  String _buildImageUrl(String image) {
    final String value = image.trim();

    if (value.isEmpty) {
      return "";
    }

    // Backend already returned a complete URL.
    if (value.startsWith("http://") || value.startsWith("https://")) {
      return value;
    }

    // Backend returned only the image filename.
    return "${ApiConstants.imageBaseUrl}$value";
  }

  // ============================================================
  // FLIPKART STYLE TIMELINE
  // ============================================================

  Widget _buildFlipkartTimeline(String currentStatus) {
    final List<Map<String, String>> stages = [
      {"id": "pending", "label": "Ordered"},
      {"id": "accepted", "label": "Packed"},
      {"id": "processing", "label": "Shipped"},
      {"id": "delivered", "label": "Delivered"},
    ];

    // ==========================================================
    // CANCELLED / REJECTED
    // ==========================================================

    if (currentStatus == "cancelled" || currentStatus == "rejected") {
      return Center(
        child: Column(
          children: [
            const Icon(Icons.cancel, color: Colors.red, size: 50),

            const SizedBox(height: 10),

            Text(
              "Order ${currentStatus.toUpperCase()}",
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      );
    }

    // ==========================================================
    // ACTIVE STAGE
    // ==========================================================

    int activeIndex = 0;

    if (currentStatus == "accepted") {
      activeIndex = 1;
    }

    if (currentStatus == "processing" ||
        currentStatus == "shipped" ||
        currentStatus == "out_for_delivery") {
      activeIndex = 2;
    }

    if (currentStatus == "delivered") {
      activeIndex = 3;
    }

    // ==========================================================
    // TIMELINE
    // ==========================================================

    return Column(
      children: List.generate(stages.length, (index) {
        final bool isCompleted = index <= activeIndex;

        final bool isLast = index == stages.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================================================
            // CIRCLE + LINE
            // ================================================
            Column(
              children: [
                Container(
                  width: 24,
                  height: 24,

                  decoration: BoxDecoration(
                    color: isCompleted
                        ? const Color(0xFF1976D2)
                        : Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),

                  child: isCompleted
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),

                if (!isLast)
                  Container(
                    width: 2,
                    height: 50,
                    color: isCompleted
                        ? const Color(0xFF1976D2)
                        : Colors.grey.shade300,
                  ),
              ],
            ),

            const SizedBox(width: 20),

            // ================================================
            // STAGE TEXT
            // ================================================
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stages[index]["label"]!,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isCompleted ? Colors.black : Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    isCompleted ? "Status updated" : "Awaiting update",
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  // ============================================================
  // DETAIL ROW
  // ============================================================

  Widget detailRow(IconData icon, String title, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF1976D2)),

          const SizedBox(width: 12),

          SizedBox(
            width: 80,
            child: Text(
              "$title:",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
          ),

          Expanded(
            child: Text(
              value?.toString() ?? "N/A",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
