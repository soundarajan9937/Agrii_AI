class ApiConstants {
  // ==========================================================
  // SERVER CONFIGURATION
  // ==========================================================

  // Your computer's current local network IP address.
  // Updated based on your ipconfig output: 10.116.232.78
  static const String serverIp = "10.116.232.78";

  // Node.js backend port
  static const String port = "5000";

  // ==========================================================
  // BASE URL
  // ==========================================================

  // http://10.116.232.78:5000/api
  static const String baseUrl = "http://$serverIp:$port/api";

  // ==========================================================
  // AUTHENTICATION
  // ==========================================================

  // /api/users
  static const String authUrl = "$baseUrl/users";

  // ==========================================================
  // ADMIN
  // ==========================================================

  // /api/admin
  static const String adminUrl = "$baseUrl/admin";

  // ==========================================================
  // PRODUCTS / MARKETPLACE
  // ==========================================================

  // /api/products
  static const String productUrl = "$baseUrl/products";

  // ==========================================================
  // ORDERS
  // ==========================================================

  // /api/orders
  static const String orderUrl = "$baseUrl/orders";

  // ==========================================================
  // PAYMENTS
  // ==========================================================

  // /api/payments
  static const String paymentUrl = "$baseUrl/payments";

  // ==========================================================
  // NOTIFICATIONS
  // ==========================================================

  // /api/notifications
  static const String notificationUrl = "$baseUrl/notifications";

  // ==========================================================
  // TRACKING
  // ==========================================================

  // /api/tracking
  static const String trackingUrl = "$baseUrl/tracking";

  // ==========================================================
  // CROP ADVISOR
  // ==========================================================

  // /api/crop-advisor
  static const String cropAdvisorUrl = "$baseUrl/crop-advisor";

  // Keep cropUrl for existing files.
  static const String cropUrl = cropAdvisorUrl;

  // ==========================================================
  // DISEASE DETECTION
  // ==========================================================

  // /api/disease
  static const String diseaseUrl = "$baseUrl/disease";

  // Gallery:
  // POST /api/disease/upload
  static const String diseaseUploadUrl = "$diseaseUrl/upload";

  // Camera Scan:
  // POST /api/disease/scan
  static const String diseaseScanUrl = "$diseaseUrl/scan";

  // ==========================================================
  // CHATBOT
  // ==========================================================

  // /api/chatbot
  static const String chatbotUrl = "$baseUrl/chatbot";

  // POST /api/chatbot/message
  static const String chatbotMessageUrl = "$chatbotUrl/message";

  // ==========================================================
  // AGRI RESOURCES & MATERIALS
  // ==========================================================

  static const String agriResourceUrl = "$baseUrl/agri-resources";

  // ==========================================================
  // IMAGE BASE URL
  // ==========================================================

  // Example:
  // http://10.116.232.78:5000/uploads/filename.jpg
  static const String imageBaseUrl = "http://$serverIp:$port/uploads/";

  // ==========================================================
  // SERVER ROOT
  // ==========================================================

  // http://10.116.232.78:5000
  static const String serverBaseUrl = "http://$serverIp:$port";
}
