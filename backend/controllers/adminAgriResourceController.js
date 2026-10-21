const AgriResource = require("../models/AgriResource");

// Get all resources (pending, approved, rejected) for admin
exports.getAllResources = async (req, res) => {
  try {
    const resources = await AgriResource.find().sort({ createdAt: -1 });
    res.status(200).json({ success: true, resources });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Approve or Reject resource
exports.updateResourceStatus = async (req, res) => {
  try {
    const { status, rejectionReason } = req.body;
    if (!["approved", "rejected"].includes(status)) {
      return res.status(400).json({ message: "Invalid status" });
    }

    const updateData = { status };
    if (status === "rejected") {
      updateData.rejectionReason = rejectionReason || "No reason provided";
    } else {
      updateData.rejectionReason = ""; // Clear reason if approved
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
