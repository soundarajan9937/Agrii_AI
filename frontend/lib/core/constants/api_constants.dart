class ApiConstants {
  // ==========================================================
  // ENVIRONMENT CONFIGURATION
  // ==========================================================

  // Set to TRUE when building APK with real Render deployed backend
  // Set to FALSE when running locally on Wi-Fi (default)
  static const bool isProduction = false;

  // Paste your Render deployed backend URL here (NO trailing slash, NO /api):
  // Example: "https://agrii-ai.onrender.com"
  static const String renderUrl = "https://YOUR-RENDER-APP-NAME.onrender.com";

  // Local development settings (your PC's local Wi-Fi IP):
  static const String localServerIp = "10.116.232.78";
  static const String localPort = "5000";

  // Base Server URL
  // Set isProduction to false for local Wi-Fi development (default)
  // Set isProduction to true only when renderUrl is updated with a real deployed URL
  static const String serverBaseUrl =
      isProduction ? renderUrl : "http://$localServerIp:$localPort";

  // Maintained for backward compatibility
  static const String serverIp = isProduction ? renderUrl : localServerIp;
  static const String port = isProduction ? "443" : localPort;

  // ==========================================================
  // BASE URL
  // ==========================================================

  static const String baseUrl = "$serverBaseUrl/api";

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
  // https://your-render-url.onrender.com/uploads/filename.jpg
  // http://10.116.232.78:5000/uploads/filename.jpg
  static const String imageBaseUrl = "$serverBaseUrl/uploads/";
}
