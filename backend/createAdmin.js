
const dns = require("dns");
require("dotenv").config();

try {
  dns.setServers(["8.8.8.8", "8.8.4.4"]);
} catch (e) {}

const mongoose = require("mongoose");
const bcrypt = require("bcryptjs");

const Admin = require("./models/adminModel");

// ==========================================================
// ADMIN CREDENTIALS (from .env)
// ==========================================================

const ADMIN_EMAIL    = process.env.ADMIN_EMAIL    || "admin@agrii.com";
const ADMIN_PASSWORD = process.env.ADMIN_PASSWORD || "Agrii@Admin#2024";
const ADMIN_NAME     = process.env.ADMIN_NAME     || "Agrii AI Admin";
const ADMIN_PHONE    = process.env.ADMIN_PHONE    || "9876543210";

// ==========================================================
// RESET / CREATE ADMIN
// ==========================================================

async function resetAdminPassword() {
  try {
    // ========================================================
    // CHECK MONGO URI
    // ========================================================

    if (!process.env.MONGO_URI) {
      console.error("ERROR: MONGO_URI is missing from .env");
      process.exit(1);
    }

    // ========================================================
    // CONNECT MONGODB
    // ========================================================

    await mongoose.connect(process.env.MONGO_URI);

    console.log("================================");
    console.log("MongoDB connected");
    console.log("================================");

    // ========================================================
    // FIND ADMIN
    // ========================================================

    let admin = await Admin.findOne({
      email: ADMIN_EMAIL.toLowerCase(),
    });

    // ========================================================
    // HASH PASSWORD
    // ========================================================

    const hashedPassword = await bcrypt.hash(
      ADMIN_PASSWORD,
      10
    );

    // ========================================================
    // ADMIN DOES NOT EXIST
    // ========================================================

    if (!admin) {
      console.log("Admin not found.");
      console.log("Creating new admin...");

      admin = new Admin({
        name: ADMIN_NAME,
        email: ADMIN_EMAIL.toLowerCase(),
        phone: ADMIN_PHONE,
        password: hashedPassword,
        role: "admin",
        status: "active",
      });

      await admin.save();

      console.log("================================");
      console.log("ADMIN CREATED SUCCESSFULLY");
      console.log("================================");
      console.log("Email    :", ADMIN_EMAIL);
      console.log("Password :", ADMIN_PASSWORD);
      console.log("Phone    :", ADMIN_PHONE);
      console.log("Role     :", admin.role);
      console.log("Status   :", admin.status);
      console.log("================================");

      return;
    }

    // ========================================================
    // ADMIN EXISTS - RESET PASSWORD
    // ========================================================

    admin.password = hashedPassword;
    admin.role = "admin";
    admin.status = "active";
    admin.phone = ADMIN_PHONE;

    if (!admin.name || admin.name.trim() === "") {
      admin.name = ADMIN_NAME;
    }

    await admin.save();

    // ========================================================
    // SUCCESS
    // ========================================================

    console.log("================================");
    console.log("ADMIN PASSWORD RESET SUCCESSFUL");
    console.log("================================");
    console.log("Email    :", ADMIN_EMAIL);
    console.log("Password :", ADMIN_PASSWORD);
    console.log("Phone    :", ADMIN_PHONE);
    console.log("Role     :", admin.role);
    console.log("Status   :", admin.status);
    console.log("================================");
  } catch (error) {
    console.error("================================");
    console.error("ADMIN RESET ERROR");
    console.error("================================");
    console.error(error);
    console.error("================================");
  } finally {
    // ========================================================
    // DISCONNECT
    // ========================================================

    try {
      await mongoose.disconnect();
      console.log("MongoDB disconnected");
    } catch (error) {
      console.error("MongoDB disconnect error:", error);
    }
  }
}

// ==========================================================
// RUN
// ==========================================================

resetAdminPassword();
