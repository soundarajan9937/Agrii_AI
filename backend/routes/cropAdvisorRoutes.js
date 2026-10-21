
const express = require("express");

const router = express.Router();

const {
  getCropRecommendation,
} = require("../controllers/cropAdvisorcontroller");

// ==========================================================
// POST /api/crop-advisor/recommend
// ==========================================================

router.post(
  "/recommend",
  getCropRecommendation
);

// ==========================================================
// GET /api/crop-advisor/recommend
// Optional route test
// ==========================================================

router.get(
  "/recommend",
  (req, res) => {
    return res.status(200).json({
      success: true,
      message: "Crop Advisor recommendation route is available",
    });
  }
);

module.exports = router;

