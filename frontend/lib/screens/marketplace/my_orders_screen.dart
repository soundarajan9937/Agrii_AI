import 'package:flutter/material.dart';
import '../../core/constants/api_constants.dart';
import '../../services/order_api_service.dart';
import '../../services/agri_resource_service.dart';
import '../../models/agri_resource_order_model.dart';
import 'track_order_screen.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> with SingleTickerProviderStateMixin {
  final OrderApiService _orderApiService = OrderApiService();
  final AgriResourceService _resourceService = AgriResourceService();

  List<dynamic> marketplaceOrders = [];
  List<AgriResourceOrderModel> resourceOrders = [];

  bool isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchAllOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchAllOrders() async {
    setState(() => isLoading = true);
    try {
      final mOrders = await _orderApiService.getUserOrders();
      final rOrders = await _resourceService.getUserOrders();
      setState(() {
        marketplaceOrders = mOrders;
        resourceOrders = rOrders;
        isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F7FD),
      appBar: AppBar(
        title: const Text("My Orders"),
        centerTitle: true,
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: "Marketplace"),
            Tab(text: "Agri Resources"),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1976D2)))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildMarketplaceList(),
                _buildResourceList(),
              ],
            ),
    );
  }

  Widget _buildMarketplaceList() {
    if (marketplaceOrders.isEmpty) return _emptyView("No Marketplace Orders");
    return RefreshIndicator(
      onRefresh: _fetchAllOrders,
      child: ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: marketplaceOrders.length,
        itemBuilder: (context, index) => _orderCard(marketplaceOrders[index]),
      ),
    );
  }

  Widget _buildResourceList() {
    if (resourceOrders.isEmpty) return _emptyView("No Resource Orders");
    return RefreshIndicator(
      onRefresh: _fetchAllOrders,
      child: ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: resourceOrders.length,
        itemBuilder: (context, index) => _resourceOrderCard(resourceOrders[index]),
      ),
    );
  }

  Widget _emptyView(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shopping_bag_outlined, size: 90, color: Colors.grey),
          const SizedBox(height: 15),
          Text(message, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _resourceOrderCard(AgriResourceOrderModel order) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: order.resourceImage != null
                      ? Image.network(
                          "${ApiConstants.serverBaseUrl}/uploads/${order.resourceImage}",
                          width: 80, height: 80, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(width: 80, height: 80, color: Colors.grey.shade200, child: const Icon(Icons.category)),
                        )
                      : Container(width: 80, height: 80, color: Colors.grey.shade200, child: const Icon(Icons.category)),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order.resourceName ?? "Unknown Material", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      Text("Price: ₹${order.price}", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      _statusChip(order.status),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Payment: ${order.paymentMethod}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      Text("Address: ${order.deliveryAddress}", style: const TextStyle(fontSize: 12, color: Colors.grey), maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                if (order.status == 'pending')
                  TextButton(
                    onPressed: () async {
                      final success = await _resourceService.cancelOrder(order.id);
                      if (success) _fetchAllOrders();
                    },
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text("Cancel Order"),
                  ),
              ],
            ),
            if (order.status == 'accepted')
              const Padding(
                padding: EdgeInsets.only(top: 10),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 20),
                    SizedBox(width: 8),
                    Text("Order Accepted by Farmer", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _orderCard(Map<String, dynamic> order) {
    final status = order["status"] ?? "Pending";
    final productName = order["productName"] ?? "Product";

    // Farmer / Seller Info
    final sellerName = order["sellerName"] ?? (order["seller"] is Map ? order["seller"]["name"] : "Farmer");
    final sellerPhone = order["sellerPhone"] ?? (order["seller"] is Map ? order["seller"]["phone"] : "N/A");
    final sellerLocation = order["sellerLocation"] ?? (order["seller"] is Map ? order["seller"]["farmLocation"] : "N/A");

    // Buyer Info
    final buyerName = order["buyerName"] ?? "Me";
    final buyerPhone = order["buyerPhone"] ?? order["phone"] ?? "N/A";
    final deliveryAddress = order["deliveryAddress"] ?? "N/A";
    final paymentMethod = order["paymentMethod"]?.toString().replaceAll("_", " ").toUpperCase() ?? "CASH ON DELIVERY";

    // Common info
    final quantityText = "${order["quantity"]} ${order["unit"] ?? "Kg"}";
    final amountText = "₹${order["totalAmount"]}";

    // Product Image
    final String imageUrl = order["productImage"] ?? (order["product"] is Map ? order["product"]["image"] : "");

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1976D2).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                          ApiConstants.imageBaseUrl + imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.inventory_2, color: Color(0xFF1976D2), size: 35),
                        )
                      : const Icon(Icons.inventory_2, color: Color(0xFF1976D2), size: 35),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        productName,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      _statusChip(status),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            const Divider(),

            const Text("Delivery Details:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 12),
            _detailRow("Seller", sellerName),
            _detailRow("Phone", sellerPhone),
            _detailRow("Address", sellerLocation),

            const SizedBox(height: 20),
            const Divider(),

            const Text("My Details:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 12),
            _detailRow("Name", buyerName),
            _detailRow("Phone", buyerPhone),
            _detailRow("Address", deliveryAddress),
            _detailRow("Quantity", quantityText),
            _detailRow("Amount", amountText),
            _detailRow("Payment", paymentMethod),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TrackOrderScreen(order: order),
                    ),
                  );
                  _fetchAllOrders();
                },
                icon: const Icon(Icons.location_on),
                label: const Text("Track Order", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1976D2),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text("$label:", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, fontStyle: FontStyle.italic)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 14, color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String status) {
    Color color = Colors.orange;
    final s = status.toLowerCase();
    if (s == "delivered" || s == "accepted") color = const Color(0xFF2E7D32);
    if (s == "cancelled" || s == "rejected") color = Colors.red;
    if (s == "shipped" || s == "processing") color = const Color(0xFF1976D2);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
