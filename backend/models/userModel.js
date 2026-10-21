
const mongoose = require("mongoose");

// ==========================================================
// USER SCHEMA
// ==========================================================
//
// This collection is ONLY for normal application users.
//
// User registration:
// POST /api/users/register
//
// role = "user"
//
// Farmers are stored in Farmer collection.
// Admins are stored in Admin collection.
// ==========================================================

const userSchema = new mongoose.Schema(
  {
    // ========================================================
    // NAME
    // ========================================================

    name: {
      type: String,
      required: true,
      trim: true,
      minlength: 2,
      maxlength: 100,
    },

    // ========================================================
    // EMAIL
    // ========================================================

    email: {
      type: String,
      required: true,
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
      required: true,
      unique: true,
      trim: true,
      maxlength: 20,
    },

    // ========================================================
    // PASSWORD
    // ========================================================
    //
    // Password is stored as a bcrypt hash.
    // Never store the plain-text password.
    // ========================================================

    password: {
      type: String,
      required: true,
      minlength: 6,
    },

    // ========================================================
    // ROLE
    // ========================================================
    //
    // This collection is ONLY for normal users.
    //
    // Do not allow farmer/admin here.
    // ========================================================

    role: {
      type: String,
      enum: ["user"],
      default: "user",
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
    // LOCATION
    // ========================================================

    latitude: {
      type: Number,
      default: null,
    },

    longitude: {
      type: Number,
      default: null,
    },

    // ========================================================
    // RECOVERY HINT
    // Used for password reset without email OTP
    // ========================================================

    recoveryHint: {
      type: String,
      required: true,
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
// EXPORT
// ==========================================================

module.exports =
  mongoose.model("User", userSchema);
