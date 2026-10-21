const mongoose = require("mongoose");

const Order = require("../models/orderModel");
const Product = require("../models/productModel");
const User = require("../models/userModel");
const Farmer = require("../models/farmerModel");
const Notification = require("../models/Notification");

// ==========================================================
// HELPER
// ==========================================================

const isValidObjectId = (id) => {
  return mongoose.Types.ObjectId.isValid(id);
};

// ==========================================================
// CREATE ORDER
// USER
// ==========================================================

const createOrder = async (req, res) => {
  try {
    const {
      buyer,
      buyerName,
      product,
      quantity,
      deliveryAddress,
      deliveryCity,
      deliveryPincode,
      paymentMethod,
    } = req.body;

    // ======================================================
    // VALIDATION
    // ======================================================

    if (
      !buyer ||
      !product ||
      quantity === undefined ||
      !deliveryAddress
    ) {
      return res.status(400).json({
        success: false,
        message:
          "Buyer, product, quantity and delivery address are required",
      });
    }

    if (
      !isValidObjectId(buyer) ||
      !isValidObjectId(product)
    ) {
      return res.status(400).json({
        success: false,
        message: "Invalid buyer or product ID",
      });
    }

    const numericQuantity = Number(quantity);

    if (
      !Number.isFinite(numericQuantity) ||
      numericQuantity <= 0
    ) {
      return res.status(400).json({
        success: false,
        message: "Quantity must be greater than 0",
      });
    }

    // ======================================================
    // FIND BUYER
    // ======================================================

    const user = await User.findById(buyer);

    if (!user) {
      return res.status(404).json({
        success: false,
        message: "Buyer not found",
      });
    }

    // ======================================================
    // FIND PRODUCT
    // ======================================================

    const productData = await Product.findById(product);

    if (!productData) {
      return res.status(404).json({
        success: false,
        message: "Product not found",
      });
    }

    // ======================================================
    // CHECK STOCK
    // ======================================================

    if (numericQuantity > productData.quantity) {
      return res.status(400).json({
        success: false,
        message: `Only ${productData.quantity} ${productData.unit} available`,
      });
    }

    // ======================================================
    // FIND FARMER
    // ======================================================

    const farmer = await Farmer.findById(productData.seller);

    if (!farmer) {
      return res.status(404).json({
        success: false,
        message: "Product seller/farmer not found",
      });
    }

    // ======================================================
    // CREATE ORDER
    // ======================================================

    const order = new Order({
      buyer: user._id,
      buyerName: buyerName || user.name, // Use provided name or default to registered name
      buyerEmail: user.email || "",
      buyerPhone: req.body.phone || user.phone,
      seller: farmer._id,
      sellerName: farmer.name,
      sellerPhone: farmer.phone || "",
      sellerLocation: farmer.farmLocation || "",
      product: productData._id,
      productName: productData.name,
      productImage: productData.image || "",
      productPrice: productData.price,
      quantity: numericQuantity,
      unit: productData.unit || "Kg",
      totalAmount: productData.price * numericQuantity,
      deliveryAddress: String(deliveryAddress).trim(),
      deliveryCity: deliveryCity ? String(deliveryCity).trim() : "",
      deliveryPincode: deliveryPincode ? String(deliveryPincode).trim() : "",
      paymentMethod: paymentMethod || "cash_on_delivery",
      paymentStatus: "pending",
      status: "pending",
      statusHistory: [
        {
          status: "pending",
          updatedBy: "user",
          note: "Order placed successfully",
        },
      ],
    });

    await order.save();

    // ======================================================
    // CREATE NOTIFICATION FOR FARMER
    // ======================================================
    try {
      await Notification.create({
        recipient: farmer._id,
        recipientModel: "Farmer",
        title: "New Order Received! 📦",
        message: `${user.name} has ordered ${numericQuantity} ${productData.unit} of ${productData.name}.`,
        type: "order",
        order: order._id,
        product: productData._id,
        data: {
          screen: "orders",
        },
      });
    } catch (notifErr) {
      console.error("NOTIFICATION ERROR:", notifErr.message);
    }

    // Reduce stock
    productData.quantity -= numericQuantity;
    if (productData.quantity <= 0) {
      productData.quantity = 0;
      productData.isActive = false;
    }
    await productData.save();

    return res.status(201).json({
      success: true,
      message: "Order placed successfully",
      order,
    });
  } catch (error) {
    console.error("CREATE ORDER ERROR:", error);
    return res.status(500).json({
      success: false,
      message: error.message || "Failed to create order",
    });
  }
};

