
const mongoose = require("mongoose");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");

const User = require("../models/userModel");
const Farmer = require("../models/farmerModel");
const Admin = require("../models/adminModel");
const Product = require("../models/productModel");
const Order = require("../models/orderModel");

// ==========================================================
// JWT
// ==========================================================

const JWT_SECRET =
  process.env.JWT_SECRET || "AGRII_SECRET_KEY";

const JWT_EXPIRES_IN = "7d";

// ==========================================================
// HELPERS
// ==========================================================

const isValidObjectId = (id) => {
  return mongoose.Types.ObjectId.isValid(id);
};

const cleanEmail = (email) => {
  return String(email || "")
    .trim()
    .toLowerCase();
};

const createToken = (id, role) => {
  return jwt.sign(
    {
      id: id.toString(),
      role,
    },
    JWT_SECRET,
    {
      expiresIn: JWT_EXPIRES_IN,
    }
  );
};

const checkAdmin = async (req, res) => {
  if (!req.user) {
    res.status(401).json({
      success: false,
      message: "Authentication required",
    });

    return null;
  }

  const role = String(
    req.user.role || ""
  )
    .trim()
    .toLowerCase();

  if (role !== "admin") {
    res.status(403).json({
      success: false,
      message: "Admin access required",
    });

    return null;
  }

  const adminId = req.user.id;

  if (!adminId || !isValidObjectId(adminId)) {
    res.status(401).json({
      success: false,
      message: "Invalid admin authentication",
    });

    return null;
  }

  const admin = await Admin.findById(adminId);

  if (!admin) {
    res.status(404).json({
      success: false,
      message: "Admin account not found",
    });

    return null;
  }

  if (admin.status === "blocked") {
    res.status(403).json({
      success: false,
      message: "Admin account is blocked",
    });

    return null;
  }

  return admin;
};

// ==========================================================
// ADMIN LOGIN
//
// POST /api/admin/login
//
// NOTE:
// Admin login is separate from /api/users/login.
// ==========================================================

const adminLogin = async (req, res) => {
  try {
    console.log("======================================");
    console.log("ADMIN LOGIN");
    console.log("======================================");

    const {
      email,
      password,
    } = req.body;

    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message:
          "Email and password are required",
      });
    }

    const cleanEmailValue =
      cleanEmail(email);

    const admin = await Admin.findOne({
      email: cleanEmailValue,
    });

    if (!admin) {
      return res.status(401).json({
        success: false,
        message:
          "Invalid email or password",
      });
    }

    if (admin.status === "blocked") {
      return res.status(403).json({
        success: false,
        message:
          "Your admin account has been blocked",
      });
    }

    const passwordMatch =
      await bcrypt.compare(
        String(password),
        admin.password
      );

    if (!passwordMatch) {
      return res.status(401).json({
        success: false,
        message:
          "Invalid email or password",
      });
    }

    const token = createToken(
      admin._id,
      "admin"
    );

    console.log(
      "Admin login successful:",
      admin.email
    );

    return res.status(200).json({
      success: true,
      message: "Admin login successful",

      token,

      user: {
        _id: admin._id,
        name: admin.name,
        email: admin.email,
        phone: admin.phone,
        role: "admin",
        status: admin.status,
      },
    });
  } catch (error) {
    console.error(
      "ADMIN LOGIN ERROR:",
      error
    );

    return res.status(500).json({
      success: false,
      message: "Admin login failed",
      error: error.message,
    });
  }
};

// ==========================================================
// DASHBOARD STATISTICS
//
// GET /api/admin/dashboard
// ==========================================================

