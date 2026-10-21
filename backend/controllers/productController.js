
const mongoose = require("mongoose");

const Product = require("../models/productModel");
const Farmer = require("../models/farmerModel");
const Admin = require("../models/adminModel");

// ==========================================================
// HELPER: CHECK OBJECT ID
// ==========================================================

const isValidObjectId = (id) => {
  return mongoose.Types.ObjectId.isValid(id);
};

// ==========================================================
// CREATE PRODUCT
// FARMER
// ==========================================================

const createProduct = async (req, res) => {
  try {
    console.log("======================================");
    console.log("CREATE PRODUCT");
    console.log("BODY:", req.body);
    console.log("FILE:", req.file);
    console.log("======================================");

    const {
      name,
      category,
      description,
      price,
      quantity,
      unit,
    } = req.body;

    // ======================================================
    // AUTHENTICATION
    // ======================================================

    if (!req.user) {
      return res.status(401).json({
        success: false,
        message: "Authentication required",
      });
    }

    const farmerId = req.user.id || req.user._id || req.user.userId;

    if (!farmerId || !isValidObjectId(farmerId)) {
      return res.status(401).json({
        success: false,
        message: "Invalid farmer session",
      });
    }

    // ======================================================
    // CHECK ROLE
    // ======================================================

    if (req.user.role && req.user.role.toLowerCase() !== "farmer") {
      return res.status(403).json({
        success: false,
        message: "Only farmers can create products",
      });
    }

    // ======================================================
    // VALIDATION
    // ======================================================

    if (!name || !String(name).trim()) {
      return res.status(400).json({
        success: false,
        message: "Product name is required",
      });
    }

    if (!category || !String(category).trim()) {
      return res.status(400).json({
        success: false,
        message: "Category is required",
      });
    }

    // ======================================================
    // FIND FARMER
    // ======================================================

    const farmer = await Farmer.findById(farmerId);

    if (!farmer) {
      return res.status(404).json({
        success: false,
        message: "Farmer not found",
      });
    }

    // ======================================================
    // CREATE PRODUCT
    // ======================================================

    // Ensure category starts with a capital letter for consistency with frontend filters
    const formattedCategory = String(category).trim().charAt(0).toUpperCase() + String(category).trim().slice(1).toLowerCase();

    const product = new Product({
      name: String(name).trim(),
      category: formattedCategory,
      description: description ? String(description).trim() : "",
      price: Number(price) || 0,
      quantity: Number(quantity) || 0,
      unit: unit ? String(unit).trim() : "Kg",

      // SAVE FILENAME FROM MULTER
      image: req.file ? req.file.filename : "",

      seller: farmer._id,
      sellerName: farmer.name || "",
      sellerPhone: farmer.phone || "",
      sellerLocation: farmer.farmLocation || "",

      approvalStatus: "pending",
      isMarketplaceVisible: false,
    });

    await product.save();

    return res.status(201).json({
      success: true,
      message: "Product uploaded successfully. Waiting for admin approval.",
      product,
    });
  } catch (error) {
    console.error("CREATE PRODUCT ERROR:", error);
    return res.status(500).json({
      success: false,
      message: "Failed to create product",
    });
  }
};

// ==========================================================
// GET APPROVED PRODUCTS
// USER MARKETPLACE
// ==========================================================

const getApprovedProducts = async (req, res) => {
  try {
    const products = await Product.find({
      approvalStatus: "approved",
      isActive: true,
      isDeleted: false,
      isMarketplaceVisible: true,
      quantity: { $gt: 0 },
    })
      .populate(
        "seller",
        "name email phone farmName farmLocation"
      )
      .sort({ createdAt: -1 });

    return res.status(200).json({
      success: true,
      count: products.length,
      products,
    });
  } catch (error) {
    console.error("GET MARKETPLACE ERROR:", error);
    return res.status(500).json({
      success: false,
      message: "Failed to load marketplace",
    });
  }
};

// ==========================================================
// GET PRODUCT BY ID
// ==========================================================

const getProductById = async (req, res) => {
  try {
    const { id } = req.params;
    if (!isValidObjectId(id)) return res.status(400).json({ success: false, message: "Invalid product ID" });

    const product = await Product.findOne({ _id: id, isDeleted: false }).populate("seller", "name phone farmName farmLocation");
    if (!product) return res.status(404).json({ success: false, message: "Product not found" });

    return res.status(200).json({ success: true, product });
  } catch (error) {
    return res.status(500).json({ success: false, message: "Failed to get product" });
  }
};

