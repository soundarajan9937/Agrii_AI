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
      backgroundColor: const Color(0xFFF8FAFC),

      // ========================================================
      // APP BAR
      // ========================================================
      appBar: AppBar(
        title: const Text(
          "Track Order",
          style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.2),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF0F766E), // Deep Teal
                Color(0xFF059669), // Emerald
                Color(0xFF0284C7), // Sky Azure
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),

      // ========================================================
      // BODY
      // ========================================================
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==================================================
            // DELIVERY STATUS CARD
            // ==================================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.1),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                    blurRadius: 14,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.local_shipping_outlined, size: 18, color: Color(0xFF059669)),
                          SizedBox(width: 8),
                          Text(
                            "Delivery Progress",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFA7F3D0)),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFF059669),
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildFlipkartTimeline(currentStatus),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ==================================================
            // ORDER INFORMATION CARD
            // ==================================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.1),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                    blurRadius: 14,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // PRODUCT IMAGE + INFO ROW
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: imageUrl.isNotEmpty
                            ? Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => const Icon(
                                  Icons.eco_rounded,
                                  color: Color(0xFF059669),
                                  size: 38,
                                ),
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFF059669),
                                    ),
                                  );
                                },
                              )
                            : const Icon(
                                Icons.eco_rounded,
                                color: Color(0xFF059669),
                                size: 38,
                              ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              productName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                                letterSpacing: -0.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Amount: ₹${amount.toStringAsFixed(0)}",
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF059669),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              "Quantity: $quantity",
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(color: Color(0xFFE2E8F0)),
                  ),

                  // DETAILS SUBSECTION
                  Row(
                    children: const [
                      Icon(Icons.badge_outlined, size: 16, color: Color(0xFF059669)),
                      SizedBox(width: 8),
                      Text(
                        "Order Information",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  detailRow(Icons.person_outline_rounded, "Farmer / Seller", sellerName),
                  detailRow(Icons.phone_outlined, "Contact Phone", phone),
                  detailRow(Icons.location_on_outlined, "Delivery Address", address),
                  detailRow(Icons.scale_rounded, "Quantity Ordered", quantity),
                  detailRow(
                    Icons.receipt_long_rounded,
                    "Order ID",
                    widget.order["_id"] != null
                        ? widget.order["_id"].toString().length > 14
                            ? "${widget.order["_id"].toString().substring(0, 14)}..."
                            : widget.order["_id"].toString()
                        : "N/A",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ==================================================
            // CANCEL BUTTON
            // ==================================================
            if (currentStatus != "delivered" &&
                currentStatus != "cancelled" &&
                currentStatus != "rejected")
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: cancelOrder,
                  icon: const Icon(Icons.cancel_outlined, color: Color(0xFFDC2626), size: 20),
                  label: const Text(
                    "Cancel This Order",
                    style: TextStyle(
                      color: Color(0xFFDC2626),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFFECACA), width: 1.3),
                    backgroundColor: const Color(0xFFFEF2F2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 24),
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

    if (value.startsWith("http://") || value.startsWith("https://")) {
      return value;
    }

    return "${ApiConstants.imageBaseUrl}$value";
  }

  // ============================================================
  // MODERN ORDER TIMELINE
  // ============================================================

  Widget _buildFlipkartTimeline(String currentStatus) {
    final List<Map<String, String>> stages = [
      {"id": "pending", "label": "Order Confirmed", "desc": "Producer notified of fresh order"},
      {"id": "accepted", "label": "Produce Packed", "desc": "Crops gathered & prepared"},
      {"id": "processing", "label": "Dispatched / On Way", "desc": "In transit to your location"},
      {"id": "delivered", "label": "Delivered to Doorstep", "desc": "Produce handed over"},
    ];

    if (currentStatus == "cancelled" || currentStatus == "rejected") {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        alignment: Alignment.center,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color(0xFFFEF2F2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.cancel_outlined, color: Color(0xFFDC2626), size: 36),
            ),
            const SizedBox(height: 12),
            Text(
              "Order ${currentStatus.toUpperCase()}",
              style: const TextStyle(
                color: Color(0xFFDC2626),
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              currentStatus == "cancelled" ? "Cancelled by buyer" : "Rejected by seller",
              style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
            ),
          ],
        ),
      );
    }

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

    return Column(
      children: List.generate(stages.length, (index) {
        final bool isCompleted = index <= activeIndex;
        final bool isCurrent = index == activeIndex;
        final bool isLast = index == stages.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: isCompleted ? const Color(0xFF059669) : const Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isCompleted ? const Color(0xFF059669) : const Color(0xFFCBD5E1),
                      width: 2,
                    ),
                    boxShadow: isCurrent
                        ? [
                            BoxShadow(
                              color: const Color(0xFF059669).withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFCBD5E1),
                            ),
                          ),
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2.5,
                    height: 44,
                    color: index < activeIndex
                        ? const Color(0xFF059669)
                        : const Color(0xFFE2E8F0),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 2, bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stages[index]["label"]!,
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: isCompleted ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      stages[index]["desc"]!,
                      style: TextStyle(
                        fontSize: 12,
                        color: isCompleted ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
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
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF059669)),
          const SizedBox(width: 10),
          SizedBox(
            width: 120,
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? "N/A",
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
                fontSize: 13.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
