const Farmer = require("../models/farmerModel");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");

// ==========================================================
// FARMER REGISTER
// POST /api/farmers/register
// ==========================================================

const farmerRegister = async (req, res) => {
  try {
    const {
      name,
      email,
      phone,
      password,
      farmName,
      farmLocation,
      latitude,
      longitude,
    } = req.body;

    // Check required fields
    if (!name || !email || !phone || !password) {
      return res.status(400).json({
        success: false,
        message: "Name, email, phone and password are required",
      });
    }

    // Check existing farmer
    const existingFarmer = await Farmer.findOne({
      email: email.toLowerCase().trim(),
    });

    if (existingFarmer) {
      return res.status(400).json({
        success: false,
        message: "Farmer email already registered",
      });
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10);

    // Create farmer
    const farmer = new Farmer({
      name: name.trim(),
      email: email.toLowerCase().trim(),
      phone: phone.trim(),
      password: hashedPassword,
      role: "farmer",
      farmName: farmName || "",
      farmLocation: farmLocation || "",
      latitude: latitude || null,
      longitude: longitude || null,
    });

    await farmer.save();

    return res.status(201).json({
      success: true,
      message: "Farmer registration successful",
      farmer: {
        _id: farmer._id,
        name: farmer.name,
        email: farmer.email,
        phone: farmer.phone,
        role: farmer.role,
        farmName: farmer.farmName,
        farmLocation: farmer.farmLocation,
      },
    });
  } catch (error) {
    console.error("FARMER REGISTER ERROR:");
    console.error(error);

    return res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// ==========================================================
// FARMER LOGIN
// POST /api/farmers/login
// ==========================================================

const farmerLogin = async (req, res) => {
  try {
    const { email, password } = req.body;

    // Validation
    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message: "Email and password are required",
      });
    }

    // Find farmer
    const farmer = await Farmer.findOne({
      email: email.toLowerCase().trim(),
    });

    if (!farmer) {
      return res.status(401).json({
        success: false,
        message: "Invalid farmer email or password",
      });
    }

    // Check role
    if (farmer.role !== "farmer") {
      return res.status(403).json({
        success: false,
        message: "This account is not a farmer account",
      });
    }

    // Check status
    if (farmer.status === "blocked") {
      return res.status(403).json({
        success: false,
        message: "Farmer account is blocked",
      });
    }

    // Compare password
    const passwordMatch = await bcrypt.compare(
      password,
      farmer.password
    );

    if (!passwordMatch) {
      return res.status(401).json({
        success: false,
        message: "Invalid farmer email or password",
      });
    }

    // Create JWT
    const token = jwt.sign(
      {
        id: farmer._id,
        role: "farmer",
      },
      process.env.JWT_SECRET || "AGRII_SECRET_KEY",
      {
        expiresIn: "7d",
      }
    );

    return res.status(200).json({
      success: true,
      message: "Farmer login successful",
      token,
      farmer: {
        _id: farmer._id,
        name: farmer.name,
        email: farmer.email,
        phone: farmer.phone,
        role: farmer.role,
        farmName: farmer.farmName,
        farmLocation: farmer.farmLocation,
        profileImage: farmer.profileImage,
      },
    });
  } catch (error) {
    console.error("FARMER LOGIN ERROR:");
    console.error(error);

    return res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// ==========================================================
// GET FARMER PROFILE
// GET /api/farmers/profile/:id
// ==========================================================

const getFarmerProfile = async (req, res) => {
  try {
    const farmer = await Farmer.findById(req.params.id).select(
      "-password"
    );

    if (!farmer) {
      return res.status(404).json({
        success: false,
        message: "Farmer not found",
      });
    }

    return res.status(200).json({
      success: true,
      farmer,
    });
  } catch (error) {
    console.error("GET FARMER PROFILE ERROR:");
    console.error(error);

    return res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// ==========================================================
// EXPORT
// ==========================================================

module.exports = {
  farmerRegister,
  farmerLogin,
  getFarmerProfile,
};