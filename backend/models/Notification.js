const mongoose = require("mongoose");

const notificationSchema = new mongoose.Schema(
  {
    // ==========================================
    // RECIPIENT OF NOTIFICATION
    // ==========================================
    // Can be a User, Farmer, or Admin
    recipient: {
      type: mongoose.Schema.Types.ObjectId,
      required: true,
      refPath: "recipientModel",
    },

    recipientModel: {
      type: String,
      required: true,
      enum: ["User", "Farmer", "Admin"],
      default: "User",
    },

    // ==========================================
    // NOTIFICATION TITLE
    // ==========================================

    title: {
      type: String,
      required: true,
    },

    // ==========================================
    // NOTIFICATION MESSAGE
    // ==========================================

    message: {
      type: String,
      required: true,
    },

    // ==========================================
    // NOTIFICATION TYPE
    // ==========================================

    type: {
      type: String,

      enum: [
        "order",
        "payment",
        "product",
        "delivery",
        "account",
        "system",
      ],

      default: "system",
    },

    // ==========================================
    // RELATED ORDER
    // ==========================================

    order: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Order",
      default: null,
    },

    // ==========================================
    // RELATED PRODUCT
    // ==========================================

    product: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Product",
      default: null,
    },

    // ==========================================
    // READ STATUS
    // ==========================================

    isRead: {
      type: Boolean,
      default: false,
    },

    // ==========================================
    // OPTIONAL DATA
    // ==========================================

    data: {
      type: mongoose.Schema.Types.Mixed,
      default: {},
    },
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model(
  "Notification",
  notificationSchema
);
