import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/product_model.dart';
import '../../services/order_api_service.dart';
import 'order_success_screen.dart';

class PaymentScreen extends StatefulWidget {
  final ProductModel product;
  final int quantity;
  final double totalAmount;
  final String deliveryAddress;
  final String phone;
  final String userName;

  const PaymentScreen({
    super.key,
    required this.product,
    required this.quantity,
    required this.totalAmount,
    required this.deliveryAddress,
    required this.phone,
    required this.userName,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String selectedPayment = "Cash on Delivery";
  bool isLoading = false;
  final OrderApiService _orderApiService = OrderApiService();

  List<Map<String, dynamic>> get paymentOptions => [
    {
      "id": "Cash on Delivery",
      "title": "Cash on Delivery",
      "subtitle": "Pay cash directly upon fresh harvest arrival",
      "icon": Icons.payments_rounded,
      "color": const Color(0xFF059669),
      "bg": const Color(0xFFECFDF5),
    },
    {
      "id": "GPay",
      "title": "Google Pay / UPI Direct",
      "subtitle": "Pay via UPI to grower (${widget.product.sellerPhone.isNotEmpty ? widget.product.sellerPhone : 'Farm UPI'})",
      "icon": Icons.account_balance_wallet_rounded,
      "color": const Color(0xFF0284C7),
      "bg": const Color(0xFFF0F9FF),
    },
  ];

  String mapPaymentMethod(String method) {
    if (method == "Cash on Delivery") {
      return "cash_on_delivery";
    } else if (method.startsWith("GPay") || method.contains("UPI")) {
      return "gpay";
    }
    return "cash_on_delivery";
  }

  Future<void> placeOrder() async {
    if (isLoading) return;

    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? userId = prefs.getString("userId");

      if (userId == null || userId.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Session expired. Please login again."),
            backgroundColor: const Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        setState(() => isLoading = false);
        return;
      }

      final Map<String, dynamic> orderData = {
        "buyer": userId,
        "buyerName": widget.userName,
        "product": widget.product.id,
        "quantity": widget.quantity,
        "deliveryAddress": widget.deliveryAddress,
        "phone": widget.phone,
        "paymentMethod": mapPaymentMethod(selectedPayment),
      };

      final result = await _orderApiService.createOrder(orderData);

      if (!mounted) return;

      if (result["success"] == true) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const OrderSuccessScreen()),
          (route) => route.isFirst,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result["message"] ?? "Failed to place order."),
            backgroundColor: const Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      debugPrint("PLACE ORDER ERROR: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Checkout error: $e"),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          "Payment",
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 19, letterSpacing: -0.3),
        ),
        centerTitle: true,
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
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Color(0xFF059669),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Securing your farm order...",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- STEPPER PROGRESS STRIP ---
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        _stepDot(step: "✓", title: "Details", active: true, done: true),
                        _stepDivider(active: true),
                        _stepDot(step: "2", title: "Payment", active: true, done: false),
                        _stepDivider(active: false),
                        _stepDot(step: "3", title: "Confirm", active: false, done: false),
                      ],
                    ),
                  ),

                  // --- SECTION: SELECT PAYMENT METHOD ---
                  Row(
                    children: const [
                      Icon(Icons.account_balance_wallet_outlined, size: 17, color: Color(0xFF059669)),
                      SizedBox(width: 8),
                      Text(
                        "Select Payment Method",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  ...paymentOptions.map((option) {
                    final isSelected = selectedPayment == option["id"];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedPayment = option["id"] as String;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF059669) : const Color(0xFFE2E8F0),
                            width: isSelected ? 2.0 : 1.1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isSelected
                                  ? const Color(0xFF059669).withValues(alpha: 0.08)
                                  : const Color(0xFF0F172A).withValues(alpha: 0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: option["bg"] as Color,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                option["icon"] as IconData,
                                color: option["color"] as Color,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    option["title"] as String,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF334155),
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    option["subtitle"] as String,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF64748B),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected ? const Color(0xFF059669) : const Color(0xFFCBD5E1),
                                  width: 2,
                                ),
                              ),
                              child: isSelected
                                  ? Center(
                                      child: Container(
                                        width: 12,
                                        height: 12,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Color(0xFF059669),
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 16),

                  // --- SECTION: ORDER DETAILS ---
                  Row(
                    children: const [
                      Icon(Icons.receipt_outlined, size: 17, color: Color(0xFF059669)),
                      SizedBox(width: 8),
                      Text(
                        "Order Details",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE2E8F0), width: 1.1),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _detailItem(Icons.eco_outlined, "Product", widget.product.name),
                        _detailItem(Icons.person_outline, "Grower / Seller", widget.product.sellerName.isNotEmpty ? widget.product.sellerName : "Local Farmer"),
                        _detailItem(Icons.badge_outlined, "Buyer Name", widget.userName),
                        _detailItem(Icons.scale_outlined, "Quantity", "${widget.quantity} ${widget.product.unit}"),
                        _detailItem(Icons.location_on_outlined, "Delivery Address", widget.deliveryAddress),
                        _detailItem(Icons.phone_outlined, "Contact Phone", widget.phone),
                        _detailItem(Icons.credit_card_outlined, "Payment Method", selectedPayment),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(color: Color(0xFFE2E8F0)),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Total Amount Payable",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            Text(
                              "₹${widget.totalAmount.toStringAsFixed(0)}",
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF059669),
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

      // --- STICKY BOTTOM BUTTON ---
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: isLoading ? null : placeOrder,
              icon: const Icon(Icons.shopping_bag_outlined, size: 20),
              label: Text(
                isLoading ? "Placing Order..." : "Place Order (₹${widget.totalAmount.toStringAsFixed(0)})",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF059669),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailItem(IconData icon, String label, String value) {
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
              label,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepDot({required String step, required String title, required bool active, required bool done}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: active ? const Color(0xFF059669) : const Color(0xFFE2E8F0),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              step,
              style: TextStyle(
                color: active ? Colors.white : const Color(0xFF64748B),
                fontSize: done ? 12 : 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            color: active ? const Color(0xFF059669) : const Color(0xFF64748B),
            fontSize: 12,
            fontWeight: active ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _stepDivider({required bool active}) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        color: active ? const Color(0xFF059669) : const Color(0xFFE2E8F0),
      ),
    );
  }
}
