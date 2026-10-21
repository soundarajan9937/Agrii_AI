
const mongoose = require("mongoose");

// ==========================================================
// ADMIN SCHEMA
// ==========================================================

const adminSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: [true, "Admin name is required"],
      trim: true,
      minlength: 2,
      maxlength: 100,
    },

    email: {
      type: String,
      required: [true, "Admin email is required"],
      unique: true,
      lowercase: true,
      trim: true,
      maxlength: 150,
    },

    phone: {
      type: String,
      required: [true, "Admin phone number is required"],
      unique: true,
      trim: true,
      maxlength: 20,
    },

    password: {
      type: String,
      required: [true, "Admin password is required"],
    },

    role: {
      type: String,
      enum: ["admin"],
      default: "admin",
      immutable: true,
    },

    status: {
      type: String,
      enum: ["active", "blocked"],
      default: "active",
    },

    profileImage: {
      type: String,
      default: "",
      trim: true,
    },
  },
  {
    timestamps: true,
  }
);

// ==========================================================
// NORMALIZE ADMIN DATA
// ==========================================================

adminSchema.pre("validate", function () {
  if (this.email) {
    this.email = this.email.trim().toLowerCase();
  }

  if (this.name) {
    this.name = this.name.trim();
  }

  if (this.phone) {
    this.phone = this.phone.trim();
  }
});

// ==========================================================
// MODEL
// ==========================================================

const Admin = mongoose.model("Admin", adminSchema, "admin");

module.exports = Admin;
