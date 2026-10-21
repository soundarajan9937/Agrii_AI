import 'package:flutter/material.dart';
import '../../models/agri_resource_model.dart';
import '../../services/agri_resource_service.dart';
import '../../core/constants/api_constants.dart';
import 'agri_resource_order_screen.dart';

class AgriResourcesScreen extends StatefulWidget {
  const AgriResourcesScreen({super.key});

  @override
  State<AgriResourcesScreen> createState() => _AgriResourcesScreenState();
}

class _AgriResourcesScreenState extends State<AgriResourcesScreen> {
  final AgriResourceService _service = AgriResourceService();
  List<AgriResourceModel> resources = [];
  bool isLoading = true;
  String selectedCategory = 'All';

  final List<String> categories = [
    'All',
    'Crop Residues',
    'Vegetable Waste',
    'Fruit Waste',
    'Animal Waste',
    'Coconut Waste',
    'Sugarcane Waste',
    'Oilseed & Nut Waste',
    'Weed & Green Waste',
    'Agri-Processing Waste',
    'Other Organic Farm Waste',
    'Agri Tools & Equipment'
  ];

  @override
  void initState() {
    super.initState();
    _fetchResources();
  }

  Future<void> _fetchResources() async {
    setState(() => isLoading = true);
    final list = await _service.getApprovedResources();
    setState(() {
      resources = list;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = selectedCategory == 'All'
        ? resources
        : resources.where((r) => r.category == selectedCategory).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F2),
      appBar: AppBar(
        title: const Text("Agri Resources & Materials"),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 22),
            onPressed: _fetchResources,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCategoryFilter(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.blue))
                : filtered.isEmpty
                    ? const Center(child: Text("No resources found"))
                    : ListView.builder(
                        padding: const EdgeInsets.all(15),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) => _resourceCard(filtered[index]),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ChoiceChip(
              label: Text(cat),
              selected: isSelected,
              onSelected: (val) => setState(() => selectedCategory = cat),
              selectedColor: Colors.blue,
              labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
            ),
          );
        },
      ),
    );
  }

  Widget _resourceCard(AgriResourceModel resource) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: Image.network(
              "${ApiConstants.serverBaseUrl}/uploads/${resource.image}",
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 180,
                color: Colors.grey.shade200,
                child: const Icon(Icons.image_not_supported, size: 50),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(resource.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text("₹${resource.price}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
                  ],
                ),
                const SizedBox(height: 5),
                Text("Category: ${resource.category}", style: const TextStyle(color: Colors.grey)),
                Text("Seller: ${resource.sellerName}", style: const TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 10),
                if (resource.description != null && resource.description!.isNotEmpty)
                  Text(resource.description!, maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => AgriResourceOrderScreen(resource: resource)));
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                    child: const Text("Order Now"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
