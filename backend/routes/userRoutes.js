
const express = require("express");

const router = express.Router();

const {
  register,
  login,
  getProfile,
} = require("../controllers/userController");

// ==========================================================
// REGISTER USER / FARMER
//
// POST /api/users/register
//
// Body:
// {
//   name,
//   email,
//   phone,
//   password,
//   role: "user" | "farmer"
// }
// ==========================================================

router.post("/register", register);

// ==========================================================
// LOGIN USER / FARMER / ADMIN
//
// POST /api/users/login
//
// Body:
// {
//   email,
//   password
// }
//
// Response contains the real role:
// user / farmer / admin
// ==========================================================

router.post("/login", login);

// ==========================================================
// RESET PASSWORD
// ==========================================================

router.post("/reset-password", require("../controllers/userController").resetPassword);

// ==========================================================
// GET PROFILE
//
// GET /api/users/profile/:id
//
// Works for:
// - User
// - Farmer
// - Admin
// ==========================================================

router.get("/profile/:id", getProfile);

// ==========================================================
// EXPORT ROUTER
// ==========================================================

module.exports = router;
