const express = require("express");

const router = express.Router();

const {
  farmerRegister,
  farmerLogin,
  getFarmerProfile,
} = require("../controllers/farmerController");

// ==========================================
// FARMER REGISTER
// POST /api/farmers/register
// ==========================================
router.post("/register", farmerRegister);

// ==========================================
// FARMER LOGIN
// POST /api/farmers/login
// ==========================================
router.post("/login", farmerLogin);

// ==========================================
// FARMER PROFILE
// GET /api/farmers/profile/:id
// ==========================================
router.get("/profile/:id", getFarmerProfile);

module.exports = router;