const getDashboardStats = async (req, res) => {
  try {
    const admin = await checkAdmin(
      req,
      res
    );

    if (!admin) return;

    const [
      totalUsers,
      totalFarmers,
      totalProducts,
      pendingProducts,
      approvedProducts,
      rejectedProducts,
      totalOrders,
      pendingOrders,
      acceptedOrders,
      deliveredOrders,
      cancelledOrders,
      totalRevenueResult,
      paidRevenueResult,
    ] = await Promise.all([
      User.countDocuments(),

      Farmer.countDocuments(),

      Product.countDocuments({
        isDeleted: false,
      }),

      Product.countDocuments({
        approvalStatus: "pending",
        isDeleted: false,
      }),

      Product.countDocuments({
        approvalStatus: "approved",
        isDeleted: false,
      }),

      Product.countDocuments({
        approvalStatus: "rejected",
        isDeleted: false,
      }),

      Order.countDocuments(),

      Order.countDocuments({
        status: "pending",
      }),

      Order.countDocuments({
        status: "accepted",
      }),

      Order.countDocuments({
        status: "delivered",
      }),

      Order.countDocuments({
        status: "cancelled",
      }),

      Order.aggregate([
        {
          $match: {
            status: {
              $nin: ["cancelled", "rejected"],
            },
          },
        },
        {
          $group: {
            _id: null,
            total: {
              $sum: "$totalAmount",
            },
          },
        },
      ]),

      Order.aggregate([
        {
          $match: {
            paymentStatus: "paid",
            status: {
              $nin: ["cancelled", "rejected"],
            },
          },
        },
        {
          $group: {
            _id: null,
            total: {
              $sum: "$totalAmount",
            },
          },
        },
      ]),
    ]);

    const totalRevenue =
      totalRevenueResult.length > 0
        ? totalRevenueResult[0].total
        : 0;

    const paidRevenue =
      paidRevenueResult.length > 0
        ? paidRevenueResult[0].total
        : 0;

    return res.status(200).json({
      success: true,

      stats: {
        totalUsers,
        totalFarmers,

        totalProducts,
        pendingProducts,
        approvedProducts,
        rejectedProducts,

        totalOrders,
        pendingOrders,
        acceptedOrders,
        deliveredOrders,
        cancelledOrders,

        totalRevenue,
        paidRevenue,
      },
    });
  } catch (error) {
    console.error(
      "GET DASHBOARD STATS ERROR:",
      error
    );

    return res.status(500).json({
      success: false,
      message:
        "Failed to load dashboard statistics",
      error: error.message,
    });
  }
};

// ==========================================================
// GET USERS
//
// GET /api/admin/users
//
// Returns normal users + farmers.
// Admin accounts are not returned here.
// ==========================================================

const getUsers = async (req, res) => {
  try {
    const admin = await checkAdmin(
      req,
      res
    );

    if (!admin) return;

    const users = await User.find()
      .select("-password")
      .sort({ createdAt: -1 });

    const farmers = await Farmer.find()
      .select("-password")
      .sort({ createdAt: -1 });

    const normalUsers = users.map(
      (user) => ({
        ...user.toObject(),
        role: "user",
      })
    );

    const farmerUsers = farmers.map(
      (farmer) => ({
        ...farmer.toObject(),
        role: "farmer",
      })
    );

    const allUsers = [
      ...normalUsers,
      ...farmerUsers,
    ].sort((a, b) => {
      const dateA = new Date(
        a.createdAt || 0
      ).getTime();

      const dateB = new Date(
        b.createdAt || 0
      ).getTime();

      return dateB - dateA;
    });

    return res.status(200).json({
      success: true,
      count: allUsers.length,
      users: allUsers,
    });
  } catch (error) {
    console.error(
      "GET ADMIN USERS ERROR:",
      error
    );

    return res.status(500).json({
      success: false,
      message: "Failed to load users",
      error: error.message,
    });
  }
};

// ==========================================================
// GET PRODUCTS
//
// GET /api/admin/products
//
// Admin can see all non-deleted products.
// ==========================================================

const getProducts = async (req, res) => {
  try {
    const admin = await checkAdmin(
      req,
      res
    );

    if (!admin) return;

    const products = await Product.find({
      isDeleted: false,
    })
      .populate(
        "seller",
        "name email phone farmName farmLocation latitude longitude status"
      )
      .populate(
        "approvedBy",
        "name email phone"
      )
      .sort({ createdAt: -1 });

    return res.status(200).json({
      success: true,
      count: products.length,
      products,
    });
  } catch (error) {
    console.error(
      "GET ADMIN PRODUCTS ERROR:",
      error
    );

    return res.status(500).json({
      success: false,
      message: "Failed to load products",
      error: error.message,
    });
  }
};

// ==========================================================
// APPROVE PRODUCT
//
// PUT /api/admin/products/:id/approve
// ==========================================================

