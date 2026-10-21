
const express = require("express");
const cors = require("cors");
const mongoose = require("mongoose");
const dotenv = require("dotenv");
const path = require("path");
const dns = require("dns");

try {
  dns.setServers(["8.8.8.8", "8.8.4.4"]);
} catch (e) {}

// ==========================================================
// LOAD ENVIRONMENT VARIABLES
// ==========================================================

dotenv.config();

// ==========================================================
// CREATE EXPRESS APP
// ==========================================================

const app = express();

// ==========================================================
// CONFIGURATION
// ==========================================================

const PORT = process.env.PORT || 5000;

// ==========================================================
// MIDDLEWARE
// ==========================================================

// Allow Flutter / mobile / web clients
app.use(cors());

// Parse JSON requests
app.use(express.json());

// Parse form/url-encoded requests
app.use(
  express.urlencoded({
    extended: true,
  })
);

// ==========================================================
// STATIC UPLOADS
// ==========================================================
//
// Uploaded disease images can be accessed using:
//
// http://YOUR-IP:5000/uploads/filename.jpg
//
// ==========================================================

const uploadsPath = path.join(__dirname, "uploads");

app.use(
  "/uploads",
  express.static(uploadsPath)
);

// ==========================================================
// LOAD ROUTES
// ==========================================================

// ----------------------------------------------------------
// USER ROUTES
// ----------------------------------------------------------

const userRoutes = require("./routes/userRoutes");

// ----------------------------------------------------------
// PRODUCT ROUTES
// ----------------------------------------------------------

const productRoutes = require("./routes/productRoutes");

// ----------------------------------------------------------
// ORDER ROUTES
// ----------------------------------------------------------

const orderRoutes = require("./routes/orderRoutes");

// ----------------------------------------------------------
// PAYMENT ROUTES
// ----------------------------------------------------------

const paymentRoutes = require("./routes/paymentRoutes");

// ----------------------------------------------------------
// ADMIN ROUTES
// ----------------------------------------------------------

const adminRoutes = require("./routes/adminRoutes");

// ----------------------------------------------------------
// NOTIFICATION ROUTES
// ----------------------------------------------------------

const notificationRoutes =
  require("./routes/notificationRoutes");

// ----------------------------------------------------------
// CROP ADVISOR ROUTES
// ----------------------------------------------------------

const cropAdvisorRoutes =
  require("./routes/cropAdvisorRoutes");

// ----------------------------------------------------------
// DISEASE DETECTION ROUTES
// ----------------------------------------------------------
//
// POST /api/disease/upload
// POST /api/disease/scan
//
// ----------------------------------------------------------

const diseaseRoutes =
  require("./routes/diseaseRoutes");

// ==========================================================
// REGISTER API ROUTES
// ==========================================================

// ----------------------------------------------------------
// USERS / FARMERS
// ----------------------------------------------------------

app.use(
  "/api/users",
  userRoutes
);

// ----------------------------------------------------------
// PRODUCTS / MARKETPLACE
// ----------------------------------------------------------

app.use(
  "/api/products",
  productRoutes
);

// ----------------------------------------------------------
// ORDERS
// ----------------------------------------------------------

app.use(
  "/api/orders",
  orderRoutes
);

// ----------------------------------------------------------
// PAYMENTS
// ----------------------------------------------------------

app.use(
  "/api/payments",
  paymentRoutes
);

// ----------------------------------------------------------
// ADMIN
// ----------------------------------------------------------

app.use(
  "/api/admin",
  adminRoutes
);

// ----------------------------------------------------------
// NOTIFICATIONS
// ----------------------------------------------------------

app.use(
  "/api/notifications",
  notificationRoutes
);

// ----------------------------------------------------------
// CROP ADVISOR
// ----------------------------------------------------------
//
// POST /api/crop-advisor/recommend
//
// ----------------------------------------------------------

app.use(
  "/api/crop-advisor",
  cropAdvisorRoutes
);

// ----------------------------------------------------------
// DISEASE DETECTION
// ----------------------------------------------------------
//
// Gallery:
//
// POST /api/disease/upload
//
// Camera:
//
// POST /api/disease/scan
//
// Both expect:
//
// image = uploaded image
//
// ----------------------------------------------------------

app.use(
  "/api/disease",
  diseaseRoutes
);

// ==========================================================
// HOME / SERVER HEALTH CHECK
// ==========================================================

app.get("/", (req, res) => {
  return res.status(200).json({
    success: true,
    message: "🌱 Agrii AI Backend Running",
  });
});

