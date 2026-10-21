import 'package:flutter/material.dart';
import '../../models/notification_model.dart';
import '../../services/notification_service.dart';
import '../farmer/farmer_home_screen.dart';
import '../agri_resources/farmer_agri_resources_screen.dart';

class NotificationsListScreen extends StatefulWidget {
  const NotificationsListScreen({super.key});

  @override
  State<NotificationsListScreen> createState() => _NotificationsListScreenState();
}

class _NotificationsListScreenState extends State<NotificationsListScreen> {
  final NotificationService _service = NotificationService();
  List<NotificationModel> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() => isLoading = true);
    final list = await _service.getNotifications();
    setState(() {
      notifications = list;
      isLoading = false;
    });
  }

  void _handleTap(NotificationModel notification) async {
    // Mark as read
    if (!notification.isRead) {
      await _service.markAsRead(notification.id);
    }

    if (!mounted) return;

    final String screen = notification.data['screen'] ?? '';

    if (screen == 'orders') {
      // Navigate to Farmer Home Screen -> Orders Tab (index 2)
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const FarmerHomeScreen(initialIndex: 2)),
        (route) => false,
      );
    } else if (screen == 'agri_resources_orders') {
      // Navigate to Farmer Agri Resources Screen -> Orders Received Tab
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const FarmerAgriResourcesScreen(initialTab: 1)),
      );
    } else {
      // Default: Refresh list
      _fetchNotifications();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F2),
      appBar: AppBar(
        title: const Text("Notifications"),
        centerTitle: true,
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : notifications.isEmpty
              ? _emptyView()
              : RefreshIndicator(
                  onRefresh: _fetchNotifications,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) => _notificationTile(notifications[index]),
                  ),
                ),
    );
  }

  Widget _emptyView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 80, color: Colors.grey),
          SizedBox(height: 15),
          Text("No notifications yet", style: TextStyle(color: Colors.grey, fontSize: 18)),
        ],
      ),
    );
  }

  Widget _notificationTile(NotificationModel n) {
    return Card(
      elevation: n.isRead ? 0 : 3,
      color: n.isRead ? Colors.white70 : Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: () => _handleTap(n),
        leading: CircleAvatar(
          backgroundColor: _getTypeColor(n.type).withValues(alpha: 0.1),
          child: Icon(_getTypeIcon(n.type), color: _getTypeColor(n.type)),
        ),
        title: Text(n.title, style: TextStyle(fontWeight: n.isRead ? FontWeight.normal : FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(n.message),
            const SizedBox(height: 5),
            Text(
              _formatDate(n.createdAt),
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        trailing: n.isRead ? null : const CircleAvatar(radius: 5, backgroundColor: Colors.orange),
      ),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'order': return Icons.shopping_bag;
      case 'product': return Icons.inventory_2;
      case 'account': return Icons.person;
      default: return Icons.notifications;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'order': return Colors.orange;
      case 'product': return Colors.orangeAccent;
      default: return Colors.blue;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) return "${diff.inMinutes} mins ago";
    if (diff.inHours < 24) return "${diff.inHours} hours ago";
    return "${date.day}/${date.month}/${date.year}";
  }
}
