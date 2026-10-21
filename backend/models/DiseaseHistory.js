const mongoose = require("mongoose");

const diseaseHistorySchema = new mongoose.Schema(
  {
    plantName: {
      type: String,
      required: true,
    },

    diseaseName: {
      type: String,
      required: true,
    },

    imageUrl: {
      type: String,
      default: "",
    },

    symptoms: {
      type: String,
      default: "",
    },

    causes: {
      type: String,
      default: "",
    },

    treatment: {
      type: String,
      default: "",
    },

    prevention: {
      type: String,
      default: "",
    },

    confidence: {
      type: String,
      default: "",
    },

    createdAt: {
      type: Date,
      default: Date.now,
    },
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model(
  "DiseaseHistory",
  diseaseHistorySchema
);