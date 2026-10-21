const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");

// ==========================================================
// MODELS
// ==========================================================

const User = require("../models/userModel");
const Farmer = require("../models/farmerModel");

// ==========================================================
// JWT SECRET
// ==========================================================

const JWT_SECRET = process.env.JWT_SECRET || "AGRII_SECRET_KEY";

// ==========================================================
// EMAIL VALIDATION
// ==========================================================

const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

// ==========================================================
// REGISTER
// ==========================================================

const register = async (req, res) => {
  try {
    const {
      name,
      email,
      phone,
      password,
      role,
      farmName,
      farmLocation,
      recoveryHint,
    } = req.body;

    if (!name || !email || !phone || !password || !recoveryHint) {
      return res.status(400).json({
        success: false,
        message: "Name, email, phone, password and recovery hint are required",
      });
    }

    const cleanName = String(name).trim();
    const cleanEmail = String(email).trim().toLowerCase();
    const cleanPhone = String(phone).trim();
    const cleanPassword = String(password);
    const cleanHint = String(recoveryHint).trim();

    const cleanRole = String(role || "user").trim().toLowerCase();

    if (!["user", "farmer"].includes(cleanRole)) {
      return res.status(400).json({
        success: false,
        message: "Registration is allowed only for user or farmer",
      });
    }

    if (!emailRegex.test(cleanEmail)) {
      return res.status(400).json({
        success: false,
        message: "Please enter a valid email address",
      });
    }

    if (cleanPassword.length < 6) {
      return res.status(400).json({
        success: false,
        message: "Password must contain at least 6 characters",
      });
    }

    // Check existing
    const [existingUser, existingFarmer] = await Promise.all([
      User.findOne({ email: cleanEmail }),
      Farmer.findOne({ email: cleanEmail }),
    ]);

    if (existingUser || existingFarmer) {
      return res.status(409).json({
        success: false,
        message: "An account with this email already exists",
      });
    }

    const hashedPassword = await bcrypt.hash(cleanPassword, 12);

    if (cleanRole === "user") {
      const user = await User.create({
        name: cleanName,
        email: cleanEmail,
        phone: cleanPhone,
        password: hashedPassword,
        recoveryHint: cleanHint,
        role: "user",
        status: "active",
      });

      return res.status(201).json({
        success: true,
        message: "User registration successful",
        user: { _id: user._id, name: user.name, email: user.email, role: "user" },
      });
    }

    if (cleanRole === "farmer") {
      const farmer = await Farmer.create({
        name: cleanName,
        email: cleanEmail,
        phone: cleanPhone,
        password: hashedPassword,
        recoveryHint: cleanHint,
        role: "farmer",
        status: "active",
        farmName: String(farmName || "").trim(),
        farmLocation: String(farmLocation || "").trim(),
      });

      return res.status(201).json({
        success: true,
        message: "Farmer registration successful",
        farmer: { _id: farmer._id, name: farmer.name, email: farmer.email, role: "farmer" },
      });
    }

  } catch (error) {
    console.error("REGISTER ERROR:", error);
    return res.status(500).json({
      success: false,
      message: "Registration failed",
      error: error.message,
    });
  }
};

// ==========================================================
// LOGIN
// ==========================================================

const login = async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message: "Email and password are required",
      });
    }

    const cleanEmail = String(email).trim().toLowerCase();

    // Try User
    let account = await User.findOne({ email: cleanEmail });
    let role = "user";

    // Try Farmer if not User
    if (!account) {
      account = await Farmer.findOne({ email: cleanEmail });
      role = "farmer";
    }

    if (!account) {
      return res.status(401).json({
        success: false,
        message: "Invalid email or password",
      });
    }

    if (account.status === "blocked") {
      return res.status(403).json({
        success: false,
        message: "Account has been blocked",
      });
    }

    const isMatch = await bcrypt.compare(password, account.password);
    if (!isMatch) {
      return res.status(401).json({
        success: false,
        message: "Invalid email or password",
      });
    }

    const token = jwt.sign(
      { id: account._id.toString(), role: account.role || role },
      JWT_SECRET,
      { expiresIn: "7d" }
    );

    return res.status(200).json({
      success: true,
      message: "Login successful",
      token,
      user: {
        _id: account._id,
        name: account.name,
        email: account.email,
        phone: account.phone,
        role: account.role || role,
        status: account.status,
      },
    });
  } catch (error) {
    console.error("LOGIN ERROR:", error);
    return res.status(500).json({ success: false, message: "Login failed" });
  }
};

// ==========================================================
// RESET PASSWORD
// POST /api/auth/reset-password
// ==========================================================

const resetPassword = async (req, res) => {
  try {
    const { email, recoveryHint, newPassword } = req.body;

    if (!email || !recoveryHint || !newPassword) {
      return res.status(400).json({
        success: false,
        message: "Email, recovery hint and new password are required",
      });
    }

    const cleanEmail = String(email).trim().toLowerCase();
    const cleanHint = String(recoveryHint).trim();

    // Find account
    let account = await User.findOne({ email: cleanEmail });
    if (!account) {
      account = await Farmer.findOne({ email: cleanEmail });
    }

    if (!account) {
      return res.status(404).json({
        success: false,
        message: "Account not found with this email",
      });
    }

    // Verify Hint
    if (account.recoveryHint !== cleanHint) {
      return res.status(401).json({
        success: false,
        message: "Incorrect recovery hint",
      });
    }

    // Update Password
    const hashedPassword = await bcrypt.hash(newPassword, 12);
    account.password = hashedPassword;
    await account.save();

    return res.status(200).json({
      success: true,
      message: "Password reset successful. You can now login.",
    });
  } catch (error) {
    console.error("RESET PASSWORD ERROR:", error);
    return res.status(500).json({
      success: false,
      message: "Failed to reset password",
    });
  }
};

module.exports = {
  register,
  login,
  resetPassword,
};
