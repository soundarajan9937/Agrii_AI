const express = require("express");
const router = express.Router();
const controller = require("../controllers/agriResourceController");
const adminController = require("../controllers/adminAgriResourceController");
const {
  authenticateToken,
  requireAdmin,
  requireFarmer
} = require("../middleware/authMiddleware");
const multer = require("multer");
const path = require("path");

// Configure Multer for Image Upload
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, "uploads/");
  },
  filename: (req, file, cb) => {
    cb(null, "resource-" + Date.now() + path.extname(file.originalname));
  },
});
const upload = multer({ storage });

// Farmer Routes
router.post("/add", authenticateToken, requireFarmer, upload.single("image"), controller.addResource);
router.get("/my-resources", authenticateToken, requireFarmer, controller.getMyResources);
router.get("/farmer-orders", authenticateToken, requireFarmer, controller.getFarmerOrders);
router.put("/order/accept/:id", authenticateToken, requireFarmer, controller.acceptOrder);
router.put("/update/:id", authenticateToken, requireFarmer, upload.single("image"), controller.updateResource);
router.delete("/delete/:id", authenticateToken, requireFarmer, controller.deleteResource);

// User Routes
router.get("/approved", authenticateToken, controller.getApprovedResources);
router.post("/order/place", authenticateToken, controller.placeOrder);
router.get("/user-orders", authenticateToken, controller.getUserOrders);
router.put("/order/cancel/:id", authenticateToken, controller.cancelOrder);

// Admin Routes
router.get("/admin/all", authenticateToken, requireAdmin, adminController.getAllResources);
router.put("/admin/status/:id", authenticateToken, requireAdmin, adminController.updateResourceStatus);

module.exports = router;
