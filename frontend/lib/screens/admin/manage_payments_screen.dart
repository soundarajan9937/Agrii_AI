import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ManagePaymentsScreen extends StatefulWidget {
  const ManagePaymentsScreen({super.key});

  @override
  State<ManagePaymentsScreen> createState() => _ManagePaymentsScreenState();
}

class _ManagePaymentsScreenState extends State<ManagePaymentsScreen> {
  // ==========================================================
  // BACKEND URL
  // ==========================================================
  //
  // REAL PHONE:
  // Use your PC IP address.
  //
  // Example:
  // http://10.253.175.78:5000/api/admin
  //
  // Android Emulator:
  // http://10.0.2.2:5000/api/admin
  //
  // ==========================================================

  static const String baseUrl = "http://10.253.175.78:5000/api/admin";

  // ==========================================================
  // VARIABLES
  // ==========================================================

  List<Map<String, dynamic>> payments = [];

  bool isLoading = true;

  // ==========================================================
  // INIT
  // ==========================================================

  @override
  void initState() {
    super.initState();
    fetchPayments();
  }

  // ==========================================================
  // GET ADMIN TOKEN
  // ==========================================================

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString("adminToken");

    final headers = <String, String>{"Content-Type": "application/json"};

    if (token != null && token.isNotEmpty) {
      headers["Authorization"] = "Bearer $token";
    }

