const mongoose = require("mongoose");

// ==========================================================
// ORDER STATUS VALUES
// ==========================================================

const ORDER_STATUSES = [
  "pending",
  "accepted",
  "rejected",
  "processing",
  "shipped",
  "out_for_delivery",
  "delivered",
  "cancelled",
];

// ==========================================================
// ORDER SCHEMA
// ==========================================================

const orderSchema = new mongoose.Schema(
  {
    // ======================================================
    // ORDER NUMBER
    // ======================================================

    orderNumber: {
      type: String,
      unique: true,
      index: true,
    },

    // ======================================================
    // BUYER / USER
    // ======================================================

    buyer: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
      index: true,
    },

    buyerName: {
      type: String,
      required: true,
      trim: true,
    },

    buyerEmail: {
      type: String,
      default: "",
      trim: true,
    },

    buyerPhone: {
      type: String,
      required: true,
      trim: true,
    },

    // ======================================================
    // SELLER / FARMER
    // ======================================================

    seller: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Farmer",
      required: true,
      index: true,
    },

    sellerName: {
      type: String,
      required: true,
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
    // PRODUCT
    // ======================================================

    product: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Product",
      required: true,
      index: true,
    },

    productName: {
      type: String,
      required: true,
      trim: true,
    },

    productImage: {
      type: String,
      default: "",
    },

    productPrice: {
      type: Number,
      required: true,
      min: 0,
    },

    // ======================================================
    // ORDER QUANTITY
    // ======================================================

    quantity: {
      type: Number,
      required: true,
      min: 1,
    },

    unit: {
      type: String,
      default: "Kg",
      trim: true,
    },

    // ======================================================
    // TOTAL AMOUNT
    // ======================================================

    totalAmount: {
      type: Number,
      required: true,
      min: 0,
    },

    // ======================================================
    // DELIVERY DETAILS
    // ======================================================

    deliveryAddress: {
      type: String,
      required: true,
      trim: true,
    },

    deliveryCity: {
      type: String,
      default: "",
      trim: true,
    },

    deliveryPincode: {
      type: String,
      default: "",
      trim: true,
    },

    // ======================================================
    // PAYMENT
    // ======================================================

    paymentMethod: {
      type: String,
      enum: [
        "cash_on_delivery",
        "gpay",
        "phonepe",
        "upi",
      ],
      default: "cash_on_delivery",
    },

    paymentStatus: {
      type: String,
      enum: [
        "pending",
        "paid",
        "failed",
        "refunded",
      ],
      default: "pending",
    },

    // ======================================================
    // ORDER STATUS
    // ======================================================

    status: {
      type: String,
      enum: ORDER_STATUSES,
      default: "pending",
      index: true,
    },

    // ======================================================
    // CANCELLATION
    // ======================================================

    cancelledBy: {
      type: String,
      enum: [
        "user",
        "farmer",
        "admin",
        null,
      ],
      default: null,
    },

    cancellationReason: {
      type: String,
      default: "",
      trim: true,
    },

    // ======================================================
    // FARMER RESPONSE
    // ======================================================

    farmerResponseAt: {
      type: Date,
      default: null,
    },

    // ======================================================
    // DELIVERY
    // ======================================================

    deliveredAt: {
      type: Date,
      default: null,
    },

    // ======================================================
    // STATUS HISTORY
    // ======================================================

    statusHistory: [
      {
        status: {
          type: String,
          enum: ORDER_STATUSES,
          required: true,
        },

        updatedBy: {
          type: String,
          enum: [
            "user",
            "farmer",
            "admin",
            "system",
          ],
          default: "system",
        },

        note: {
          type: String,
          default: "",
          trim: true,
        },

        date: {
          type: Date,
          default: Date.now,
        },
      },
    ],
  },
  {
    timestamps: true,
  }
);

// ==========================================================
// GENERATE ORDER NUMBER
// ==========================================================

orderSchema.pre("save", function () {
  if (!this.orderNumber) {
    const timestamp = Date.now();

    const random = Math.floor(
      1000 + Math.random() * 9000
    );

    this.orderNumber = `AGR-${timestamp}-${random}`;
  }
});

// ==========================================================
// EXPORT
// ==========================================================

module.exports = mongoose.model(
  "Order",
  orderSchema
);