const getUserOrders = async (req, res) => {
  try {
    const userId = req.params.userId || req.user.id;
    const orders = await Order.find({ buyer: userId })
      .populate("product", "name category price image unit")
      .populate("seller", "name email phone farmName farmLocation")
      .sort({ createdAt: -1 });
    return res.status(200).json({ success: true, count: orders.length, orders });
  } catch (error) {
    return res.status(500).json({ success: false, message: "Error" });
  }
};

const getFarmerOrders = async (req, res) => {
  try {
    const farmerId = req.params.farmerId || req.user.id;
    const orders = await Order.find({ seller: farmerId })
      .populate("buyer", "name email phone")
      .populate("product", "name category price image unit")
      .sort({ createdAt: -1 });
    return res.status(200).json({ success: true, count: orders.length, orders });
  } catch (error) {
    return res.status(500).json({ success: false, message: "Error" });
  }
};

const getOrderById = async (req, res) => {
  try {
    const { id } = req.params;
    const order = await Order.findById(id)
      .populate("buyer", "name email phone")
      .populate("seller", "name email phone farmName farmLocation")
      .populate("product", "name category price image unit");
    if (!order) return res.status(404).json({ success: false, message: "Order not found" });
    return res.status(200).json({ success: true, order });
  } catch (error) {
    return res.status(500).json({ success: false, message: "Error" });
  }
};

const acceptOrder = async (req, res) => {
  try {
    const { id } = req.params;
    const farmerId = req.user.id;
    const order = await Order.findById(id);
    if (!order) return res.status(404).json({ success: false, message: "Order not found" });
    if (String(order.seller) !== String(farmerId)) return res.status(403).json({ success: false, message: "Forbidden" });
    order.status = "accepted";
    order.statusHistory.push({ status: "accepted", updatedBy: "farmer", note: "Farmer accepted" });
    await order.save();
    return res.status(200).json({ success: true, order });
  } catch (error) {
    return res.status(500).json({ success: false, message: "Error" });
  }
};

const rejectOrder = async (req, res) => {
  try {
    const { id } = req.params;
    const { reason } = req.body;
    const farmerId = req.user.id;
    const order = await Order.findById(id);
    if (!order) return res.status(404).json({ success: false, message: "Order not found" });
    if (String(order.seller) !== String(farmerId)) return res.status(403).json({ success: false, message: "Forbidden" });
    order.status = "rejected";
    order.cancellationReason = reason || "Rejected by farmer";
    order.statusHistory.push({ status: "rejected", updatedBy: "farmer", note: order.cancellationReason });
    await order.save();
    const product = await Product.findById(order.product);
    if (product) { product.quantity += order.quantity; product.isActive = true; await product.save(); }
    return res.status(200).json({ success: true, order });
  } catch (error) {
    return res.status(500).json({ success: false, message: "Error" });
  }
};

const updateOrderStatus = async (req, res) => {
  try {
    const { id } = req.params;
    const { status, note } = req.body;
    const order = await Order.findById(id);
    if (!order) return res.status(404).json({ success: false, message: "Order not found" });
    order.status = status;
    order.statusHistory.push({ status, updatedBy: req.user.role, note: note || `Status updated to ${status}` });
    if (status === "delivered") order.deliveredAt = new Date();
    await order.save();
    return res.status(200).json({ success: true, order });
  } catch (error) {
    return res.status(500).json({ success: false, message: "Error" });
  }
};

const cancelOrder = async (req, res) => {
  try {
    const { id } = req.params;
    const buyerId = req.user.id;
    const order = await Order.findById(id);
    if (!order) return res.status(404).json({ success: false, message: "Order not found" });
    if (String(order.buyer) !== String(buyerId)) return res.status(403).json({ success: false, message: "Forbidden" });
    order.status = "cancelled";
    order.statusHistory.push({ status: "cancelled", updatedBy: "user", note: "Cancelled by user" });
    await order.save();
    const product = await Product.findById(order.product);
    if (product) { product.quantity += order.quantity; product.isActive = true; await product.save(); }
    return res.status(200).json({ success: true, order });
  } catch (error) {
    return res.status(500).json({ success: false, message: "Error" });
  }
};

const getAllOrders = async (req, res) => {
  try {
    const orders = await Order.find()
      .populate("buyer", "name phone")
      .populate("seller", "name phone farmName")
      .populate("product", "name price")
      .sort({ createdAt: -1 });
    return res.status(200).json({ success: true, count: orders.length, orders });
  } catch (error) {
    return res.status(500).json({ success: false, message: "Error" });
  }
};

module.exports = {
  createOrder,
  getUserOrders,
  getFarmerOrders,
  getOrderById,
  acceptOrder,
  rejectOrder,
  updateOrderStatus,
  cancelOrder,
  getAllOrders,
};
