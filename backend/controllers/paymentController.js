const Payment = require("../models/Payment");
const Order = require("../models/orderModel");
const Notification = require("../models/Notification");

// ==========================================
// CREATE PAYMENT
// ==========================================

const createPayment = async (req, res) => {
  try {
    const {
      order,
      buyer,
      amount,
      paymentMethod,
      transactionId,
      gateway,
    } = req.body;

    if (
      !order ||
      !buyer ||
      amount === undefined ||
      !paymentMethod
    ) {
      return res.status(400).json({
        success: false,
        message:
          "Order, buyer, amount and payment method are required",
      });
    }

    const orderData = await Order.findById(
      order
    );

    if (!orderData) {
      return res.status(404).json({
        success: false,
        message: "Order not found",
      });
    }

    // COD does not need online verification
    const paymentStatus =
      paymentMethod === "Cash on Delivery"
        ? "pending"
        : transactionId
        ? "paid"
        : "pending";

    const payment = new Payment({
      order,
      buyer,
      amount: Number(amount),
      paymentMethod,
      status: paymentStatus,
      transactionId:
        transactionId || "",
      gateway: gateway || "",
      paidAt:
        paymentStatus === "paid"
          ? new Date()
          : null,
    });

    await payment.save();

    // Connect payment to order
    orderData.payment = payment._id;

    orderData.paymentMethod =
      paymentMethod;

    orderData.paymentStatus =
      paymentStatus;

    await orderData.save();

    await Notification.create({
      user: buyer,
      title: "Payment Update",
      message:
        `Payment for order ${orderData.orderNumber} is ${paymentStatus}.`,
      type: "payment",
      order: orderData._id,
    });

    return res.status(201).json({
      success: true,
      message: "Payment created successfully",
      payment,
    });
  } catch (error) {
    console.log(
      "========== PAYMENT ERROR =========="
    );
    console.log(error);

    return res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// ==========================================
// GET PAYMENT BY ID
// ==========================================

const getPaymentById = async (req, res) => {
  try {
    const payment =
      await Payment.findById(
        req.params.id
      )
        .populate(
          "order",
          "orderNumber totalAmount status"
        )
        .populate(
          "buyer",
          "name email phone"
        );

    if (!payment) {
      return res.status(404).json({
        success: false,
        message: "Payment not found",
      });
    }

    return res.status(200).json({
      success: true,
      payment,
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// ==========================================
// PAYMENT HISTORY
// ==========================================

const getPaymentHistory = async (
  req,
  res
) => {
  try {
    const { buyer } = req.query;

    const filter = {};

    if (buyer) {
      filter.buyer = buyer;
    }

    const payments =
      await Payment.find(filter)
        .populate(
          "order",
          "orderNumber totalAmount status"
        )
        .sort({ createdAt: -1 });

    return res.status(200).json({
      success: true,
      count: payments.length,
      payments,
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// ==========================================
// UPDATE PAYMENT STATUS
// ==========================================

const updatePaymentStatus = async (
  req,
  res
) => {
  try {
    const { status, transactionId } =
      req.body;

    const allowedStatuses = [
      "pending",
      "paid",
      "failed",
      "refunded",
    ];

    if (
      !allowedStatuses.includes(status)
    ) {
      return res.status(400).json({
        success: false,
        message: "Invalid payment status",
      });
    }

    const payment =
      await Payment.findById(
        req.params.id
      );

    if (!payment) {
      return res.status(404).json({
        success: false,
        message: "Payment not found",
      });
    }

    payment.status = status;

    if (transactionId) {
      payment.transactionId =
        transactionId;
    }

    if (status === "paid") {
      payment.paidAt = new Date();
    }

    await payment.save();

    // Update order
    await Order.findByIdAndUpdate(
      payment.order,
      {
        paymentStatus: status,
      }
    );

    return res.status(200).json({
      success: true,
      message:
        "Payment status updated successfully",
      payment,
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

module.exports = {
  createPayment,
  getPaymentById,
  getPaymentHistory,
  updatePaymentStatus,
};