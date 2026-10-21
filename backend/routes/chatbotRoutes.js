const express = require("express");

const {
  sendChatbotMessage,
} = require("../controllers/chatbotController");

const router = express.Router();

// ==========================================================
// CHATBOT HEALTH CHECK
//
// GET /api/chatbot
// ==========================================================

router.get("/", (req, res) => {
  return res.status(200).json({
    success: true,
    message: "🌾 Agrii AI Chatbot API is Running!",
  });
});

// ==========================================================
// SEND CHATBOT MESSAGE
//
// POST /api/chatbot/message
//
// Request:
//
// {
//   "message": "Which season is best for paddy?"
// }
//
// Response:
//
// {
//   "success": true,
//   "reply": "For paddy cultivation..."
// }
//
// ==========================================================

router.post(
  "/message",
  sendChatbotMessage
);

module.exports = router;