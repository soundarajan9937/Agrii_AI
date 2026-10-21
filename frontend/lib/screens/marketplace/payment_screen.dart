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

  List<String> get paymentMethods => [
    "Cash on Delivery",
    "GPay (${widget.product.sellerPhone.isNotEmpty ? widget.product.sellerPhone : "Contact Farmer"})",
  ];

  String mapPaymentMethod(String method) {
    if (method == "Cash on Delivery") {
      return "cash_on_delivery";
    } else if (method.startsWith("GPay")) {
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
          const SnackBar(content: Text("Session expired. Please login again.")),
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
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint("PLACE ORDER ERROR: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("An error occurred during checkout"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  IconData getPaymentIcon(String method) {
    if (method == "Cash on Delivery") {
      return Icons.money;
    } else {
      return Icons.account_balance_wallet;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F7FD),
      appBar: AppBar(
        title: const Text("Payment"),
        centerTitle: true,
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
      ),
      body: isLoading
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF1976D2)))
        : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Select Payment Method",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            ...paymentMethods.map((method) {
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: RadioListTile<String>(
                  value: method,
                  groupValue: selectedPayment,
                  activeColor: const Color(0xFF1976D2),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      selectedPayment = value;
                    });
                  },
                  title: Text(
                    method,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  secondary: Icon(getPaymentIcon(method), color: const Color(0xFF1976D2)),
                ),
              );
            }),
            const SizedBox(height: 20),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Order Details",
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text("Product: ${widget.product.name}", style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    Text("Seller: ${widget.product.sellerName}", style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    Text("Buyer: ${widget.userName}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text("Quantity: ${widget.quantity} ${widget.product.unit}", style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    Text("Delivery Address: ${widget.deliveryAddress}", style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    Text("Phone: ${widget.phone}", style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    Text("Payment: $selectedPayment", style: const TextStyle(fontSize: 16)),
                    const Divider(height: 25),
                    Text(
                      "Total Amount: ₹${widget.totalAmount.toStringAsFixed(0)}",
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1976D2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: placeOrder,
                icon: const Icon(Icons.shopping_cart_checkout),
                label: const Text(
                  "Place Order",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1976D2),
                  foregroundColor: Colors.white,
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
}
