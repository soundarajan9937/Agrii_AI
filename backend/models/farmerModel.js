
const mongoose = require("mongoose");

// ==========================================================
// FARMER SCHEMA
// ==========================================================
//
// This collection stores ONLY farmer accounts.
//
// Farmer registration:
// POST /api/users/register
//
// role = "farmer"
//
// Farmers can later:
// - Upload products
// - Edit products
// - Delete products
// - View their products
// - Receive orders from users
// ==========================================================

const farmerSchema = new mongoose.Schema(
  {
    // ========================================================
    // FARMER NAME
    // ========================================================

    name: {
      type: String,
      required: [true, "Farmer name is required"],
      trim: true,
      minlength: 2,
      maxlength: 100,
    },

    // ========================================================
    // EMAIL
    // ========================================================

    email: {
      type: String,
      required: [true, "Email is required"],
      unique: true,
      lowercase: true,
      trim: true,
      maxlength: 150,
    },

    // ========================================================
    // PHONE
    // ========================================================

    phone: {
      type: String,
      required: [true, "Phone number is required"],
      unique: true,
      trim: true,
      maxlength: 20,
    },

    // ========================================================
    // PASSWORD
    // ========================================================
    //
    // Stored as a bcrypt hash.
    // ========================================================

    password: {
      type: String,
      required: [true, "Password is required"],
    },

    // ========================================================
    // ROLE
    // ========================================================
    //
    // This collection is ONLY for farmers.
    // ========================================================

    role: {
      type: String,
      enum: ["farmer"],
      default: "farmer",
      immutable: true,
    },

    // ========================================================
    // ACCOUNT STATUS
    // ========================================================

    status: {
      type: String,
      enum: ["active", "blocked"],
      default: "active",
    },

    // ========================================================
    // PROFILE IMAGE
    // ========================================================

    profileImage: {
      type: String,
      default: "",
      trim: true,
    },

    // ========================================================
    // FARM NAME
    // ========================================================

    farmName: {
      type: String,
      default: "",
      trim: true,
      maxlength: 150,
    },

    // ========================================================
    // FARM LOCATION
    // ========================================================

    farmLocation: {
      type: String,
      default: "",
      trim: true,
      maxlength: 300,
    },

    // ========================================================
    // LATITUDE
    // ========================================================

    latitude: {
      type: Number,
      default: null,
    },

    // ========================================================
    // LONGITUDE
    // ========================================================

    longitude: {
      type: Number,
      default: null,
    },

    // ========================================================
    // RECOVERY HINT
    // ========================================================

    recoveryHint: {
      type: String,
      required: [true, "Recovery hint is required"],
      trim: true,
    },
  },

  // ==========================================================
  // TIMESTAMPS
  // ==========================================================

  {
    timestamps: true,
  }
);

// ==========================================================
// MODEL
// ==========================================================

const Farmer = mongoose.model(
  "Farmer",
  farmerSchema,
  "farmers"
);

module.exports = Farmer;