const approveProduct = async (req, res) => {
  try {
    const admin = await checkAdmin(
      req,
      res
    );

    if (!admin) return;

    const { id } = req.params;

    if (!isValidObjectId(id)) {
      return res.status(400).json({
        success: false,
        message: "Invalid product ID",
      });
    }

    const product =
      await Product.findById(id);

    if (!product) {
      return res.status(404).json({
        success: false,
        message: "Product not found",
      });
    }

    if (product.isDeleted) {
      return res.status(400).json({
        success: false,
        message:
          "Deleted product cannot be approved",
      });
    }

    if (
      product.approvalStatus ===
      "approved"
    ) {
      return res.status(400).json({
        success: false,
        message:
          "Product is already approved",
      });
    }

    // ======================================================
    // APPROVAL
    // ======================================================

    product.approvalStatus =
      "approved";

    product.rejectionReason = "";

    product.approvedAt =
      new Date();

    product.rejectedAt = null;

    product.approvedBy =
      admin._id;

    product.isActive = true;

    product.isDeleted = false;

    product.isMarketplaceVisible =
      true;

    await product.save();

    const updatedProduct =
      await Product.findById(id)
        .populate(
          "seller",
          "name email phone farmName farmLocation"
        )
        .populate(
          "approvedBy",
          "name email"
        );

    return res.status(200).json({
      success: true,
      message:
        "Product approved successfully and added to marketplace",
      product: updatedProduct,
    });
  } catch (error) {
    console.error(
      "ADMIN APPROVE PRODUCT ERROR:",
      error
    );

    return res.status(500).json({
      success: false,
      message:
        "Failed to approve product",
      error: error.message,
    });
  }
};

// ==========================================================
// REJECT PRODUCT
//
// PUT /api/admin/products/:id/reject
//
// Body:
// {
//   "rejectionReason": "Reason"
// }
// ==========================================================

const rejectProduct = async (req, res) => {
  try {
    const admin = await checkAdmin(
      req,
      res
    );

    if (!admin) return;

    const { id } = req.params;

    const {
      rejectionReason,
    } = req.body;

    if (!isValidObjectId(id)) {
      return res.status(400).json({
        success: false,
        message: "Invalid product ID",
      });
    }

    const product =
      await Product.findById(id);

    if (!product) {
      return res.status(404).json({
        success: false,
        message: "Product not found",
      });
    }

    if (product.isDeleted) {
      return res.status(400).json({
        success: false,
        message:
          "Deleted product cannot be rejected",
      });
    }

    const reason =
      rejectionReason &&
      String(rejectionReason).trim()
        ? String(rejectionReason).trim()
        : "Product rejected by admin";

    product.approvalStatus =
      "rejected";

    product.rejectionReason =
      reason;

    product.rejectedAt =
      new Date();

    product.approvedAt = null;

    product.approvedBy =
      admin._id;

    product.isActive = false;

    product.isMarketplaceVisible =
      false;

    await product.save();

    const updatedProduct =
      await Product.findById(id)
        .populate(
          "seller",
          "name email phone farmName farmLocation"
        )
        .populate(
          "approvedBy",
          "name email"
        );

    return res.status(200).json({
      success: true,
      message:
        "Product rejected successfully",
      product: updatedProduct,
    });
  } catch (error) {
    console.error(
      "ADMIN REJECT PRODUCT ERROR:",
      error
    );

    return res.status(500).json({
      success: false,
      message:
        "Failed to reject product",
      error: error.message,
    });
  }
};

// ==========================================================
// GET ORDERS
//
// GET /api/admin/orders
//
// Shows:
// buyer
// seller
// product
// delivery
// payment
// status
// ==========================================================

const getOrders = async (req, res) => {
  try {
    const admin = await checkAdmin(
      req,
      res
    );

    if (!admin) return;

    const orders = await Order.find()
      .populate(
        "buyer",
        "name email phone status"
      )
      .populate(
        "seller",
        "name email phone farmName farmLocation status"
      )
      .populate(
        "product",
        "name category price quantity unit image approvalStatus"
      )
      .sort({ createdAt: -1 });

    return res.status(200).json({
      success: true,
      count: orders.length,
      orders,
    });
  } catch (error) {
    console.error(
      "GET ADMIN ORDERS ERROR:",
      error
    );

    return res.status(500).json({
      success: false,
      message: "Failed to load orders",
      error: error.message,
    });
  }
};

// ==========================================================
// UPDATE ORDER STATUS
//
// PUT /api/admin/orders/:id/status
//
// Body:
// {
//   "status": "processing",
//   "note": "Order is being processed"
// }
// ==========================================================

