import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../../services/marketplace_api_service.dart';
import '../../core/constants/api_constants.dart';
import 'product_details_screen.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  final MarketplaceApiService _apiService = MarketplaceApiService();
  List<ProductModel> products = [];
  List<ProductModel> filteredProducts = [];
  bool isLoading = true;
  String selectedCategory = "All";
  final TextEditingController _searchController = TextEditingController();

  final List<String> categories = [
    "All",
    "Vegetables",
    "Fruits",
    "Grains",
    "Seeds",
    "Fertilizers",
    "Tools"
  ];

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() => isLoading = true);
    try {
      final List<dynamic> data = await _apiService.getProducts();
      if (mounted) {
        setState(() {
          products = data.map((json) => ProductModel.fromJson(json)).toList();
          isLoading = false;
          // Re-apply current filter after data is loaded
          _filterProducts(_searchController.text);
        });
      }
    } catch (e) {
      debugPrint("FETCH PRODUCTS ERROR: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _filterProducts(String query) {
    setState(() {
      filteredProducts = products.where((product) {
        final matchesQuery = product.name.toLowerCase().contains(query.toLowerCase());
        final matchesCategory = selectedCategory == "All" || product.category == selectedCategory;
        return matchesQuery && matchesCategory;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          // ==========================================
          // HEADER & SEARCH
          // ==========================================
          SliverAppBar(
            expandedHeight: 180.0,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF1976D2),
            flexibleSpace: FlexibleSpaceBar(
              title: const Text("Agrii Marketplace", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 60),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, 5))],
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: _filterProducts,
                          decoration: const InputDecoration(
                            hintText: "Search fresh products...",
                            border: InputBorder.none,
                            icon: Icon(Icons.search, color: Color(0xFF1976D2)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchProducts),
            ],
          ),

          // ==========================================
          // CATEGORY SELECTOR
          // ==========================================
          SliverToBoxAdapter(
            child: SizedBox(
              height: 70,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final isSelected = selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      onSelected: (val) {
                        setState(() {
                          selectedCategory = cat;
                          _filterProducts(_searchController.text);
                        });
                      },
                      selectedColor: const Color(0xFF1976D2),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      backgroundColor: Colors.white,
                      elevation: 2,
                      pressElevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                  );
                },
              ),
            ),
          ),

          // ==========================================
          // PRODUCT GRID
          // ==========================================
          isLoading
              ? const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: Color(0xFF1976D2))))
              : filteredProducts.isEmpty
                  ? SliverFillRemaining(child: _emptyView())
                  : SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.65,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _productCard(filteredProducts[index]),
                          childCount: filteredProducts.length,
                        ),
                      ),
                    ),
        ],
      ),
    );
  }

  Widget _emptyView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.search_off, size: 80, color: Colors.grey),
        const SizedBox(height: 15),
        const Text("No matches found", style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.w500)),
        TextButton(onPressed: () {
          setState(() {
            _searchController.clear();
            selectedCategory = "All";
            filteredProducts = products;
          });
        }, child: const Text("Clear Filters", style: TextStyle(color: Color(0xFF1976D2)))),
      ],
    );
  }

  Widget _productCard(ProductModel product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailsScreen(product: product)));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: product.image.isNotEmpty
                        ? Image.network(
                            ApiConstants.imageBaseUrl + product.image,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                          )
                        : const Icon(Icons.inventory_2, size: 40, color: Colors.grey),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        product.category,
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF1976D2)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // DETAILS
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.person, size: 12, color: Colors.grey),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                product.sellerName,
                                style: const TextStyle(color: Colors.grey, fontSize: 11),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "₹${product.price.toStringAsFixed(0)}",
                          style: const TextStyle(color: Color(0xFF1976D2), fontWeight: FontWeight.bold, fontSize: 17),
                        ),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Color(0xFF1976D2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.add_shopping_cart, color: Colors.white, size: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