// ==========================================================
// GET FARMER PRODUCTS
// ==========================================================

const getMyProducts = async (req, res) => {
  try {
    if (!req.user) return res.status(401).json({ success: false, message: "Authentication required" });
    const farmerId = req.user.id || req.user._id || req.user.userId;

    const products = await Product.find({ seller: farmerId, isDeleted: false }).sort({ createdAt: -1 });
    return res.status(200).json({ success: true, count: products.length, products });
  } catch (error) {
    return res.status(500).json({ success: false, message: "Failed to load farmer products" });
  }
};

// ==========================================================
// GET PENDING PRODUCTS
// ADMIN
// ==========================================================

const getPendingProducts = async (req, res) => {
  try {
    const products = await Product.find({ approvalStatus: "pending", isDeleted: false }).populate("seller", "name farmName").sort({ createdAt: -1 });
    return res.status(200).json({ success: true, count: products.length, products });
  } catch (error) {
    return res.status(500).json({ success: false, message: "Failed to load pending products" });
  }
};

// ==========================================================
// APPROVE PRODUCT
// ADMIN
// ==========================================================

const approveProduct = async (req, res) => {
  try {
    const { id } = req.params;
    const adminId = req.user.id || req.user._id;

    const product = await Product.findById(id);
    if (!product) return res.status(404).json({ success: false, message: "Product not found" });

    product.approvalStatus = "approved";
    product.approvedAt = new Date();
    product.approvedBy = adminId;
    product.isMarketplaceVisible = true;

    await product.save();
    return res.status(200).json({ success: true, message: "Product approved", product });
  } catch (error) {
    return res.status(500).json({ success: false, message: "Failed to approve" });
  }
};

// ==========================================================
// REJECT PRODUCT
// ADMIN
// ==========================================================

const rejectProduct = async (req, res) => {
  try {
    const { id } = req.params;
    const { rejectionReason } = req.body;

    const product = await Product.findById(id);
    if (!product) return res.status(404).json({ success: false, message: "Product not found" });

    product.approvalStatus = "rejected";
    product.rejectionReason = rejectionReason || "Rejected by admin";
    product.rejectedAt = new Date();
    product.isMarketplaceVisible = false;

    await product.save();
    return res.status(200).json({ success: true, message: "Product rejected", product });
  } catch (error) {
    return res.status(500).json({ success: false, message: "Failed to reject" });
  }
};

// ==========================================================
// UPDATE PRODUCT
// FARMER
// ==========================================================

const updateProduct = async (req, res) => {
  try {
    const { id } = req.params;
    const { name, category, description, price, quantity, unit } = req.body;

    const product = await Product.findById(id);
    if (!product) return res.status(404).json({ success: false, message: "Product not found" });

    if (name) product.name = name;
    if (category) {
      product.category = String(category).trim().charAt(0).toUpperCase() + String(category).trim().slice(1).toLowerCase();
    }
    if (description) product.description = description;
    if (price) product.price = Number(price);
    if (quantity) product.quantity = Number(quantity);
    if (unit) product.unit = unit;

    // UPDATE IMAGE IF NEW FILE UPLOADED
    if (req.file) {
      product.image = req.file.filename;
    }

    // Reset approval status after edit
    product.approvalStatus = "pending";
    product.isMarketplaceVisible = false;

    await product.save();
    return res.status(200).json({ success: true, message: "Product updated", product });
  } catch (error) {
    return res.status(500).json({ success: false, message: "Failed to update" });
  }
};

// ==========================================================
// DELETE PRODUCT
// FARMER
// ==========================================================

const deleteProduct = async (req, res) => {
  try {
    const { id } = req.params;
    const product = await Product.findById(id);
    if (!product) return res.status(404).json({ success: false, message: "Product not found" });

    product.isDeleted = true;
    product.isMarketplaceVisible = false;
    product.deletedAt = new Date();

    await product.save();
    return res.status(200).json({ success: true, message: "Product deleted" });
  } catch (error) {
    return res.status(500).json({ success: false, message: "Failed to delete" });
  }
};

module.exports = {
  createProduct,
  getApprovedProducts,
  getProductById,
  getMyProducts,
  getPendingProducts,
  approveProduct,
  rejectProduct,
  updateProduct,
  deleteProduct,
};
