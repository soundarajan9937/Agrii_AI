
const dns = require("dns");
try {
  dns.setServers(["8.8.8.8", "8.8.4.4"]);
} catch (e) {}

const express = require("express");
const cors = require("cors");
const dotenv = require("dotenv");
const path = require("path");

const connectDB = require("./config/db");

dotenv.config();

const app = express();

// ==========================================================
// CONFIGURATION
// ==========================================================

const PORT = process.env.PORT || 5000;

// ==========================================================
// MIDDLEWARE
// ==========================================================

app.use(cors());

app.use(express.json());

app.use(
  express.urlencoded({
    extended: true,
  })
);

// ==========================================================
// STATIC UPLOADS
// ==========================================================

app.use(
  "/uploads",
  express.static(
    path.join(__dirname, "uploads")
  )
);

// ==========================================================
// ROUTES
// ==========================================================

const userRoutes = require("./routes/userRoutes");
const productRoutes = require("./routes/productRoutes");
const orderRoutes = require("./routes/orderRoutes");
const paymentRoutes = require("./routes/paymentRoutes");
const adminRoutes = require("./routes/adminRoutes");
const notificationRoutes = require("./routes/notificationRoutes");

const cropAdvisorRoutes = require("./routes/cropAdvisorRoutes");
const chatbotRoutes = require("./routes/chatbotRoutes");
const agriResourceRoutes = require("./routes/agriResourceRoutes");

// ==========================================================
// API ROUTES
// ==========================================================

// USERS / FARMERS
app.use(
  "/api/users",
  userRoutes
);

// PRODUCTS / MARKETPLACE
app.use(
  "/api/products",
  productRoutes
);

// ORDERS
app.use(
  "/api/orders",
  orderRoutes
);

// PAYMENTS
app.use(
  "/api/payments",
  paymentRoutes
);

// ADMIN
app.use(
  "/api/admin",
  adminRoutes
);

// NOTIFICATIONS
app.use(
  "/api/notifications",
  notificationRoutes
);

// ==========================================================
// CROP ADVISOR
// ==========================================================

app.use(
  "/api/crop-advisor",
  cropAdvisorRoutes
);

// ==========================================================
// CHATBOT
// ==========================================================

app.use(
  "/api/chatbot",
  chatbotRoutes
);

// ==========================================================
// AGRI RESOURCES & MATERIALS
// ==========================================================

app.use(
  "/api/agri-resources",
  agriResourceRoutes
);

// ==========================================================
// HOME / HEALTH CHECK
// ==========================================================

app.get("/", (req, res) => {
  return res.status(200).json({
    success: true,
    message: "🌱 Agrii AI Backend is Running Successfully!",
  });
});

// ==========================================================
// CROP ADVISOR HEALTH CHECK
// ==========================================================

app.get("/api/crop-advisor", (req, res) => {
  return res.status(200).json({
    success: true,
    message: "🌱 Agrii AI Crop Advisor API is Running!",
  });
});

// ==========================================================
// CHATBOT HEALTH CHECK
// ==========================================================

app.get("/api/chatbot", (req, res) => {
  return res.status(200).json({
    success: true,
    message: "🤖 Agrii AI Chatbot API is Running!",
  });
});

// ==========================================================
// 404 ROUTE
// ==========================================================

app.use((req, res) => {
  return res.status(404).json({
    success: false,
    message: "Route Not Found",
    path: req.originalUrl,
  });
});

// ==========================================================
// GLOBAL ERROR HANDLER
// ==========================================================

app.use((err, req, res, next) => {
  console.error("======================================");
  console.error("❌ GLOBAL ERROR");
  console.error(err);
  console.error("======================================");

  return res.status(err.status || 500).json({
    success: false,
    message:
      err.message ||
      "Internal Server Error",
  });
});

// ==========================================================
// START SERVER
// ==========================================================

const start = async () => {
  try {
    console.log("======================================");
    console.log("🌱 AGRII AI BACKEND");
    console.log("======================================");

    // ========================================================
    // CHECK ENVIRONMENT
    // ========================================================

    if (!process.env.MONGO_URI) {
      throw new Error(
        "MONGO_URI is missing in the .env file"
      );
    }

    if (!process.env.GEMINI_API_KEY) {
      console.warn(
        "⚠️ WARNING: GEMINI_API_KEY is missing"
      );

      console.warn(
        "⚠️ AI features will not work."
      );
    } else {
      console.log(
        "✅ Gemini API key detected"
      );
    }

    // ========================================================
    // CONNECT DATABASE
    // ========================================================

    console.log(
      "🔄 Connecting to MongoDB..."
    );

    await connectDB();

    // ========================================================
    // START EXPRESS SERVER
    // ========================================================

    app.listen(
      PORT,
      "0.0.0.0",
      () => {
        console.log(
          "======================================"
        );

        console.log(
          "🚀 Agrii AI Backend Started"
        );

        console.log(
          `📡 Network : http://10.253.175.78:${PORT}`
        );

        console.log(
          `📡 Local   : http://localhost:${PORT}`
        );

        console.log(
          `🌱 Crop Advisor: http://10.253.175.78:${PORT}/api/crop-advisor`
        );

        console.log(
          `🤖 Chatbot: http://10.253.175.78:${PORT}/api/chatbot`
        );

        console.log(
          `💬 Chatbot Message: http://10.253.175.78:${PORT}/api/chatbot/message`
        );

        console.log(
          "======================================"
        );
      }
    );

  } catch (error) {
    console.error(
      "======================================"
    );

    console.error(
      "❌ BACKEND FAILED TO START"
    );

    console.error(
      "======================================"
    );

    console.error(
      error.message
    );

    console.error(
      "======================================"
    );

    process.exit(1);
  }
};

// ==========================================================
// START APPLICATION
// ==========================================================

start();

// ==========================================================
// EXPORT APP
// ==========================================================

module.exports = app;
