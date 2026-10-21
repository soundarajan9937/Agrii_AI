import 'package:flutter/material.dart';
import '../../models/agri_resource_model.dart';
import '../../models/agri_resource_order_model.dart';
import '../../services/agri_resource_service.dart';
import '../../core/constants/api_constants.dart';
import 'add_agri_resource_screen.dart';
import 'edit_agri_resource_screen.dart';

class FarmerAgriResourcesScreen extends StatefulWidget {
  final int initialTab;
  const FarmerAgriResourcesScreen({super.key, this.initialTab = 0});

  @override
  State<FarmerAgriResourcesScreen> createState() => _FarmerAgriResourcesScreenState();
}

class _FarmerAgriResourcesScreenState extends State<FarmerAgriResourcesScreen> {
  final AgriResourceService _service = AgriResourceService();
  List<AgriResourceModel> myResources = [];
  List<AgriResourceOrderModel> orders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => isLoading = true);
    try {
      final rList = await _service.getMyResources();
      final oList = await _service.getFarmerOrders();
      setState(() {
        myResources = rList;
        orders = oList;
        isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: widget.initialTab,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("My Agri Resources"),
          backgroundColor: Colors.orange,
          bottom: const TabBar(
            tabs: [Tab(text: "My Listings"), Tab(text: "Orders Received")],
            indicatorColor: Colors.white,
          ),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.orange))
            : TabBarView(
                children: [
                  _buildMyListings(),
                  _buildOrdersReceived(),
                ],
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final res = await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddAgriResourceScreen()));
            if (res == true) _fetchData();
          },
          backgroundColor: Colors.orange,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildMyListings() {
    if (myResources.isEmpty) return const Center(child: Text("No listings found"));
    return ListView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: myResources.length,
      itemBuilder: (context, index) {
        final r = myResources[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    "${ApiConstants.serverBaseUrl}/uploads/${r.image}",
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.image_not_supported),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      Text("Price: ₹${r.price}", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                      Text("Status: ${r.status.toUpperCase()}", style: TextStyle(color: r.status == 'approved' ? Colors.green : (r.status == 'rejected' ? Colors.red : Colors.orange), fontWeight: FontWeight.bold, fontSize: 12)),
                      if (r.status == 'rejected' && r.rejectionReason != null && r.rejectionReason!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            "Reason: ${r.rejectionReason}",
                            style: const TextStyle(color: Colors.red, fontSize: 11, fontStyle: FontStyle.italic),
                          ),
                        ),
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () async {
                        final res = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => EditAgriResourceScreen(resource: r)),
                        );
                        if (res == true) _fetchData();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        final bool? confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Delete Resource"),
                            content: const Text("Are you sure you want to delete this listing?"),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
                              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete", style: TextStyle(color: Colors.red))),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          final success = await _service.deleteResource(r.id);
                          if (success) _fetchData();
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrdersReceived() {
    if (orders.isEmpty) return const Center(child: Text("No orders received"));
    return ListView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final o = orders[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: ExpansionTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: o.resourceImage != null
                  ? Image.network(
                      "${ApiConstants.serverBaseUrl}/uploads/${o.resourceImage}",
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    )
                  : Container(width: 50, height: 50, color: Colors.grey.shade200, child: const Icon(Icons.category)),
            ),
            title: Text(o.resourceName ?? 'Unknown Material', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("Buyer: ${o.buyerName} | Status: ${o.status}"),
            children: [
              Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(),
                    Text("Payment Method: ${o.paymentMethod}"),
                    Text("Buyer Phone: ${o.buyerPhone}"),
                    Text("Price: ₹${o.price}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                    const SizedBox(height: 10),
                    if (o.status == 'pending')
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              final success = await _service.acceptOrder(o.id);
                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Order accepted successfully")));
                                _fetchData();
                              }
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                            child: const Text("Accept Order"),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