    return headers;
  }

  // ==========================================================
  // FETCH PAYMENTS FROM MONGODB
  // ==========================================================

  Future<void> fetchPayments() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    try {
      final headers = await _getHeaders();

      final url = "$baseUrl/payments";

      debugPrint("========== ADMIN PAYMENTS ==========");
      debugPrint("URL: $url");

      final response = await http.get(Uri.parse(url), headers: headers);

      debugPrint("STATUS: ${response.statusCode}");
      debugPrint("BODY: ${response.body}");
      debugPrint("====================================");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final paymentList = data["payments"];

        if (paymentList is List) {
          final List<Map<String, dynamic>> loadedPayments = [];

          for (final payment in paymentList) {
            if (payment is Map) {
              loadedPayments.add(Map<String, dynamic>.from(payment));
            }
          }

          if (mounted) {
            setState(() {
              payments = loadedPayments;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              payments = [];
            });
          }
        }
      } else {
        String message = "Failed to load payments";

        try {
          final data = jsonDecode(response.body);

          if (data["message"] != null) {
            message = data["message"].toString();
          }
        } catch (_) {}

        _showMessage(message, Colors.red);
      }
    } catch (error) {
      debugPrint("========== PAYMENT ERROR ==========");
      debugPrint(error.toString());
      debugPrint("===================================");

      _showMessage("Unable to connect to server", Colors.red);
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // ==========================================================
  // GET PAYMENT ID
  // ==========================================================

  String _getPaymentId(Map<String, dynamic> payment) {
    return payment["_id"]?.toString() ?? payment["id"]?.toString() ?? "Unknown";
  }

  // ==========================================================
  // GET ORDER INFORMATION
  // ==========================================================

  String _getOrderNumber(Map<String, dynamic> payment) {
    final order = payment["order"];

    if (order is Map) {
      return order["orderNumber"]?.toString() ??
          order["_id"]?.toString() ??
          "Unknown";
    }

    return order?.toString() ?? "Unknown";
  }

  // ==========================================================
  // GET BUYER NAME
  // ==========================================================

  String _getBuyerName(Map<String, dynamic> payment) {
    final buyer = payment["buyer"];

    if (buyer is Map) {
      return buyer["name"]?.toString() ?? "Unknown";
    }

    return buyer?.toString() ?? "Unknown";
  }

  // ==========================================================
  // GET BUYER PHONE
  // ==========================================================

  String _getBuyerPhone(Map<String, dynamic> payment) {
    final buyer = payment["buyer"];

    if (buyer is Map) {
      return buyer["phone"]?.toString() ?? "";
    }

    return "";
  }

  // ==========================================================
  // GET PAYMENT AMOUNT
  // ==========================================================

  String _getAmount(Map<String, dynamic> payment) {
    dynamic amount;

    amount = payment["amount"];

    // Some payment models may use totalAmount
    amount ??= payment["totalAmount"];

    // If amount is inside order
    amount ??= (payment["order"] as Map?)?["totalAmount"];

    if (amount == null) {
      return "₹0";
    }

    if (amount is num) {
      return "₹${amount.toStringAsFixed(0)}";
    }

    return "₹${amount.toString()}";
  }

  // ==========================================================
  // GET PAYMENT METHOD
  // ==========================================================

  String _getPaymentMethod(Map<String, dynamic> payment) {
    return payment["method"]?.toString() ??
        payment["paymentMethod"]?.toString() ??
        "Unknown";
  }

  // ==========================================================
  // GET PAYMENT STATUS
  // ==========================================================

  String _getPaymentStatus(Map<String, dynamic> payment) {
    final status = payment["status"]?.toString();

    if (status != null && status.isNotEmpty) {
      return status;
    }

    return "Unknown";
  }

  // ==========================================================
  // PAYMENT STATUS COLOR
  // ==========================================================

  Color _getStatusColor(String status) {
    final value = status.toLowerCase();

    if (value == "success" ||
        value == "successful" ||
        value == "paid" ||
        value == "completed") {
      return Colors.green;
    }

    if (value == "pending") {
      return Colors.orange;
    }

    if (value == "failed" || value == "cancelled" || value == "rejected") {
      return Colors.red;
    }

    return Colors.blue;
  }

  // ==========================================================
  // PAYMENT STATUS ICON
  // ==========================================================

  IconData _getStatusIcon(String status) {
    final value = status.toLowerCase();

    if (value == "success" ||
        value == "successful" ||
        value == "paid" ||
        value == "completed") {
      return Icons.check_circle;
    }

    if (value == "pending") {
      return Icons.pending;
    }

    if (value == "failed" || value == "cancelled" || value == "rejected") {
      return Icons.cancel;
    }

    return Icons.info;
  }

  // ==========================================================
  // SHOW PAYMENT DETAILS
  // ==========================================================

  void _showPaymentDetails(Map<String, dynamic> payment) {
    final paymentId = _getPaymentId(payment);
    final orderNumber = _getOrderNumber(payment);
    final buyerName = _getBuyerName(payment);
    final buyerPhone = _getBuyerPhone(payment);
    final amount = _getAmount(payment);
    final method = _getPaymentMethod(payment);
    final status = _getPaymentStatus(payment);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            "Payment Details",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detailRow("Payment ID", paymentId),

                _detailRow("Order", orderNumber),

                _detailRow("Buyer", buyerName),

                if (buyerPhone.isNotEmpty) _detailRow("Phone", buyerPhone),

                _detailRow("Amount", amount),

                _detailRow("Method", method),

                _detailRow("Status", status),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  // ==========================================================
  // DETAIL ROW
  // ==========================================================

  Widget _detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black87, fontSize: 15),
          children: [
            TextSpan(
              text: "$title: ",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // MESSAGE
  // ==========================================================

  void _showMessage(String message, Color color) {
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F2),

      // ========================================================
      // APP BAR
      // ========================================================
      appBar: AppBar(
        title: const Text(
          "Manage Payments",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,

        actions: [
          IconButton(
            tooltip: "Refresh",
            onPressed: isLoading ? null : fetchPayments,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),

      // ========================================================
      // BODY
      // ========================================================
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : payments.isEmpty
          ? _emptyPayments()
          : RefreshIndicator(
              color: Colors.green,
              onRefresh: fetchPayments,

              child: ListView.builder(
                padding: const EdgeInsets.all(15),
                itemCount: payments.length,

                itemBuilder: (context, index) {
                  final payment = payments[index];

                  return _paymentCard(payment);
                },
              ),
            ),
    );
  }

  // ==========================================================
  // EMPTY PAYMENTS
  // ==========================================================

  Widget _emptyPayments() {
    return RefreshIndicator(
      color: Colors.green,
      onRefresh: fetchPayments,

      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),

        children: const [
          SizedBox(height: 150),

          Icon(Icons.payment_outlined, size: 70, color: Colors.grey),

          SizedBox(height: 20),

          Center(
            child: Text(
              "No payments found",
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          SizedBox(height: 8),

          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                "Payments created by users "
                "will appear here.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // PAYMENT CARD
  // ==========================================================

  Widget _paymentCard(Map<String, dynamic> payment) {
    final paymentId = _getPaymentId(payment);

    final orderNumber = _getOrderNumber(payment);

    final buyerName = _getBuyerName(payment);

    final buyerPhone = _getBuyerPhone(payment);

    final amount = _getAmount(payment);

    final method = _getPaymentMethod(payment);

    final status = _getPaymentStatus(payment);

    final statusColor = _getStatusColor(status);

    final statusIcon = _getStatusIcon(status);

    return Card(
      margin: const EdgeInsets.only(bottom: 14),

      elevation: 3,

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),

      child: Padding(
        padding: const EdgeInsets.all(15),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // ==================================================
            // TOP SECTION
            // ==================================================
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                CircleAvatar(
                  radius: 27,

                  backgroundColor: Colors.green.shade100,

                  child: const Icon(
                    Icons.payment,
                    color: Colors.green,
                    size: 28,
                  ),
                ),

                const SizedBox(width: 15),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        paymentId,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        "Order: $orderNumber",
                        style: const TextStyle(color: Colors.black87),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        "Buyer: $buyerName",
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                Column(
                  children: [
                    Icon(statusIcon, color: statusColor, size: 27),

                    const SizedBox(height: 4),

                    Text(
                      status,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 15),

            const Divider(),

            const SizedBox(height: 8),

            // ==================================================
            // AMOUNT
            // ==================================================
            Row(
              children: [
                const Icon(Icons.currency_rupee, size: 20, color: Colors.green),

                const SizedBox(width: 5),

                Text(
                  amount,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 9),

            // ==================================================
            // PAYMENT METHOD
            // ==================================================
            Row(
              children: [
                const Icon(Icons.credit_card, size: 19, color: Colors.blue),

                const SizedBox(width: 7),

                Expanded(
                  child: Text(
                    "Method: $method",
                    style: const TextStyle(color: Colors.black87),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // ==================================================
            // PHONE
            // ==================================================
            if (buyerPhone.isNotEmpty)
              Row(
                children: [
                  const Icon(Icons.phone, size: 18, color: Colors.green),

                  const SizedBox(width: 7),

                  Text(
                    buyerPhone,
                    style: const TextStyle(color: Colors.black87),
                  ),
                ],
              ),

            const SizedBox(height: 12),

            // ==================================================
            // VIEW DETAILS
            // ==================================================
            SizedBox(
              width: double.infinity,

              child: OutlinedButton.icon(
                onPressed: () {
                  _showPaymentDetails(payment);
                },

                icon: const Icon(Icons.visibility),

                label: const Text("View Details"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
