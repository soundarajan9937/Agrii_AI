const mongoose = require("mongoose");

const agriResourceOrderSchema = new mongoose.Schema(
  {
    buyerName: {
      type: String,
      required: true,
    },
    buyerId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
    resourceId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "AgriResource",
      required: true,
    },
    sellerId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Farmer",
      required: true,
    },
    price: {
      type: Number,
      required: true,
    },
    paymentMethod: {
      type: String,
      enum: ["Cash on Delivery", "GPay"],
      required: true,
    },
    status: {
      type: String,
      enum: ["pending", "accepted", "cancelled"],
      default: "pending",
    },
    buyerPhone: {
      type: String,
      required: true,
    },
    deliveryAddress: {
      type: String,
      required: [true, "Delivery address is required"],
    },
  },
  { timestamps: true }
);

module.exports = mongoose.model("AgriResourceOrder", agriResourceOrderSchema);
