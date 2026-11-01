import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../../core/constants/api_constants.dart';
import '../../core/constants/theme/auth_theme.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  List<dynamic> users = [];
  List<dynamic> filteredUsers = [];
  bool isLoading = true;
  String selectedRoleFilter = 'All'; // 'All', 'farmer', 'user'
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchUsers() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("adminToken") ?? prefs.getString("token");

      final response = await http.get(
        Uri.parse("${ApiConstants.adminUrl}/users"),
        headers: {
          "Content-Type": "application/json",
          if (token != null) "Authorization": "Bearer $token",
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            users = data["users"] ?? [];
            isLoading = false;
            _applyFilters();
          });
        }
      } else {
        if (mounted) {
          setState(() => isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Failed to load users: ${response.statusCode}"),
              backgroundColor: const Color(0xFFDC2626),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("FETCH USERS ERROR: $e");
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Connection Error. Please check backend server."),
            backgroundColor: Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _applyFilters() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      filteredUsers = users.where((u) {
        final role = (u["role"] ?? "user").toString().toLowerCase();

        final matchesRole = selectedRoleFilter == 'All' ||
            (selectedRoleFilter == 'farmer' && role == 'farmer') ||
            (selectedRoleFilter == 'user' && role != 'farmer');

        final name = (u["name"] ?? "").toString().toLowerCase();
        final email = (u["email"] ?? "").toString().toLowerCase();
        final phone = (u["phone"] ?? "").toString().toLowerCase();
        final farm = (u["farmName"] ?? "").toString().toLowerCase();
        final loc = (u["farmLocation"] ?? "").toString().toLowerCase();

        final matchesQuery = query.isEmpty ||
            name.contains(query) ||
            email.contains(query) ||
            phone.contains(query) ||
            farm.contains(query) ||
            loc.contains(query);

        return matchesRole && matchesQuery;
      }).toList();
    });
  }

  String formatDate(String? dateStr) {
    if (dateStr == null) return "N/A";
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy, hh:mm a').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final farmerCount = users.where((u) => u["role"] == "farmer").length;
    final customerCount = users.where((u) => u["role"] != "farmer").length;

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
                                  "Users & Farmers",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: -0.3,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              AdminTheme.limeChip("${users.length} TOTAL"),
                            ],
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            "Directory of registered platform accounts",
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
                        tooltip: "Refresh accounts",
                        onPressed: fetchUsers,
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
          // SEARCH BAR (CYBER LIME)
          // ==========================================
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Container(
              decoration: BoxDecoration(
                color: AdminTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AdminTheme.border),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                onChanged: (_) => _applyFilters(),
                decoration: InputDecoration(
                  hintText: "Search by name, email, phone, location...",
                  hintStyle: const TextStyle(
                    color: AdminTheme.textMuted,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w400,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AdminTheme.lime,
                    size: 22,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded, size: 18, color: AdminTheme.textMuted),
                          onPressed: () {
                            _searchController.clear();
                            _applyFilters();
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
          ),

          // ==========================================
          // ROLE SELECTOR CHIPS (LIME REFERENCE PILLS)
          // ==========================================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                _roleChip("All Accounts", "All", users.length),
                const SizedBox(width: 8),
                _roleChip("Farmers", "farmer", farmerCount),
                const SizedBox(width: 8),
                _roleChip("Customers", "user", customerCount),
              ],
            ),
          ),

          const SizedBox(height: 6),

          // ==========================================
          // LIST OF USERS
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
                          "Loading platform accounts...",
                          style: TextStyle(
                            color: AdminTheme.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : filteredUsers.isEmpty
                    ? _emptyView()
                    : RefreshIndicator(
                        color: AdminTheme.lime,
                        backgroundColor: AdminTheme.surface,
                        onRefresh: fetchUsers,
                        child: ListView.builder(
                          physics: const BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics(),
                          ),
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                          itemCount: filteredUsers.length,
                          itemBuilder: (ctx, i) => _userCard(filteredUsers[i]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _roleChip(String label, String value, int count) {
    final isSelected = selectedRoleFilter == value;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            selectedRoleFilter = value;
            _applyFilters();
          });
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? AdminTheme.lime : AdminTheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? AdminTheme.lime : AdminTheme.border,
              width: 1.2,
            ),
            boxShadow: isSelected
                ? const [
                    BoxShadow(
                      color: Color(0x5500FF00),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: isSelected ? Colors.black : Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? Colors.black87 : AdminTheme.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _userCard(dynamic u) {
    final bool isFarmer = u["role"] == "farmer";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AdminTheme.cardDecoration(glow: false),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          collapsedIconColor: AdminTheme.textSecondary,
          iconColor: AdminTheme.lime,
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isFarmer ? AdminTheme.lime.withValues(alpha: 0.15) : const Color(0x2238BDF8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isFarmer ? AdminTheme.limeBorder : const Color(0x4438BDF8),
              ),
            ),
            child: Icon(
              isFarmer ? Icons.agriculture_rounded : Icons.person_rounded,
              color: isFarmer ? AdminTheme.lime : const Color(0xFF38BDF8),
              size: 22,
            ),
          ),
          title: Text(
            u["name"] ?? "Registered Account",
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 15.5,
              color: Colors.white,
            ),
          ),
          subtitle: Row(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: isFarmer ? AdminTheme.lime.withValues(alpha: 0.15) : const Color(0x2238BDF8),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isFarmer ? AdminTheme.limeBorder : const Color(0x4438BDF8),
                  ),
                ),
                child: Text(
                  isFarmer ? "FARMER" : "CUSTOMER",
                  style: TextStyle(
                    color: isFarmer ? AdminTheme.lime : const Color(0xFF38BDF8),
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (u["phone"] != null && u["phone"].toString().isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    u["phone"].toString(),
                    style: const TextStyle(fontSize: 12, color: AdminTheme.textSecondary),
                  ),
                ),
              ],
            ],
          ),
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  const Divider(height: 1, color: AdminTheme.border),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AdminTheme.surfaceElevated,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AdminTheme.border),
                    ),
                    child: Column(
                      children: [
                        _detailItem(Icons.phone_rounded, "Phone Number", u["phone"] ?? "Not provided"),
                        const SizedBox(height: 8),
                        _detailItem(Icons.mail_rounded, "Email Address", u["email"] ?? "Not provided"),
                        if (isFarmer) ...[
                          const SizedBox(height: 8),
                          _detailItem(Icons.home_work_rounded, "Farm / Organization", u["farmName"] ?? "Individual Grower"),
                          const SizedBox(height: 8),
                          _detailItem(Icons.location_on_rounded, "Farm Location", u["farmLocation"] ?? "Not provided"),
                        ],
                        const SizedBox(height: 8),
                        _detailItem(Icons.calendar_today_rounded, "Registered Date", formatDate(u["createdAt"])),
                      ],
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

  Widget _detailItem(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AdminTheme.lime),
        const SizedBox(width: 8),
        Text(
          "$label: ",
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 12.5,
            color: AdminTheme.textSecondary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _emptyView() {
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
              Icons.people_outline_rounded,
              size: 48,
              color: AdminTheme.lime,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "No Accounts Found",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "No users or farmers match your search or filter criteria.",
            style: TextStyle(fontSize: 13, color: AdminTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}
