
const express = require("express");

const router = express.Router();

const {
  authenticateToken,
  requireAdmin,
} = require("../middleware/authMiddleware");

const {
  adminLogin,
  getDashboardStats,
  getUsers,
  getProducts,
  approveProduct,
  rejectProduct,
  getOrders,
  updateOrderStatus,
  getPayments,
} = require("../controllers/adminController");

// ==========================================================
// ADMIN LOGIN
//
// POST /api/admin/login
//
// Login does NOT require a token.
// ==========================================================

router.post(
  "/login",
  adminLogin
);

// ==========================================================
// PROTECTED ADMIN ROUTES
//
// Every route below requires:
// 1. Valid JWT
// 2. role === admin
// ==========================================================

router.use(
  authenticateToken,
  requireAdmin
);

// ==========================================================
// ADMIN DASHBOARD
//
// GET /api/admin/dashboard
// ==========================================================

router.get(
  "/dashboard",
  getDashboardStats
);

// ==========================================================
// USERS
//
// GET /api/admin/users
// ==========================================================

router.get(
  "/users",
  getUsers
);

// ==========================================================
// PRODUCTS
//
// GET /api/admin/products
// ==========================================================

router.get(
  "/products",
  getProducts
);

// ==========================================================
// APPROVE PRODUCT
//
// PUT /api/admin/products/:id/approve
// ==========================================================

router.put(
  "/products/:id/approve",
  approveProduct
);

// ==========================================================
// REJECT PRODUCT
//
// PUT /api/admin/products/:id/reject
// ==========================================================

router.put(
  "/products/:id/reject",
  rejectProduct
);

// ==========================================================
// ORDERS
//
// GET /api/admin/orders
// ==========================================================

router.get(
  "/orders",
  getOrders
);

// ==========================================================
// UPDATE ORDER STATUS
//
// PUT /api/admin/orders/:id/status
// ==========================================================

router.put(
  "/orders/:id/status",
  updateOrderStatus
);

// ==========================================================
// PAYMENTS
//
// GET /api/admin/payments
// ==========================================================

router.get(
  "/payments",
  getPayments
);

// ==========================================================
// EXPORT
// ==========================================================

module.exports = router;
