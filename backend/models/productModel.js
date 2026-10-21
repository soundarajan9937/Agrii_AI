const mongoose = require("mongoose");

const productSchema = new mongoose.Schema(
  {
    // ======================================================
    // PRODUCT INFORMATION
    // ======================================================

    name: {
      type: String,
      required: true,
      trim: true,
    },

    category: {
      type: String,
      required: true,
      trim: true,
    },

    description: {
      type: String,
      default: "",
      trim: true,
    },

    // ======================================================
    // PRICE
    // ======================================================

    price: {
      type: Number,
      required: true,
      min: 0,
    },

    // ======================================================
    // QUANTITY
    // ======================================================

    quantity: {
      type: Number,
      required: true,
      min: 0,
    },

    unit: {
      type: String,
      default: "Kg",
      trim: true,
    },

    // ======================================================
    // IMAGE
    // ======================================================

    image: {
      type: String,
      default: "",
    },

    // ======================================================
    // FARMER / SELLER
    // IMPORTANT:
    // Farmer is stored in the "farmers" collection.
    // ======================================================

    seller: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Farmer",
      required: true,
    },

    sellerName: {
      type: String,
      default: "",
      trim: true,
    },

    sellerPhone: {
      type: String,
      default: "",
      trim: true,
    },

    sellerLocation: {
      type: String,
      default: "",
      trim: true,
    },

    // ======================================================
    // ADMIN APPROVAL
    // ======================================================

    approvalStatus: {
      type: String,
      enum: ["pending", "approved", "rejected"],
      default: "pending",
    },

    rejectionReason: {
      type: String,
      default: "",
      trim: true,
    },

    approvedAt: {
      type: Date,
      default: null,
    },

    rejectedAt: {
      type: Date,
      default: null,
    },

    approvedBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Admin",
      default: null,
    },

    // ======================================================
    // PRODUCT STATUS
    // ======================================================

    isActive: {
      type: Boolean,
      default: true,
    },

    isDeleted: {
      type: Boolean,
      default: false,
    },

    deletedAt: {
      type: Date,
      default: null,
    },

    // ======================================================
    // MARKETPLACE
    // ======================================================

    isMarketplaceVisible: {
      type: Boolean,
      default: false,
    },
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model("Product", productSchema);