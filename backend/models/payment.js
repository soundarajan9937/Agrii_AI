const mongoose = require("mongoose");

const paymentSchema = new mongoose.Schema(
  {
    // ==========================================
    // ORDER
    // ==========================================

    order: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Order",
      required: true,
    },

    // ==========================================
    // BUYER
    // ==========================================

    buyer: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },

    // ==========================================
    // AMOUNT
    // ==========================================

    amount: {
      type: Number,
      required: true,
      min: 0,
    },

    // ==========================================
    // PAYMENT METHOD
    // ==========================================

    paymentMethod: {
      type: String,
      enum: [
        "Cash on Delivery",
        "UPI",
        "Card",
        "Net Banking",
      ],
      required: true,
    },

    // ==========================================
    // PAYMENT STATUS
    // ==========================================

    status: {
      type: String,
      enum: [
        "pending",
        "paid",
        "failed",
        "refunded",
      ],
      default: "pending",
    },

    // ==========================================
    // TRANSACTION ID
    // ==========================================

    transactionId: {
      type: String,
      default: "",
    },

    // ==========================================
    // PAYMENT GATEWAY
    // ==========================================

    gateway: {
      type: String,
      default: "",
    },

    // ==========================================
    // PAYMENT DATE
    // ==========================================

    paidAt: {
      type: Date,
      default: null,
    },

    // ==========================================
    // REFUND
    // ==========================================

    refundAmount: {
      type: Number,
      default: 0,
    },

    refundDate: {
      type: Date,
      default: null,
    },
  },
  {
    timestamps: true,
  }
);

// ==========================================
// EXPORT PAYMENT MODEL
// ==========================================
//
// Prevents:
// OverwriteModelError: Cannot overwrite
// `Payment` model once compiled
//
// ==========================================

module.exports =
  mongoose.models.Payment ||
  mongoose.model("Payment", paymentSchema);