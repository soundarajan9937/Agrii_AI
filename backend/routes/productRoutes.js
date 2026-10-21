
const express = require("express");

const router = express.Router();

// ==========================================================
// AUTH MIDDLEWARE
// ==========================================================

const {
  authenticateToken,
  requireAdmin,
  requireFarmer,
  requireUser,
} = require("../middleware/authMiddleware");

const upload = require("../middleware/upload");

// ==========================================================
// PRODUCT CONTROLLER
// ==========================================================

const {
  createProduct,
  getApprovedProducts,
  getProductById,
  getMyProducts,
  getPendingProducts,
  approveProduct,
  rejectProduct,
  updateProduct,
  deleteProduct,
} = require("../controllers/productController");

// ==========================================================
// USER MARKETPLACE
// ==========================================================

router.get(
  "/",
  authenticateToken,
  requireUser,
  getApprovedProducts
);

// ==========================================================
// FARMER PRODUCTS
// ==========================================================

router.get(
  "/my",
  authenticateToken,
  requireFarmer,
  getMyProducts
);

// ==========================================================
// ADMIN - PENDING PRODUCTS
// ==========================================================

router.get(
  "/admin/pending",
  authenticateToken,
  requireAdmin,
  getPendingProducts
);

// ==========================================================
// ADMIN - APPROVE PRODUCT
// ==========================================================

router.put(
  "/admin/approve/:id",
  authenticateToken,
  requireAdmin,
  approveProduct
);

// ==========================================================
// ADMIN - REJECT PRODUCT
// ==========================================================

router.put(
  "/admin/reject/:id",
  authenticateToken,
  requireAdmin,
  rejectProduct
);

// ==========================================================
// FARMER CREATE PRODUCT
// ==========================================================

router.post(
  "/",
  authenticateToken,
  requireFarmer,
  upload.single("image"),
  createProduct
);

// ==========================================================
// FARMER UPDATE PRODUCT
// ==========================================================

router.put(
  "/:id",
  authenticateToken,
  requireFarmer,
  upload.single("image"),
  updateProduct
);

// ==========================================================
// FARMER DELETE PRODUCT
// ==========================================================

router.delete(
  "/:id",
  authenticateToken,
  requireFarmer,
  deleteProduct
);

// ==========================================================
// GET SINGLE PRODUCT
// ==========================================================

router.get(
  "/:id",
  authenticateToken,
  getProductById
);

// ==========================================================
// EXPORT
// ==========================================================

module.exports = router;
