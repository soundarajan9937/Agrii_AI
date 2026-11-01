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
      debugPrint("FETCH ALL ORDERS ERROR: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  String _buildImageUrl(String image) {
    final String value = image.trim();
    if (value.isEmpty) return "";
    if (value.startsWith("http://") || value.startsWith("https://")) return value;
    return "${ApiConstants.imageBaseUrl}$value";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          Container(
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
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x2A0F766E),
                  blurRadius: 16,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Top Header Row
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 16, 6),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25),
                            ),
                          ),
                          child: const Icon(
                            Icons.local_shipping_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                "My Orders",
                                style: TextStyle(
                                  fontSize: 21,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              Text(
                                "Track farm fresh deliveries",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: "Refresh Orders",
                          onPressed: _fetchAllOrders,
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.refresh_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Pill Segmented TabBar
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 2, 16, 10),
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      labelColor: const Color(0xFF0F766E),
                      unselectedLabelColor: Colors.white,
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                      tabs: [
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.storefront_rounded, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                marketplaceOrders.isEmpty
                                    ? "Marketplace"
                                    : "Marketplace (${marketplaceOrders.length})",
                              ),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.eco_rounded, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                resourceOrders.isEmpty
                                    ? "Agri Resources"
                                    : "Agri Resources (${resourceOrders.length})",
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF059669)),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Loading your orders...",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildMarketplaceList(),
                      _buildResourceList(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketplaceList() {
    if (marketplaceOrders.isEmpty) {
      return _emptyView(
        title: "No Marketplace Orders",
        subtitle: "Order fresh vegetables, fruits, and grains directly from local farmers.",
        icon: Icons.shopping_basket_outlined,
      );
    }
    return RefreshIndicator(
      color: const Color(0xFF059669),
      onRefresh: _fetchAllOrders,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: marketplaceOrders.length,
        itemBuilder: (context, index) => _orderCard(marketplaceOrders[index]),
      ),
    );
  }

  Widget _buildResourceList() {
    if (resourceOrders.isEmpty) {
      return _emptyView(
        title: "No Resource Orders",
        subtitle: "Order agricultural equipment, organic fertilizers, and quality seeds.",
        icon: Icons.agriculture_outlined,
      );
    }
    return RefreshIndicator(
      color: const Color(0xFF059669),
      onRefresh: _fetchAllOrders,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: resourceOrders.length,
        itemBuilder: (context, index) => _resourceOrderCard(resourceOrders[index]),
      ),
    );
  }

  Widget _emptyView({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF059669).withValues(alpha: 0.12),
                    const Color(0xFF0284C7).withValues(alpha: 0.12),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: const Color(0xFF0F766E),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchAllOrders,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text("Refresh Status"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF059669),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // MARKETPLACE ORDER CARD
  // ============================================================
  Widget _orderCard(Map<String, dynamic> order) {
    final status = order["status"]?.toString() ?? "Pending";
    final productName = order["productName"]?.toString() ?? "Farm Product";

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
    final quantityText = "${order["quantity"] ?? 1} ${order["unit"] ?? "Kg"}";
    final amountText = "₹${order["totalAmount"] ?? 0}";

    // Product Image
    final String rawImage = order["productImage"]?.toString() ??
        (order["product"] is Map ? order["product"]["image"]?.toString() ?? "" : "");
    final String imageUrl = _buildImageUrl(rawImage);

    final String orderIdShort = order["_id"] != null && order["_id"].toString().length >= 6
        ? "#${order["_id"].toString().substring(order["_id"].toString().length - 6).toUpperCase()}"
        : "";

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F766E).withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Product Row: Image + Title + Status + Order ID
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image Container
                Container(
                  width: 78,
                  height: 78,
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
                            size: 36,
                          ),
                        )
                      : const Icon(
                          Icons.eco_rounded,
                          color: Color(0xFF059669),
                          size: 36,
                        ),
                ),
                const SizedBox(width: 14),

                // Name & Status Pill
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              productName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                                letterSpacing: -0.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (orderIdShort.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                orderIdShort,
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _statusChip(status),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Order Metrics Strip: Quantity, Total Amount, Payment Method
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFEDF2F7)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Quantity
                  Row(
                    children: [
                      const Icon(Icons.scale_rounded, size: 16, color: Color(0xFF059669)),
                      const SizedBox(width: 6),
                      Text(
                        quantityText,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF334155),
                        ),
                      ),
                    ],
                  ),

                  // Divider dot
                  Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: Color(0xFFCBD5E1),
                      shape: BoxShape.circle,
                    ),
                  ),

                  // Total Amount
                  Row(
                    children: [
                      const Text(
                        "Total: ",
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      Text(
                        amountText,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF059669),
                        ),
                      ),
                    ],
                  ),

                  // Divider dot
                  Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: Color(0xFFCBD5E1),
                      shape: BoxShape.circle,
                    ),
                  ),

                  // Payment
                  Row(
                    children: [
                      const Icon(Icons.payments_outlined, size: 15, color: Color(0xFF0284C7)),
                      const SizedBox(width: 5),
                      Text(
                        paymentMethod == "CASH ON DELIVERY" ? "COD" : paymentMethod,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0284C7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Farmer & Delivery Details Section
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFF1F5F9)),
              ),
              child: Column(
                children: [
                  // Farmer row
                  _infoCardSection(
                    title: "Farmer Details",
                    icon: Icons.agriculture_rounded,
                    iconColor: const Color(0xFF059669),
                    items: [
                      {"label": "Seller", "value": sellerName.toString()},
                      {"label": "Phone", "value": sellerPhone.toString()},
                      {"label": "Location", "value": sellerLocation.toString()},
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                  ),
                  // Delivery row
                  _infoCardSection(
                    title: "Delivery Details",
                    icon: Icons.location_on_rounded,
                    iconColor: const Color(0xFF0284C7),
                    items: [
                      {"label": "Customer", "value": buyerName.toString()},
                      {"label": "Phone", "value": buyerPhone.toString()},
                      {"label": "Address", "value": deliveryAddress.toString()},
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Track Order Gradient Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF0F766E),
                      Color(0xFF059669),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF059669).withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TrackOrderScreen(order: order),
                        ),
                      );
                      _fetchAllOrders();
                    },
                    child: const Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.near_me_rounded, color: Colors.white, size: 18),
                          SizedBox(width: 8),
                          Text(
                            "Track Order",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                          SizedBox(width: 6),
                          Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // AGRI RESOURCE ORDER CARD
  // ============================================================
  Widget _resourceOrderCard(AgriResourceOrderModel order) {
    final status = order.status;
    final String imageUrl = order.resourceImage != null ? _buildImageUrl(order.resourceImage!) : "";
    final paymentMethod = order.paymentMethod.replaceAll("_", " ").toUpperCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F766E).withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 78,
                  height: 78,
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
                            Icons.category_rounded,
                            color: Color(0xFF0F766E),
                            size: 36,
                          ),
                        )
                      : const Icon(
                          Icons.category_rounded,
                          color: Color(0xFF0F766E),
                          size: 36,
                        ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.resourceName ?? "Agricultural Resource",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Text(
                            "Price: ",
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          Text(
                            "₹${order.price.toStringAsFixed(0)}",
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF059669),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      _statusChip(status),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Delivery & Payment info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFEDF2F7)),
              ),
              child: Column(
                children: [
                  _infoCardSection(
                    title: "Resource Order Details",
                    icon: Icons.inventory_2_rounded,
                    iconColor: const Color(0xFF0284C7),
                    items: [
                      {"label": "Recipient", "value": order.buyerName.isNotEmpty ? order.buyerName : "Customer"},
                      {"label": "Phone", "value": order.buyerPhone.isNotEmpty ? order.buyerPhone : "N/A"},
                      {"label": "Address", "value": order.deliveryAddress.isNotEmpty ? order.deliveryAddress : "N/A"},
                      {"label": "Payment", "value": paymentMethod.isNotEmpty ? paymentMethod : "Cash on Delivery"},
                    ],
                  ),
                ],
              ),
            ),

            if (status.toLowerCase() == 'pending') ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        title: const Text("Cancel Order"),
                        content: const Text("Are you sure you want to cancel this resource order?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text("Keep Order"),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text("Yes, Cancel"),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      final success = await _resourceService.cancelOrder(order.id);
                      if (success) _fetchAllOrders();
                    }
                  },
                  icon: const Icon(Icons.cancel_outlined, color: Colors.red, size: 18),
                  label: const Text(
                    "Cancel Resource Order",
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFFCA5A5)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                  ),
                ),
              ),
            ],

            if (status.toLowerCase() == 'accepted')
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFA7F3D0)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.verified_rounded, color: Color(0xFF059669), size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Order Confirmed & Accepted by Farmer",
                        style: TextStyle(
                          color: Color(0xFF059669),
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // INFO CARD SECTION BUILDER
  // ============================================================
  Widget _infoCardSection({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Map<String, String>> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 15, color: iconColor),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: iconColor,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 76,
                  child: Text(
                    "${item["label"]}:",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    item["value"] ?? "N/A",
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // STATUS CHIP
  // ============================================================
  Widget _statusChip(String status) {
    Color textColor = const Color(0xFFD97706);
    Color bgColor = const Color(0xFFFEF3C7);
    IconData icon = Icons.schedule_rounded;

    final s = status.toLowerCase();
    if (s == "delivered") {
      textColor = const Color(0xFF0284C7);
      bgColor = const Color(0xFFE0F2FE);
      icon = Icons.done_all_rounded;
    } else if (s == "accepted" || s == "confirmed") {
      textColor = const Color(0xFF059669);
      bgColor = const Color(0xFFECFDF5);
      icon = Icons.check_circle_rounded;
    } else if (s == "cancelled" || s == "rejected") {
      textColor = const Color(0xFFDC2626);
      bgColor = const Color(0xFFFEF2F2);
      icon = Icons.cancel_rounded;
    } else if (s == "processing" || s == "shipped" || s == "out_for_delivery") {
      textColor = const Color(0xFF7C3AED);
      bgColor = const Color(0xFFF3E8FF);
      icon = Icons.local_shipping_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: textColor),
          const SizedBox(width: 5),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: textColor,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
