const dns = require("dns");
const mongoose = require("mongoose");

// Fix for querySrv ECONNREFUSED on Windows / local ISP DNS resolvers
try {
  dns.setServers(["8.8.8.8", "8.8.4.4"]);
} catch (e) {
  // Fallback gracefully if setServers is unavailable
}

// CONNECT DB
// ==========================================================

const connectDB = async () => {
  try {
    const conn = await mongoose.connect(process.env.MONGO_URI, {
      serverSelectionTimeoutMS: 15000,
    });

    console.log("======================================");
    console.log(`✅ MongoDB Connected: ${conn.connection.host}`);
    console.log(`📦 Database: ${conn.connection.name}`);
    console.log("======================================");
  } catch (error) {
    console.error("======================================");
    console.error("❌ MongoDB Connection Failed:");
    console.error(error.message);
    console.error("======================================");
    process.exit(1);
  }
};

module.exports = connectDB;