// ==========================================================
// CROP ADVISOR HEALTH CHECK
// ==========================================================

app.get(
  "/api/crop-advisor",
  (req, res) => {
    return res.status(200).json({
      success: true,
      message:
        "🌱 Agrii AI Crop Advisor API Running",
    });
  }
);

// ==========================================================
// DISEASE DETECTION HEALTH CHECK
// ==========================================================
//
// GET /api/disease
//
// This only checks whether the disease route is connected.
// It does NOT analyze an image.
//
// ==========================================================

app.get(
  "/api/disease",
  (req, res) => {
    return res.status(200).json({
      success: true,
      message:
        "🌿 Agrii AI Disease Detection API Running",

      endpoints: {
        upload:
          "POST /api/disease/upload",

        scan:
          "POST /api/disease/scan",
      },
    });
  }
);

// ==========================================================
// 404 ROUTE
// ==========================================================

app.use(
  (req, res) => {
    return res.status(404).json({
      success: false,
      message: "Route Not Found",
      path: req.originalUrl,
    });
  }
);

// ==========================================================
// GLOBAL ERROR HANDLER
// ==========================================================

app.use(
  (err, req, res, next) => {
    console.error("");
    console.error(
      "======================================"
    );
    console.error(
      "❌ GLOBAL ERROR"
    );
    console.error(
      "======================================"
    );

    console.error(
      err
    );

    console.error(
      "======================================"
    );

    return res.status(
      err.status || 500
    ).json({
      success: false,

      message:
        err.message ||
        "Internal Server Error",

      error:
        process.env.NODE_ENV ===
        "development"
          ? err.stack
          : undefined,
    });
  }
);

// ==========================================================
// START SERVER
// ==========================================================

const startServer = async () => {
  try {
    console.log("");
    console.log(
      "======================================"
    );
    console.log(
      "🌱 AGRII AI BACKEND"
    );
    console.log(
      "======================================"
    );

    // ========================================================
    // CHECK MONGO URI
    // ========================================================

    if (!process.env.MONGO_URI) {
      throw new Error(
        "MONGO_URI is missing in the .env file"
      );
    }

    // ========================================================
    // CHECK GEMINI API KEY
    // ========================================================

    if (!process.env.GEMINI_API_KEY) {
      console.warn(
        "⚠️ WARNING: GEMINI_API_KEY is missing."
      );

      console.warn(
        "⚠️ Disease Detection and other Gemini AI features will not work."
      );
    } else {
      console.log(
        "✅ Gemini API key detected"
      );
    }

    // ========================================================
    // UPLOAD DIRECTORY
    // ========================================================

    console.log(
      `📁 Upload directory: ${uploadsPath}`
    );

    // ========================================================
    // CONNECT MONGODB
    // ========================================================

    console.log(
      "🔄 Connecting to MongoDB..."
    );

    await mongoose.connect(
      process.env.MONGO_URI
    );

    console.log(
      "✅ MongoDB Connected"
    );

    console.log(
      `📦 Database: ${mongoose.connection.name}`
    );

    // ========================================================
    // START EXPRESS SERVER
    // ========================================================

    app.listen(
      PORT,
      "0.0.0.0",
      () => {
        console.log("");
        console.log(
          "======================================"
        );

        console.log(
          "🚀 AGRII AI BACKEND STARTED"
        );

        console.log(
          "======================================"
        );

        console.log(
          `🌍 Port: ${PORT}`
        );

        console.log(
          `🌍 Local: http://localhost:${PORT}`
        );

        console.log(
          `📱 Android Emulator: http://10.0.2.2:${PORT}`
        );

        console.log(
          `🌱 Crop Advisor: http://localhost:${PORT}/api/crop-advisor`
        );

        console.log(
          `🌿 Disease API: http://localhost:${PORT}/api/disease`
        );

        console.log(
          `📤 Disease Upload: http://localhost:${PORT}/api/disease/upload`
        );

        console.log(
          `📷 Disease Scan: http://localhost:${PORT}/api/disease/scan`
        );

        console.log(
          `📁 Uploads: http://localhost:${PORT}/uploads`
        );

        console.log(
          "======================================"
        );
      }
    );
  } catch (error) {
    console.error("");
    console.error(
      "======================================"
    );

    console.error(
      "❌ SERVER STARTUP FAILED"
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

startServer();

// ==========================================================
// EXPORT APP
// ==========================================================

module.exports = app;

