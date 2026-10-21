const express = require("express");
const router = express.Router();
const {
  getNotifications,
  getUnreadCount,
  markAsRead,
  markAllAsRead,
  deleteNotification,
} = require("../controllers/notificationController");
const { authenticateToken } = require("../middleware/authMiddleware");

// ==========================================
// APPLY AUTH MIDDLEWARE TO ALL ROUTES
// ==========================================
router.use(authenticateToken);

router.get("/", getNotifications);
router.get("/unread-count", getUnreadCount);
router.put("/:id/read", markAsRead);
router.put("/read-all", markAllAsRead);
router.delete("/:id", deleteNotification);

module.exports = router;
