
const jwt = require("jsonwebtoken");

// ==========================================================
// JWT SECRET
// Must be the same secret used in userController.js
// ==========================================================

const JWT_SECRET =
  process.env.JWT_SECRET || "AGRII_SECRET_KEY";

// ==========================================================
// AUTHENTICATE TOKEN
//
// Reads:
// Authorization: Bearer <token>
//
// Creates:
// req.user = {
//   id,
//   role
// }
// ==========================================================

const authenticateToken = (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader) {
      return res.status(401).json({
        success: false,
        message: "Authentication token is required",
      });
    }

    if (!authHeader.startsWith("Bearer ")) {
      return res.status(401).json({
        success: false,
        message: "Invalid authorization format",
      });
    }

    const token = authHeader.substring(7).trim();

    if (!token) {
      return res.status(401).json({
        success: false,
        message: "Authentication token is missing",
      });
    }

    // ======================================================
    // VERIFY TOKEN
    // ======================================================

    const decoded = jwt.verify(
      token,
      JWT_SECRET
    );

    // ======================================================
    // CREATE req.user
    // ======================================================

    req.user = {
      id: decoded.id,
      role: decoded.role,
    };

    next();
  } catch (error) {
    console.error(
      "AUTHENTICATION ERROR:",
      error.message
    );

    if (error.name === "TokenExpiredError") {
      return res.status(401).json({
        success: false,
        message: "Authentication token has expired",
      });
    }

    if (error.name === "JsonWebTokenError") {
      return res.status(401).json({
        success: false,
        message: "Invalid authentication token",
      });
    }

    return res.status(401).json({
      success: false,
      message: "Authentication failed",
    });
  }
};

// ==========================================================
// ADMIN ONLY
// ==========================================================

const requireAdmin = (req, res, next) => {
  if (!req.user) {
    return res.status(401).json({
      success: false,
      message: "Authentication required",
    });
  }

  const role = String(
    req.user.role || ""
  )
    .trim()
    .toLowerCase();

  if (role !== "admin") {
    return res.status(403).json({
      success: false,
      message: "Admin access required",
    });
  }

  next();
};

// ==========================================================
// FARMER ONLY
// ==========================================================

const requireFarmer = (req, res, next) => {
  if (!req.user) {
    return res.status(401).json({
      success: false,
      message: "Authentication required",
    });
  }

  const role = String(
    req.user.role || ""
  )
    .trim()
    .toLowerCase();

  if (role !== "farmer") {
    return res.status(403).json({
      success: false,
      message: "Farmer access required",
    });
  }

  next();
};

// ==========================================================
// USER ONLY
// ==========================================================

const requireUser = (req, res, next) => {
  if (!req.user) {
    return res.status(401).json({
      success: false,
      message: "Authentication required",
    });
  }

  const role = String(
    req.user.role || ""
  )
    .trim()
    .toLowerCase();

  if (role !== "user") {
    return res.status(403).json({
      success: false,
      message: "User access required",
    });
  }

  next();
};

// ==========================================================
// EXPORT
// ==========================================================

module.exports = {
  authenticateToken,
  requireAdmin,
  requireFarmer,
  requireUser,
};

