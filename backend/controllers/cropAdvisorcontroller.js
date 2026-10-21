const https = require("https");

// ==========================================================
// GEMINI CONFIGURATION
// ==========================================================

const GEMINI_API_KEY = process.env.GEMINI_API_KEY;

// Gemini 3.6 Flash is a stable model.
const GEMINI_MODEL = "gemini-3.6-flash";

// ==========================================================
// GEMINI REQUEST HELPER
// ==========================================================

const callGemini = (prompt) => {
  return new Promise((resolve, reject) => {
    // ------------------------------------------------------
    // CHECK API KEY
    // ------------------------------------------------------

    if (!GEMINI_API_KEY) {
      return reject(
        new Error(
          "GEMINI_API_KEY is missing in the .env file"
        )
      );
    }

    // ------------------------------------------------------
    // REQUEST BODY
    // ------------------------------------------------------

    const requestBody = JSON.stringify({
      contents: [
        {
          parts: [
            {
              text: prompt,
            },
          ],
        },
      ],

      generationConfig: {
        maxOutputTokens: 1500,

        // Force Gemini to return valid JSON.
        responseMimeType: "application/json",

        responseSchema: {
          type: "OBJECT",

          properties: {
            bestSuitedCrop: {
              type: "STRING",
            },

            alternativeCrop: {
              type: "STRING",
            },

            whyThisCrop: {
              type: "STRING",
            },

            expectedYield: {
              type: "STRING",
            },

            fertilizerSchedule: {
              type: "STRING",
            },

            wateringSchedule: {
              type: "STRING",
            },

            harvestWindow: {
              type: "STRING",
            },

            marketProfitability: {
              type: "STRING",
            },
          },

          required: [
            "bestSuitedCrop",
            "alternativeCrop",
            "whyThisCrop",
            "expectedYield",
            "fertilizerSchedule",
            "wateringSchedule",
            "harvestWindow",
            "marketProfitability",
          ],
        },
      },
    });

    // ------------------------------------------------------
    // HTTPS OPTIONS
    // ------------------------------------------------------

    const options = {
      hostname:
        "generativelanguage.googleapis.com",

      path:
        `/v1beta/models/${GEMINI_MODEL}:generateContent?key=${GEMINI_API_KEY}`,

      method: "POST",

      headers: {
        "Content-Type": "application/json",

        "Content-Length":
          Buffer.byteLength(requestBody),
      },
    };

    // ------------------------------------------------------
    // SEND REQUEST
    // ------------------------------------------------------

    const request = https.request(
      options,
      (response) => {
        let data = "";

        response.on("data", (chunk) => {
          data += chunk;
        });

        response.on("end", () => {
          try {
            const parsed = JSON.parse(data);

            // ------------------------------------------------
            // GEMINI ERROR
            // ------------------------------------------------

            if (
              response.statusCode < 200 ||
              response.statusCode >= 300
            ) {
              const apiError =
                parsed?.error?.message ||
                `Gemini API returned status ${response.statusCode}`;

              return reject(
                new Error(apiError)
              );
            }

            resolve(parsed);
          } catch (error) {
            console.error(
              "Gemini raw response:",
              data
            );

            reject(
              new Error(
                "Invalid response received from Gemini API"
              )
            );
          }
        });
      }
    );

    request.on("error", (error) => {
      reject(error);
    });

    request.setTimeout(40000, () => {
      request.destroy(
        new Error(
          "Gemini API request timed out"
        )
      );
    });

    request.write(requestBody);
    request.end();
  });
};

// ==========================================================
// GET CROP RECOMMENDATION
//
// POST /api/crop-advisor/recommend
// ==========================================================

