
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

// ==========================================================
// ORDER CONTROLLER
// ==========================================================

const {
  createOrder,
  getUserOrders,
  getFarmerOrders,
  getOrderById,
  acceptOrder,
  rejectOrder,
  updateOrderStatus,
  cancelOrder,
  getAllOrders,
} = require("../controllers/orderController");

// ==========================================================
// CREATE ORDER
// USER
// ==========================================================

// POST /api/orders

router.post(
  "/",
  authenticateToken,
  requireUser,
  createOrder
);

// ==========================================================
// USER ORDERS
// ==========================================================

// GET /api/orders/user
//
// User ID comes from JWT.

router.get(
  "/user",
  authenticateToken,
  requireUser,
  getUserOrders
);

// ==========================================================
// FARMER ORDERS
// ==========================================================

// GET /api/orders/farmer
//
// Farmer ID comes from JWT.

router.get(
  "/farmer",
  authenticateToken,
  requireFarmer,
  getFarmerOrders
);

// ==========================================================
// ADMIN - ALL ORDERS
// ==========================================================

// GET /api/orders/admin/all

router.get(
  "/admin/all",
  authenticateToken,
  requireAdmin,
  getAllOrders
);

// ==========================================================
// FARMER ACCEPT ORDER
// ==========================================================

// PUT /api/orders/:id/accept

router.put(
  "/:id/accept",
  authenticateToken,
  requireFarmer,
  acceptOrder
);

// ==========================================================
// FARMER REJECT ORDER
// ==========================================================

// PUT /api/orders/:id/reject

router.put(
  "/:id/reject",
  authenticateToken,
  requireFarmer,
  rejectOrder
);

// ==========================================================
// UPDATE ORDER STATUS
// ==========================================================
//
// This controller should verify the authenticated role
// and ownership before changing the order.

router.put(
  "/:id/status",
  authenticateToken,
  updateOrderStatus
);

// ==========================================================
// USER CANCEL ORDER
// ==========================================================

// PUT /api/orders/:id/cancel

router.put(
  "/:id/cancel",
  authenticateToken,
  requireUser,
  cancelOrder
);

// ==========================================================
// GET ORDER BY ID
// ==========================================================
//
// Any authenticated account can view an order only if the
// orderController verifies that the user is allowed to see it.

router.get(
  "/:id",
  authenticateToken,
  getOrderById
);

// ==========================================================
// EXPORT
// ==========================================================

module.exports = router;
