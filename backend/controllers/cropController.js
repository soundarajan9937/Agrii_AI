const { GoogleGenAI } = require("@google/genai");

const ai = new GoogleGenAI({
  apiKey: process.env.GEMINI_API_KEY,
});

const getCropRecommendation = async (req, res) => {
  console.log("========== CROP REQUEST ==========");
  console.log(req.body);
  console.log("==================================");

  try {
    const { crop, soil, season, previousCrop } = req.body;

    if (!crop || !soil || !season || !previousCrop) {
      return res.status(400).json({
        success: false,
        message: "All fields are required",
      });
    }

    const prompt = `
You are an expert agriculture advisor.

Crop: ${crop}
Soil: ${soil}
Season: ${season}
Previous Crop: ${previousCrop}

Reply ONLY with valid JSON.

{
  "success": true,
  "recommendation": {
    "bestCrop": "",
    "expectedYield": "",
    "harvestTime": "",
    "fertilizer": "",
    "irrigation": "",
    "reason": ""
  }
}
`;

    const response = await ai.models.generateContent({
      model: "gemini-2.5-flash-001",
      contents: prompt,
    });

    let text = response.text;

    console.log("========== GEMINI RESPONSE ==========");
    console.log(text);
    console.log("=====================================");

    text = text.replace(/```json/g, "")
               .replace(/```/g, "")
               .trim();

    const data = JSON.parse(text);

    res.status(200).json(data);

  } catch (error) {
    console.log("========== CROP AI ERROR ==========");
    console.log(error);
    console.log("===================================");

    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

module.exports = {
  getCropRecommendation,
};