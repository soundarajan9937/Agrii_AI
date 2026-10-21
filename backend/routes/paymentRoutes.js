const express = require("express");

const router = express.Router();

const {
  createPayment,
  getPaymentById,
  getPaymentHistory,
  updatePaymentStatus,
} = require("../controllers/paymentController");

// ==========================================
// CREATE PAYMENT
//
// POST /api/payments/create
// ==========================================

router.post("/create", createPayment);

// ==========================================
// GET PAYMENT
//
// GET /api/payments/:id
// ==========================================

router.get("/:id", getPaymentById);

// ==========================================
// PAYMENT HISTORY
//
// GET /api/payments/history
// ==========================================

router.get("/history", getPaymentHistory);

// ==========================================
// UPDATE PAYMENT STATUS
//
// PUT /api/payments/:id/status
// ==========================================

router.put("/:id/status", updatePaymentStatus);

module.exports = router;