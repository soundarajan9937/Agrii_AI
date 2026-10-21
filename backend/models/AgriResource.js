const mongoose = require("mongoose");

const agriResourceSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: [true, "Material name is required"],
      trim: true,
    },
    category: {
      type: String,
      required: [true, "Category is required"],
      enum: [
        "Crop Residues",
        "Vegetable Waste",
        "Fruit Waste",
        "Animal Waste",
        "Coconut Waste",
        "Sugarcane Waste",
        "Oilseed & Nut Waste",
        "Weed & Green Waste",
        "Agri-Processing Waste",
        "Other Organic Farm Waste",
        "Agri Tools & Equipment",
      ],
    },
    sellerName: {
      type: String,
      required: true,
    },
    sellerId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Farmer",
      required: true,
    },
    price: {
      type: Number,
      required: [true, "Price is required"],
    },
    phoneNumber: {
      type: String,
      required: [true, "Phone number is required"],
    },
    image: {
      type: String,
      required: [true, "Photo is required"],
    },
    status: {
      type: String,
      enum: ["pending", "approved", "rejected"],
      default: "pending",
    },
    description: {
      type: String,
      trim: true,
    },
    rejectionReason: {
      type: String,
      default: "",
    },
  },
  { timestamps: true }
);

module.exports = mongoose.model("AgriResource", agriResourceSchema);
