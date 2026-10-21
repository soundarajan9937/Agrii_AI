const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const mongoose = require("mongoose");

const User = require("../models/userModel");
const Farmer = require("../models/farmerModel");
const Admin = require("../models/adminModel");

// ==========================================================
// JWT CONFIGURATION
// ==========================================================

const JWT_SECRET = process.env.JWT_SECRET || "AGRII_SECRET_KEY";
const JWT_EXPIRES_IN = "7d";

const createToken = (id, role) => {
  return jwt.sign(
    { id: id.toString(), role: role.toLowerCase() },
    JWT_SECRET,
    { expiresIn: JWT_EXPIRES_IN }
  );
};

const cleanEmail = (email) => String(email || "").trim().toLowerCase();
const cleanString = (value) => String(value || "").trim();
const isValidEmail = (email) => /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);

// ==========================================================
// REGISTER USER / FARMER
// ==========================================================

const register = async (req, res) => {
  try {
    const { name, email, phone, password, role, farmName, farmLocation, recoveryHint } = req.body;

    if (!name || !email || !phone || !password || !recoveryHint) {
      return res.status(400).json({
        success: false,
        message: "Name, email, phone, password and recovery hint are required",
      });
    }

    const cleanName = cleanString(name);
    const cleanEmailValue = cleanEmail(email);
    const cleanPhone = cleanString(phone);
    const cleanPassword = String(password);
    const cleanHint = cleanString(recoveryHint);

    const selectedRole = String(role || "user").trim().toLowerCase();

    if (cleanName.length < 2) return res.status(400).json({ success: false, message: "Name must be at least 2 characters" });
    if (!isValidEmail(cleanEmailValue)) return res.status(400).json({ success: false, message: "Invalid email" });
    if (cleanPassword.length < 6) return res.status(400).json({ success: false, message: "Password too short" });

    // Check existing
    const [existingEmail, existingPhone] = await Promise.all([
      Promise.any([User.findOne({ email: cleanEmailValue }), Farmer.findOne({ email: cleanEmailValue }), Admin.findOne({ email: cleanEmailValue })]).catch(() => null),
      Promise.any([User.findOne({ phone: cleanPhone }), Farmer.findOne({ phone: cleanPhone }), Admin.findOne({ phone: cleanPhone })]).catch(() => null),
    ]);

    if (existingEmail) return res.status(409).json({ success: false, message: "Email already registered" });
    if (existingPhone) return res.status(409).json({ success: false, message: "Phone already registered" });

    const hashedPassword = await bcrypt.hash(cleanPassword, 10);

    if (selectedRole === "farmer") {
      if (!cleanString(farmName) || !cleanString(farmLocation)) {
        return res.status(400).json({ success: false, message: "Farm name and location are required" });
      }

      const farmer = await Farmer.create({
        name: cleanName, email: cleanEmailValue, phone: cleanPhone, password: hashedPassword,
        recoveryHint: cleanHint, role: "farmer", status: "active", farmName: cleanString(farmName), farmLocation: cleanString(farmLocation)
      });

      return res.status(201).json({ success: true, message: "Farmer registration successful", user: farmer });
    }

    const user = await User.create({
      name: cleanName, email: cleanEmailValue, phone: cleanPhone, password: hashedPassword,
      recoveryHint: cleanHint, role: "user", status: "active"
    });

    return res.status(201).json({ success: true, message: "User registration successful", user });
  } catch (error) {
    console.error("REGISTER ERROR:", error);
    return res.status(500).json({ success: false, message: "Registration failed" });
  }
};

// ==========================================================
// LOGIN
// ==========================================================

const login = async (req, res) => {
  try {
    const { email, password } = req.body;
    if (!email || !password) return res.status(400).json({ success: false, message: "Missing fields" });

    const cleanEmailValue = cleanEmail(email);
    let account = await User.findOne({ email: cleanEmailValue });
    let role = "user";

    if (!account) {
      account = await Farmer.findOne({ email: cleanEmailValue });
      role = "farmer";
    }
    if (!account) {
      account = await Admin.findOne({ email: cleanEmailValue });
      role = "admin";
    }

    if (!account) return res.status(401).json({ success: false, message: "Invalid email or password" });
    if (account.status === "blocked") return res.status(403).json({ success: false, message: "Blocked" });

    const isMatch = await bcrypt.compare(password, account.password);
    if (!isMatch) return res.status(401).json({ success: false, message: "Invalid email or password" });

    const token = createToken(account._id, account.role || role);

    return res.status(200).json({
      success: true,
      message: "Login successful",
      token,
      user: account
    });
  } catch (error) {
    return res.status(500).json({ success: false, message: "Login failed" });
  }
};

// ==========================================================
// RESET PASSWORD
// ==========================================================

const resetPassword = async (req, res) => {
  try {
    const { email, recoveryHint, newPassword } = req.body;

    if (!email || !recoveryHint || !newPassword) {
      return res.status(400).json({ success: false, message: "Missing fields" });
    }

    const cleanEmailValue = cleanEmail(email);
    const cleanHint = cleanString(recoveryHint);

    let account = await User.findOne({ email: cleanEmailValue });
    if (!account) account = await Farmer.findOne({ email: cleanEmailValue });

    if (!account) return res.status(404).json({ success: false, message: "Account not found" });

    if (account.recoveryHint !== cleanHint) {
      return res.status(401).json({ success: false, message: "Incorrect recovery hint" });
    }

    const hashedPassword = await bcrypt.hash(newPassword, 10);
    account.password = hashedPassword;
    await account.save();

    return res.status(200).json({ success: true, message: "Password reset successful" });
  } catch (error) {
    console.error("RESET ERROR:", error);
    return res.status(500).json({ success: false, message: "Failed to reset password" });
  }
};

const getProfile = async (req, res) => {
  try {
    const { id } = req.params;
    if (!mongoose.Types.ObjectId.isValid(id)) return res.status(400).json({ success: false, message: "Invalid ID" });

    let user = await User.findById(id).select("-password").lean();
    if (!user) user = await Farmer.findById(id).select("-password").lean();
    if (!user) user = await Admin.findById(id).select("-password").lean();

    if (!user) return res.status(404).json({ success: false, message: "Not found" });

    return res.status(200).json({ success: true, user });
  } catch (error) {
    return res.status(500).json({ success: false, message: "Error" });
  }
};

module.exports = {
  register,
  login,
  resetPassword,
  getProfile,
};