const updateOrderStatus = async (
  req,
  res
) => {
  try {
    const admin = await checkAdmin(
      req,
      res
    );

    if (!admin) return;

    const { id } = req.params;

    const {
      status,
      note,
    } = req.body;

    if (!isValidObjectId(id)) {
      return res.status(400).json({
        success: false,
        message: "Invalid order ID",
      });
    }

    const allowedStatuses = [
      "pending",
      "accepted",
      "rejected",
      "processing",
      "shipped",
      "out_for_delivery",
      "delivered",
      "cancelled",
    ];

    const newStatus =
      String(status || "")
        .trim()
        .toLowerCase();

    if (
      !allowedStatuses.includes(
        newStatus
      )
    ) {
      return res.status(400).json({
        success: false,
        message:
          "Invalid order status",
        allowedStatuses,
      });
    }

    const order =
      await Order.findById(id);

    if (!order) {
      return res.status(404).json({
        success: false,
        message: "Order not found",
      });
    }

    const oldStatus =
      order.status;

    // ======================================================
    // UPDATE STATUS
    // ======================================================

    order.status =
      newStatus;

    // ======================================================
    // STATUS HISTORY
    // ======================================================

    order.statusHistory.push({
      status: newStatus,
      updatedBy: "admin",
      note:
        note &&
        String(note).trim()
          ? String(note).trim()
          : `Order status changed from ${oldStatus} to ${newStatus}`,
      date: new Date(),
    });

    // ======================================================
    // DELIVERY
    // ======================================================

    if (
      newStatus === "delivered"
    ) {
      order.deliveredAt =
        new Date();
    }

    // ======================================================
    // CANCELLATION
    // ======================================================

    if (
      newStatus === "cancelled"
    ) {
      order.cancelledBy =
        "admin";

      order.cancellationReason =
        note &&
        String(note).trim()
          ? String(note).trim()
          : "Order cancelled by admin";
    }

    await order.save();

    const updatedOrder =
      await Order.findById(id)
        .populate(
          "buyer",
          "name email phone status"
        )
        .populate(
          "seller",
          "name email phone farmName farmLocation status"
        )
        .populate(
          "product",
          "name category price quantity unit image"
        );

    return res.status(200).json({
      success: true,
      message:
        "Order status updated successfully",
      order: updatedOrder,
    });
  } catch (error) {
    console.error(
      "UPDATE ORDER STATUS ERROR:",
      error
    );

    return res.status(500).json({
      success: false,
      message:
        "Failed to update order status",
      error: error.message,
    });
  }
};

// ==========================================================
// GET PAYMENTS
//
// GET /api/admin/payments
//
// IMPORTANT:
// There is no separate Payment model in the files provided.
// Payment information comes from Order.
// ==========================================================

const getPayments = async (req, res) => {
  try {
    const admin = await checkAdmin(
      req,
      res
    );

    if (!admin) return;

    const payments =
      await Order.find({
        paymentMethod: {
          $exists: true,
        },
      })
        .select(
          [
            "_id",
            "orderNumber",
            "buyer",
            "buyerName",
            "buyerEmail",
            "buyerPhone",
            "seller",
            "sellerName",
            "product",
            "productName",
            "totalAmount",
            "paymentMethod",
            "paymentStatus",
            "status",
            "createdAt",
            "updatedAt",
          ].join(" ")
        )
        .populate(
          "buyer",
          "name email phone"
        )
        .populate(
          "seller",
          "name email phone farmName farmLocation"
        )
        .populate(
          "product",
          "name image price"
        )
        .sort({ createdAt: -1 });

    const summary = {
      totalPayments:
        payments.length,

      pending: payments.filter(
        (payment) =>
          payment.paymentStatus ===
          "pending"
      ).length,

      paid: payments.filter(
        (payment) =>
          payment.paymentStatus ===
          "paid"
      ).length,

      failed: payments.filter(
        (payment) =>
          payment.paymentStatus ===
          "failed"
      ).length,

      refunded: payments.filter(
        (payment) =>
          payment.paymentStatus ===
          "refunded"
      ).length,

      totalAmount: payments.reduce(
        (sum, payment) =>
          sum +
          Number(
            payment.totalAmount || 0
          ),
        0
      ),

      paidAmount: payments
        .filter(
          (payment) =>
            payment.paymentStatus ===
            "paid"
        )
        .reduce(
          (sum, payment) =>
            sum +
            Number(
              payment.totalAmount || 0
            ),
          0
        ),
    };

    return res.status(200).json({
      success: true,
      count: payments.length,
      summary,
      payments,
    });
  } catch (error) {
    console.error(
      "GET ADMIN PAYMENTS ERROR:",
      error
    );

    return res.status(500).json({
      success: false,
      message:
        "Failed to load payments",
      error: error.message,
    });
  }
};

// ==========================================================
// EXPORT
// ==========================================================

module.exports = {
  adminLogin,
  getDashboardStats,
  getUsers,
  getProducts,
  approveProduct,
  rejectProduct,
  getOrders,
  updateOrderStatus,
  getPayments,
};
