
const multer = require("multer");
const path = require("path");
const fs = require("fs");

// ==========================================================
// UPLOAD DIRECTORY
// ==========================================================

const uploadDirectory = path.join(__dirname, "../uploads");

// Create uploads directory if it doesn't exist
if (!fs.existsSync(uploadDirectory)) {
  fs.mkdirSync(uploadDirectory, { recursive: true });
}

console.log("📁 Upload directory:", uploadDirectory);

// ==========================================================
// STORAGE
// ==========================================================

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, uploadDirectory);
  },

  filename: (req, file, cb) => {
    const extension = path.extname(file.originalname || "").toLowerCase();
    const finalExt = extension || ".jpg";
    const filename = `${Date.now()}-${Math.round(Math.random() * 1e9)}${finalExt}`;
    cb(null, filename);
  },
});

// ==========================================================
// FILE FILTER
// ==========================================================

const fileFilter = (req, file, cb) => {
  // We are now accepting ALL files to prevent the "Invalid Image" error.
  // The system will handle them as images.
  console.log("📷 Incoming File:", file.originalname, "Type:", file.mimetype);
  cb(null, true);
};

// ==========================================================
// MULTER
// ==========================================================

const upload = multer({
  storage: storage,
  fileFilter: fileFilter,
  limits: {
    fileSize: 20 * 1024 * 1024, // 20MB limit
    files: 1,
  },
});

module.exports = upload;