const getCropRecommendation = async (
  req,
  res
) => {
  try {
    console.log(
      "======================================"
    );

    console.log(
      "🌱 CROP ADVISOR REQUEST"
    );

    console.log(
      "======================================"
    );

    // ======================================================
    // GET INPUT
    // ======================================================

    const {
      soil,
      season,
      duration,
      area,
      previousCrop,
    } = req.body;

    // ======================================================
    // VALIDATION
    // ======================================================

    if (
      !soil ||
      !season ||
      !duration ||
      !area ||
      !previousCrop
    ) {
      return res.status(400).json({
        success: false,

        message:
          "Soil, season, duration, area and previous crop are required",
      });
    }

    // ======================================================
    // CLEAN INPUT
    // ======================================================

    const cleanSoil =
      String(soil).trim();

    const cleanSeason =
      String(season).trim();

    const cleanDuration =
      String(duration).trim();

    const cleanArea =
      String(area).trim();

    const cleanPreviousCrop =
      String(previousCrop).trim();

    // ======================================================
    // CREATE PROMPT
    // ======================================================

    const prompt = `
You are Agrii AI, a professional agricultural crop advisor
helping farmers in India.

You MUST analyze the farmer information carefully and
recommend an ACTUAL crop.

FARMER INFORMATION

Current Season:
${cleanSeason}

Soil Type:
${cleanSoil}

Cultivation Duration:
${cleanDuration}

Land Area:
${cleanArea}

Previous Crop:
${cleanPreviousCrop}


YOUR TASK

Choose the BEST crop for this farmer.

You MUST provide an actual crop name.

For example:

Best crop = Chickpea

Do NOT leave the crop name empty.

Do NOT write:
"Recommended Crop:"

without a crop name.

Consider all of these:

1. Soil suitability
2. Current season
3. Previous crop
4. Crop rotation
5. Cultivation duration
6. Land area
7. Water requirements
8. Fertilizer requirements
9. General market potential

IMPORTANT:

- Give practical advice for an Indian farmer.
- Use simple English.
- Be specific.
- Do not guarantee profit.
- Do not invent guaranteed market prices.
- Yield must be an estimate.
- Fertilizer quantities are approximate and should depend on soil testing.
- Water requirements depend on rainfall, soil moisture and crop stage.
- Consider crop rotation from the previous crop.

VERY IMPORTANT:

The "bestSuitedCrop" field MUST contain an actual crop name.

The "alternativeCrop" field should contain one useful alternative crop.

The "whyThisCrop" field must explain:
- why the crop suits the soil
- why it suits the season
- how the previous crop affects crop rotation

The "expectedYield" field must provide an approximate yield
for the specified land area of ${cleanArea}.

The "fertilizerSchedule" field must give a simple practical
fertilizer schedule.

The "wateringSchedule" field must give simple irrigation
guidance.

The "harvestWindow" field must give an approximate harvesting
period.

The "marketProfitability" field must explain general market
potential without guaranteeing profit.

Return ONLY the requested structured JSON fields.
Do not use Markdown.
Do not use ###.
Do not use **.
Do not leave any required field empty.
`;

    console.log(
      "🌱 Farmer Details:"
    );

    console.log(
      `Season: ${cleanSeason}`
    );

    console.log(
      `Soil: ${cleanSoil}`
    );

    console.log(
      `Duration: ${cleanDuration}`
    );

    console.log(
      `Area: ${cleanArea}`
    );

    console.log(
      `Previous Crop: ${cleanPreviousCrop}`
    );

    console.log(
      "======================================"
    );

    console.log(
      "🌱 Sending request to Gemini..."
    );

    // ======================================================
    // CALL GEMINI
    // ======================================================

    const result =
      await callGemini(prompt);

    // ======================================================
    // CHECK CANDIDATES
    // ======================================================

    const candidates =
      result?.candidates;

    if (
      !Array.isArray(candidates) ||
      candidates.length === 0
    ) {
      console.error(
        "Gemini returned no candidates"
      );

      return res.status(502).json({
        success: false,

        message:
          "Gemini returned no recommendation",
      });
    }

    // ======================================================
    // GET PARTS
    // ======================================================

    const parts =
      candidates[0]?.content?.parts;

    if (
      !Array.isArray(parts) ||
      parts.length === 0
    ) {
      console.error(
        "Gemini returned no content parts"
      );

      return res.status(502).json({
        success: false,

        message:
          "Gemini returned an empty response",
      });
    }

    // ======================================================
    // GET TEXT
    // ======================================================

    const rawText =
      parts
        .map(
          (part) =>
            part?.text || ""
        )
        .join("")
        .trim();

    if (!rawText) {
      console.error(
        "Gemini returned empty text"
      );

      return res.status(502).json({
        success: false,

        message:
          "No crop recommendation was generated",
      });
    }

    console.log(
      "======================================"
    );

    console.log(
      "🌱 Gemini Raw Response:"
    );

    console.log(rawText);

    console.log(
      "======================================"
    );

    // ======================================================
    // PARSE JSON
    // ======================================================

    let aiData;

    try {
      aiData = JSON.parse(rawText);
    } catch (jsonError) {
      console.error(
        "Gemini JSON parsing error:",
        jsonError.message
      );

      return res.status(502).json({
        success: false,

        message:
          "Gemini returned an invalid recommendation format.",

        error:
          rawText,
      });
    }

    // ======================================================
    // VALIDATE REQUIRED AI FIELDS
    // ======================================================

    const bestSuitedCrop =
      String(
        aiData.bestSuitedCrop || ""
      ).trim();

    const alternativeCrop =
      String(
        aiData.alternativeCrop || ""
      ).trim();

    const whyThisCrop =
      String(
        aiData.whyThisCrop || ""
      ).trim();

    const expectedYield =
      String(
        aiData.expectedYield || ""
      ).trim();

    const fertilizerSchedule =
      String(
        aiData.fertilizerSchedule || ""
      ).trim();

    const wateringSchedule =
      String(
        aiData.wateringSchedule || ""
      ).trim();

    const harvestWindow =
      String(
        aiData.harvestWindow || ""
      ).trim();

    const marketProfitability =
      String(
        aiData.marketProfitability || ""
      ).trim();

    // ======================================================
    // CHECK CROP NAME
    // ======================================================

    if (!bestSuitedCrop) {
      console.error(
        "Gemini did not provide a crop name"
      );

      return res.status(502).json({
        success: false,

        message:
          "Gemini did not provide a recommended crop.",
      });
    }

    // ======================================================
    // BUILD CLEAN RESPONSE
    // ======================================================

    const recommendation = `
BEST SUITED CROP
${bestSuitedCrop}

ALTERNATIVE CROP
${alternativeCrop || "No alternative crop suggested."}

WHY THIS CROP
${whyThisCrop}

EXPECTED YIELD
${expectedYield}

FERTILIZER SCHEDULE
${fertilizerSchedule}

WATERING SCHEDULE
${wateringSchedule}

HARVEST WINDOW
${harvestWindow}

MARKET AND PROFITABILITY
${marketProfitability}

IMPORTANT
Yield, fertilizer requirements, watering requirements and
market conditions are estimates. Actual results depend on
soil testing, weather, irrigation, farming practices and
local market conditions.
`.trim();

    // ======================================================
    // LOG SUCCESS
    // ======================================================

    console.log(
      "======================================"
    );

    console.log(
      "✅ Crop recommendation generated successfully"
    );

    console.log(
      `🌱 Recommended Crop: ${bestSuitedCrop}`
    );

    console.log(
      "======================================"
    );

    // ======================================================
    // RESPONSE TO FLUTTER
    // ======================================================

    return res.status(200).json({
      success: true,

      message:
        "Crop recommendation generated successfully",

      recommendation,

      crop: bestSuitedCrop,

      alternativeCrop:
        alternativeCrop,

      details: {
        whyThisCrop,
        expectedYield,
        fertilizerSchedule,
        wateringSchedule,
        harvestWindow,
        marketProfitability,
      },
    });
  } catch (error) {
    // ======================================================
    // ERROR LOG
    // ======================================================

    console.error(
      "======================================"
    );

    console.error(
      "❌ CROP ADVISOR ERROR"
    );

    console.error(
      error.message
    );

    console.error(
      "======================================"
    );

    const errorMessage =
      String(
        error.message || ""
      );

    // ======================================================
    // API KEY ERROR
    // ======================================================

    if (
      errorMessage
        .toLowerCase()
        .includes("api key") ||
      errorMessage.includes(
        "API_KEY"
      )
    ) {
      return res.status(500).json({
        success: false,

        message:
          "Gemini API key is missing or invalid.",

        error:
          errorMessage,
      });
    }

    // ======================================================
    // MODEL ERROR
    // ======================================================

    if (
      errorMessage
        .toLowerCase()
        .includes("not found") ||
      errorMessage.includes(
        "NOT_FOUND"
      ) ||
      errorMessage
        .toLowerCase()
        .includes("model")
    ) {
      return res.status(502).json({
        success: false,

        message:
          "The configured Gemini model is not available.",

        error:
          errorMessage,
      });
    }

    // ======================================================
    // QUOTA ERROR
    // ======================================================

    if (
      errorMessage
        .toLowerCase()
        .includes("quota") ||
      errorMessage.includes(
        "RESOURCE_EXHAUSTED"
      )
    ) {
      return res.status(502).json({
        success: false,

        message:
          "Gemini API quota has been exceeded. Please check your Gemini API account.",

        error:
          errorMessage,
      });
    }

    // ======================================================
    // TIMEOUT
    // ======================================================

    if (
      errorMessage
        .toLowerCase()
        .includes("timed out")
    ) {
      return res.status(504).json({
        success: false,

        message:
          "Gemini AI took too long to respond. Please try again.",

        error:
          errorMessage,
      });
    }

    // ======================================================
    // GENERAL ERROR
    // ======================================================

    return res.status(500).json({
      success: false,

      message:
        "Failed to generate crop recommendation",

      error:
        errorMessage,
    });
  }
};

// ==========================================================
// EXPORT
// ==========================================================

module.exports = {
  getCropRecommendation,
};