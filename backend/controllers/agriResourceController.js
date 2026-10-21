const AgriResource = require("../models/AgriResource");
const AgriResourceOrder = require("../models/AgriResourceOrder");
const Notification = require("../models/Notification");

// Farmer: Add new resource
exports.addResource = async (req, res) => {
  try {
    const { name, category, sellerName, price, phoneNumber, description } = req.body;
    const image = req.file ? req.file.filename : "";

    if (!image) return res.status(400).json({ message: "Photo is required" });

    const resource = new AgriResource({
      name,
      category,
      sellerName,
      sellerId: req.user.id,
      price,
      phoneNumber,
      image,
      description,
    });

    await resource.save();
    res.status(201).json({ success: true, resource });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// User & Farmer: Get all approved resources
exports.getApprovedResources = async (req, res) => {
  try {
    const resources = await AgriResource.find({ status: "approved" }).sort({ createdAt: -1 });
    res.status(200).json({ success: true, resources });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Farmer: Get own resources
exports.getMyResources = async (req, res) => {
  try {
    const resources = await AgriResource.find({ sellerId: req.user.id }).sort({ createdAt: -1 });
    res.status(200).json({ success: true, resources });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// User: Place order
exports.placeOrder = async (req, res) => {
  try {
    const { buyerName, resourceId, sellerId, price, paymentMethod, buyerPhone, deliveryAddress } = req.body;

    const order = new AgriResourceOrder({
      buyerName,
      buyerId: req.user.id,
      resourceId,
      sellerId,
      price,
      paymentMethod,
      buyerPhone,
      deliveryAddress,
    });

    await order.save();

    // ======================================================
    // CREATE NOTIFICATION FOR FARMER
    // ======================================================
    try {
      await Notification.create({
        recipient: sellerId,
        recipientModel: "Farmer",
        title: "New Agri Resource Order! 🚜",
        message: `${buyerName} wants to buy your agri resource.`,
        type: "order",
        data: {
          screen: "agri_resources_orders",
        },
      });
    } catch (notifErr) {
      console.error("NOTIFICATION ERROR:", notifErr.message);
    }

    res.status(201).json({ success: true, order });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Farmer: Get orders for their resources
exports.getFarmerOrders = async (req, res) => {
  try {
    const orders = await AgriResourceOrder.find({ sellerId: req.user.id })
      .populate("resourceId")
      .sort({ createdAt: -1 });

    // Filter out orders where the material was deleted
    const validOrders = orders.filter((order) => order.resourceId !== null);

    res.status(200).json({ success: true, orders: validOrders });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Farmer: Accept order
exports.acceptOrder = async (req, res) => {
  try {
    const order = await AgriResourceOrder.findByIdAndUpdate(
      req.params.id,
      { status: "accepted" },
      { new: true }
    );
    res.status(200).json({ success: true, order });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// User: Cancel order
exports.cancelOrder = async (req, res) => {
  try {
    const order = await AgriResourceOrder.findByIdAndUpdate(
      req.params.id,
      { status: "cancelled" },
      { new: true }
    );
    res.status(200).json({ success: true, order });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// User: Get own orders
exports.getUserOrders = async (req, res) => {
  try {
    const orders = await AgriResourceOrder.find({ buyerId: req.user.id })
      .populate("resourceId")
      .sort({ createdAt: -1 });

    // Filter out orders where the material was deleted
    const validOrders = orders.filter((order) => order.resourceId !== null);

    res.status(200).json({ success: true, orders: validOrders });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Farmer: Delete resource
exports.deleteResource = async (req, res) => {
  try {
    const resourceId = req.params.id;

    // Delete the resource
    await AgriResource.findByIdAndDelete(resourceId);

    // Also delete all orders associated with this resource
    await AgriResourceOrder.deleteMany({ resourceId });

    res.status(200).json({ success: true, message: "Resource and related orders deleted" });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Farmer: Update resource
exports.updateResource = async (req, res) => {
  try {
    const { name, category, price, phoneNumber, description } = req.body;

    const updateData = {
      name,
      category,
      price,
      phoneNumber,
      description,
      status: "pending", // Reset to pending after edit for admin re-approval
    };

    if (req.file) {
      updateData.image = req.file.filename;
    }

    const resource = await AgriResource.findByIdAndUpdate(
      req.params.id,
      updateData,
      { new: true }
    );

    res.status(200).json({ success: true, resource });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
