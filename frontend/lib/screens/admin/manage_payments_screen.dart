import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/api_constants.dart';
import '../../core/constants/theme/auth_theme.dart';

class ManagePaymentsScreen extends StatefulWidget {
  const ManagePaymentsScreen({super.key});

  @override
  State<ManagePaymentsScreen> createState() => _ManagePaymentsScreenState();
}

class _ManagePaymentsScreenState extends State<ManagePaymentsScreen> {
  static const String baseUrl = ApiConstants.adminUrl;
  List<Map<String, dynamic>> payments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPayments();
  }

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("adminToken") ?? prefs.getString("token");
    final headers = <String, String>{"Content-Type": "application/json"};
    if (token != null && token.isNotEmpty) {
      headers["Authorization"] = "Bearer $token";
    }
    return headers;
  }

  Future<void> fetchPayments() async {
    if (mounted) setState(() => isLoading = true);

    try {
      final headers = await _getHeaders();
      final url = "$baseUrl/payments";
      final response = await http.get(Uri.parse(url), headers: headers);

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
        }
      } else {
        _showMessage("Failed to load payments: ${response.statusCode}", const Color(0xFFEF4444));
      }
    } catch (error) {
      debugPrint("PAYMENT ERROR: $error");
      _showMessage("Unable to connect to server", const Color(0xFFEF4444));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  String _getPaymentId(Map<String, dynamic> payment) {
    return payment["_id"]?.toString() ?? payment["id"]?.toString() ?? "Unknown";
  }

  String _getOrderNumber(Map<String, dynamic> payment) {
    final order = payment["order"];
    if (order is Map) {
      return order["orderNumber"]?.toString() ?? order["_id"]?.toString() ?? "Unknown";
    }
    return order?.toString() ?? "Unknown";
  }

  String _getBuyerName(Map<String, dynamic> payment) {
    final buyer = payment["buyer"];
    if (buyer is Map) {
      return buyer["name"]?.toString() ?? "Customer";
    }
    return buyer?.toString() ?? "Customer";
  }

  String _getBuyerPhone(Map<String, dynamic> payment) {
    final buyer = payment["buyer"];
    if (buyer is Map) {
      return buyer["phone"]?.toString() ?? "";
    }
    return "";
  }

  num _getRawAmount(Map<String, dynamic> payment) {
    dynamic amount = payment["amount"] ?? payment["totalAmount"] ?? (payment["order"] as Map?)?["totalAmount"];
    if (amount is num) return amount;
    if (amount is String) return num.tryParse(amount) ?? 0;
    return 0;
  }

  String _getAmount(Map<String, dynamic> payment) {
    final numVal = _getRawAmount(payment);
    return "₹${numVal.toStringAsFixed(0)}";
  }

  String _getPaymentMethod(Map<String, dynamic> payment) {
    return payment["method"]?.toString() ?? payment["paymentMethod"]?.toString() ?? "UPI / Online";
  }

  String _getPaymentStatus(Map<String, dynamic> payment) {
    final status = payment["status"]?.toString();
    if (status != null && status.isNotEmpty) {
      return status;
    }
    return "completed";
  }

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
        return Dialog(
          backgroundColor: AdminTheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AdminTheme.limeBorder, width: 1.2),
          ),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Payment Details",
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                    AdminTheme.limeChip(status.toUpperCase()),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(color: AdminTheme.border, height: 1),
                const SizedBox(height: 16),
                _detailRow("Payment ID", paymentId),
                _detailRow("Order Reference", orderNumber),
                _detailRow("Customer Name", buyerName),
                if (buyerPhone.isNotEmpty) _detailRow("Customer Phone", buyerPhone),
                _detailRow("Total Amount", amount, isLime: true),
                _detailRow("Settlement Gateway", method),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AdminTheme.lime,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text("Close", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(String title, String value, {bool isLime = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              "$title:",
              style: const TextStyle(fontWeight: FontWeight.w700, color: AdminTheme.textSecondary, fontSize: 12.5),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: isLime ? AdminTheme.lime : Colors.white,
                fontSize: isLime ? 15 : 12.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMessage(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AdminTheme.surfaceElevated,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: color, width: 1.2),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    num totalVolume = 0;
    for (final p in payments) {
      totalVolume += _getRawAmount(p);
    }

    return Scaffold(
      backgroundColor: AdminTheme.background,
      body: Column(
        children: [
          // ==========================================
          // TOP CYBER LIME APPBAR
          // ==========================================
          Container(
            decoration: BoxDecoration(
              gradient: AdminTheme.appBarGradient,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              border: const Border(
                bottom: BorderSide(color: AdminTheme.limeBorder, width: 1),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x3300FF00),
                  blurRadius: 16,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AdminTheme.limeBorder),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: AdminTheme.lime,
                          size: 18,
                        ),
                        tooltip: "Back",
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Flexible(
                                child: Text(
                                  "Payments & Ledger",
                                  style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: -0.3,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              AdminTheme.limeChip("${payments.length} TRANS"),
                            ],
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            "Real-time financial audits and payouts",
                            style: TextStyle(
                              fontSize: 12,
                              color: AdminTheme.textSecondary,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AdminTheme.limeBorder),
                      ),
                      child: IconButton(
                        tooltip: "Refresh ledger",
                        onPressed: isLoading ? null : fetchPayments,
                        icon: const Icon(
                          Icons.refresh_rounded,
                          color: AdminTheme.lime,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ==========================================
          // HERO REVENUE LEDGER BANNER
          // ==========================================
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: AdminTheme.cardDecoration(glow: true),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AdminTheme.lime.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AdminTheme.limeBorder),
                    ),
                    child: const Icon(Icons.account_balance_wallet_rounded, color: AdminTheme.lime, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "GROSS SETTLEMENT VOLUME",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AdminTheme.textSecondary,
                            letterSpacing: 0.6,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "₹${totalVolume.toStringAsFixed(0)}",
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: AdminTheme.lime,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AdminTheme.limeChip("ACTIVE"),
                ],
              ),
            ),
          ),

          // ==========================================
          // PAYMENTS LIST
          // ==========================================
          Expanded(
            child: isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(AdminTheme.lime),
                        ),
                        SizedBox(height: 16),
                        Text(
                          "Syncing transaction audits...",
                          style: TextStyle(
                            color: AdminTheme.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : payments.isEmpty
                    ? _emptyPayments()
                    : RefreshIndicator(
                        color: AdminTheme.lime,
                        backgroundColor: AdminTheme.surface,
                        onRefresh: fetchPayments,
                        child: ListView.builder(
                          physics: const BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics(),
                          ),
                          padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
                          itemCount: payments.length,
                          itemBuilder: (context, index) {
                            return _paymentCard(payments[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _emptyPayments() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AdminTheme.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AdminTheme.limeBorder),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x3300FF00),
                  blurRadius: 20,
                ),
              ],
            ),
            child: const Icon(
              Icons.payment_outlined,
              size: 48,
              color: AdminTheme.lime,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "No Payment Records Found",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Payments created by users will appear here.",
            style: TextStyle(fontSize: 13, color: AdminTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _paymentCard(Map<String, dynamic> payment) {
    final paymentId = _getPaymentId(payment);
    final orderNumber = _getOrderNumber(payment);
    final buyerName = _getBuyerName(payment);
    final buyerPhone = _getBuyerPhone(payment);
    final amount = _getAmount(payment);
    final method = _getPaymentMethod(payment);
    final status = _getPaymentStatus(payment);

    final rawId = paymentId.length > 8 ? paymentId.substring(paymentId.length - 8).toUpperCase() : paymentId.toUpperCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: AdminTheme.cardDecoration(glow: false),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AdminTheme.lime.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AdminTheme.limeBorder),
                ),
                child: const Icon(Icons.currency_rupee_rounded, color: AdminTheme.lime, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "TXN #$rawId",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            fontFamily: "monospace",
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        AdminTheme.limeChip(status.toUpperCase()),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      "Order: $orderNumber",
                      style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Text(
                amount,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AdminTheme.lime,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AdminTheme.surfaceElevated,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AdminTheme.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.person_outline_rounded, size: 15, color: AdminTheme.textSecondary),
                    const SizedBox(width: 6),
                    Text(
                      buyerName,
                      style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600),
                    ),
                    if (buyerPhone.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Text("($buyerPhone)", style: const TextStyle(color: AdminTheme.textMuted, fontSize: 11.5)),
                    ],
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AdminTheme.border),
                  ),
                  child: Text(
                    method.toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFF38BDF8),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // SOLID LIME PILL BUTTON - MATCHING USER IMAGE REFERENCE
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton.icon(
              onPressed: () => _showPaymentDetails(payment),
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminTheme.lime,
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              icon: const Icon(Icons.visibility_rounded, size: 17, color: Colors.black),
              label: const Text(
                "View Audit Details",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
