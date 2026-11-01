const https = require("https");

// ==========================================================
// GEMINI CONFIGURATION
// ==========================================================

const GEMINI_API_KEY = process.env.GEMINI_API_KEY;

// Fast primary model for chatbot
const GEMINI_MODEL = "gemini-3.5-flash";

// Fallback model
const GEMINI_FALLBACK_MODEL = "gemini-3.5-flash-lite";

// ==========================================================
// WAIT HELPER
// ==========================================================

const wait = (milliseconds) => {
  return new Promise((resolve) => {
    setTimeout(resolve, milliseconds);
  });
};

// ==========================================================
// CALL GEMINI
// ==========================================================

const callGemini = (
  prompt,
  model = GEMINI_MODEL,
  attempt = 0
) => {
  return new Promise((resolve, reject) => {
    if (!GEMINI_API_KEY) {
      return reject(
        new Error(
          "GEMINI_API_KEY is missing from backend .env file"
        )
      );
    }

    const generationConfig = {
      maxOutputTokens: 350,
      temperature: 0.4,
    };

    // Disable thinking budget on gemini-3.5-flash for immediate (< 2s) response
    if (model === GEMINI_MODEL) {
      generationConfig.thinkingConfig = { thinkingBudget: 0 };
    }

    const requestBody = JSON.stringify({
      contents: [
        {
          role: "user",
          parts: [
            {
              text: prompt,
            },
          ],
        },
      ],
      generationConfig,
    });

    const options = {
      hostname:
        "generativelanguage.googleapis.com",

      path:
        `/v1beta/models/${model}:generateContent?key=${GEMINI_API_KEY}`,

      method: "POST",

      headers: {
        "Content-Type":
          "application/json",

        "Content-Length":
          Buffer.byteLength(requestBody),
      },
    };

    const request = https.request(
      options,
      (response) => {
        let data = "";

        response.on(
          "data",
          (chunk) => {
            data += chunk;
          }
        );

        response.on(
          "end",
          async () => {
            try {
              const parsed =
                JSON.parse(data);

              console.log(
                `🌾 Gemini Model: ${model}`
              );

              console.log(
                `🌾 Gemini Status: ${response.statusCode}`
              );

              // ==================================================
              // SUCCESS
              // ==================================================

              if (
                response.statusCode >= 200 &&
                response.statusCode < 300
              ) {
                return resolve(parsed);
              }

              const errorMessage =
                String(
                  parsed?.error?.message ||
                    ""
                );

              const errorStatus =
                String(
                  parsed?.error?.status ||
                    ""
                );

              // ==================================================
              // RATE LIMIT / QUOTA / BUSY (429 or 503)
              // ==================================================

              if (
                response.statusCode === 429 ||
                response.statusCode === 503
              ) {
                console.warn(
                  `⚠️ Gemini ${response.statusCode} on ${model}`
                );

                // If primary model failed, immediately try fallback without delay
                if (model === GEMINI_MODEL) {
                  console.log(
                    "🔄 Instantly trying fallback model: " + GEMINI_FALLBACK_MODEL
                  );
                  try {
                    const fallbackResult = await callGemini(
                      prompt,
                      GEMINI_FALLBACK_MODEL,
                      0
                    );
                    return resolve(fallbackResult);
                  } catch (fallbackError) {
                    return reject(fallbackError);
                  }
                }

                if (attempt < 1) {
                  await wait(500);
                  try {
                    const retryResult = await callGemini(
                      prompt,
                      model,
                      attempt + 1
                    );
                    return resolve(retryResult);
                  } catch (retryError) {
                    return reject(retryError);
                  }
                }

                const quotaError =
                  new Error(
                    "GEMINI_SERVICE_UNAVAILABLE"
                  );
                quotaError.code =
                  "GEMINI_SERVICE_UNAVAILABLE";

                return reject(quotaError);
              }

              // ==================================================
              // MODEL NOT FOUND
              // ==================================================

              if (
                response.statusCode ===
                  404 ||
                errorStatus ===
                  "NOT_FOUND"
              ) {
                const modelError =
                  new Error(
                    "GEMINI_MODEL_NOT_FOUND"
                  );

                modelError.code =
                  "GEMINI_MODEL_NOT_FOUND";

                return reject(
                  modelError
                );
              }

              // ==================================================
              // API KEY
              // ==================================================

              if (
                response.statusCode ===
                  401 ||
                response.statusCode ===
                  403
              ) {
                const keyError =
                  new Error(
                    "GEMINI_API_KEY_INVALID"
                  );

                keyError.code =
                  "GEMINI_API_KEY_INVALID";

                return reject(
                  keyError
                );
              }

              // ==================================================
              // OTHER GEMINI ERROR
              // ==================================================

              console.error(
                "❌ Gemini Error:",
                errorMessage
              );

              const apiError =
                new Error(
                  errorMessage ||
                    "Gemini API error"
                );

              apiError.code =
                "GEMINI_API_ERROR";

              return reject(
                apiError
              );
            } catch (error) {
              console.error(
                "❌ Invalid Gemini response"
              );

              return reject(
                new Error(
                  "Invalid response received from Gemini API"
                )
              );
            }
          }
        );
      }
    );

    request.setTimeout(
      15000,
      () => {
        request.destroy(
          new Error(
            "Gemini request timeout"
          )
        );
      }
    );

    request.on(
      "error",
      (error) => {
        reject(error);
      }
    );

    request.write(
      requestBody
    );

    request.end();
  });
};

// ==========================================================
// CLEAN AI TEXT
// ==========================================================

const cleanAiText = (text) => {
  let result = String(
    text || ""
  );

  // Remove markdown
  result = result.replace(
    /```[\s\S]*?```/g,
    ""
  );

  result = result.replace(
    /\*\*\*/g,
    ""
  );

  result = result.replace(
    /\*\*/g,
    ""
  );

  result = result.replace(
    /^#{1,6}\s*/gm,
    ""
  );

  result = result.replace(
    /^[-*_]{3,}\s*$/gm,
    ""
  );

  result = result.replace(
    /`/g,
    ""
  );

  // Remove excessive blank lines
  result = result.replace(
    /\n{3,}/g,
    "\n\n"
  );

  return result.trim();
};

// ==========================================================
// CHATBOT
//
// POST /api/chatbot/message
// ==========================================================

const sendChatbotMessage =
  async (req, res) => {
    try {
      console.log(
        "======================================"
      );

      console.log(
        "🌾 AGRII AI CHATBOT REQUEST"
      );

      console.log(
        "======================================"
      );

      // ======================================================
      // VALIDATION
      // ======================================================

      const {
        message,
      } = req.body || {};

      if (
        typeof message !==
          "string" ||
        message.trim().length === 0
      ) {
        return res.status(400).json({
          success: false,
          message:
            "Please ask an Agrii related question.",
        });
      }

      const userMessage =
        message.trim();

      // Limit extremely large requests
      if (
        userMessage.length >
        2000
      ) {
        return res.status(400).json({
          success: false,
          message:
            "Please keep your question shorter.",
        });
      }

      console.log(
        "👨‍🌾 Farmer:",
        userMessage
      );

      // ======================================================
      // AGRII AI PROMPT (STRICT AGRICULTURE-ONLY DOMAIN)
      // ======================================================

      const prompt = `
You are Agrii AI, an intelligent multilingual agricultural AI assistant built specifically and exclusively for agriculture, farming, crops, and farmers.

STRICT DOMAIN RULE - ONLY AGRICULTURE QUESTIONS:
1. You are permitted to answer ONLY questions related to agriculture, farming, horticulture, and farm produce:
   - Crops, grains, vegetables, fruits (types, farming, soil needs, harvest, seasonal care, nutritional/health benefits of farm produce)
   - Soil health, preparation, pH, testing
   - Fertilizers, manures, bio-fertilizers, organic farming, compost, NPK
   - Plant diseases, pest control, insecticides, fungicides, weed management
   - Irrigation systems (drip, sprinkler), water conservation for crops
   - Farm tools, machinery, modern agricultural technology
   - Livestock, dairy farming, cattle, poultry, goat farming
   - Crop storage, mandi/market produce handling, Agrii marketplace app services
2. Greetings & Identity:
   - If the user says a greeting (e.g. "hi", "hello", "வணக்கம்", "नमस्ते", "ನಮಸ್ಕಾರ") or asks "who are you", introduce yourself as Agrii AI, your farming assistant, and invite them to ask their agriculture or farming question.
3. Off-Topic & Non-Agriculture Questions (STRICT REFUSAL):
   - If the user asks ANY question that is NOT related to agriculture or farming (such as movies, cinema, celebrities, sports, cricket, politics, computer coding, general school homework, games, vehicles unrelated to farming, or general gossip):
   - You MUST STRICTLY REFUSE to answer the off-topic question.
   - Inform the user that you are Agrii AI and only answer agriculture and farming questions, and politely invite them to ask an agricultural question.
   - DO NOT answer the non-agri question even partially.

STRICT MULTILINGUAL MATCHING:
1. Automatically detect the exact language of the user's message.
2. ALWAYS respond ONLY in the user's exact language (both for agricultural answers and for refusals):
   - If user asks in English -> Respond 100% in English. (NEVER switch to Kannada, Tamil, or Hindi).
     Example refusal in English: "I am Agrii AI, your agriculture assistant. I can only assist with agriculture, crops, and farming-related questions. Please ask a farming question."
   - If user asks in Tamil (தமிழ்) -> Respond 100% in Tamil.
     Example refusal in Tamil: "நான் அக்ரி AI, உங்கள் விவசாய உதவியாளர். என்னால் விவசாயம் மற்றும் பயிர் தொடர்பான கேள்விகளுக்கு மட்டுமே பதிலளிக்க முடியும். தயவுசெய்து விவசாயம் சார்ந்த கேள்விகளைக் கேளுங்கள்."
   - If user asks in Kannada (ಕನ್ನಡ) -> Respond 100% in Kannada.
     Example refusal in Kannada: "ನಾನು ಅಗ್ರಿ AI, ನಿಮ್ಮ ಕೃಷಿ ಸಹಾಯಕ. ನಾನು ಕೃಷಿ, ಬೆಳೆಗಳು ಮತ್ತು ತೋಟಗಾರಿಕೆಗೆ ಸಂಬಂಧಿಸಿದ ಪ್ರಶ್ನೆಗಳಿಗೆ ಮಾತ್ರ ಉತ್ತರಿಸಬಲ್ಲೆ. ದಯವಿಟ್ಟು ಕೃಷಿ ಸಂಬಂಧಿತ ಪ್ರಶ್ನೆಯನ್ನು ಕೇಳಿ."
   - If user asks in Hindi (हिन्दी) -> Respond 100% in Hindi.
     Example refusal in Hindi: "मैं अग्री एआई (Agrii AI) हूँ, आपका कृषि सहायक। मैं केवल कृषि, फसलों और खेती से संबंधित प्रश्नों के उत्तर दे सकता हूँ। कृपया खेती से संबंधित प्रश्न पूछें।"
   - If user asks in Telugu (తెలుగు) -> Respond 100% in Telugu.
   - If user asks in Malayalam (മലയാളം) -> Respond 100% in Malayalam.
   - If user writes in transliterated script (e.g. Tanglish/Hinglish), reply in the same natural conversational style.

RESPONSE STYLE:
- Fast, direct, concise (2 to 5 sentences or short bullet points).
- Plain text only. NO markdown bold symbols (**), NO headings (#), NO backticks (\`).

USER MESSAGE:
${userMessage}
`;

      // ======================================================
      // CALL GEMINI
      // ======================================================

      console.log(
        "🌾 Sending request to Gemini..."
      );

      const result =
        await callGemini(
          prompt
        );

      // ======================================================
      // EXTRACT RESPONSE
      // ======================================================

      const candidates =
        result?.candidates;

      if (
        !Array.isArray(
          candidates
        ) ||
        candidates.length === 0
      ) {
        console.error(
          "❌ Gemini returned no candidates"
        );

        return res.status(502).json({
          success: false,
          message:
            "Agrii AI could not generate a response.",
        });
      }

      const parts =
        candidates[0]
          ?.content
          ?.parts;

      if (
        !Array.isArray(parts) ||
        parts.length === 0
      ) {
        return res.status(502).json({
          success: false,
          message:
            "Agrii AI returned an empty response.",
        });
      }

      let reply =
        parts
          .map(
            (part) =>
              part?.text || ""
          )
          .join("\n")
          .trim();

      reply =
        cleanAiText(
          reply
        );

      if (!reply) {
        return res.status(502).json({
          success: false,
          message:
            "Agrii AI could not generate a response.",
        });
      }

      // ======================================================
      // SUCCESS
      // ======================================================

      console.log(
        "✅ Agrii AI response generated"
      );

      return res.status(200).json({
        success: true,
        message:
          "Agrii AI response generated successfully.",
        reply: reply,
      });
    } catch (error) {
      console.error(
        "======================================"
      );

      console.error(
        "❌ AGRII AI CHATBOT ERROR"
      );

      console.error(
        error
      );

      console.error(
        "======================================"
      );

      // ======================================================
      // QUOTA
      // ======================================================

      if (
        error.code ===
        "GEMINI_QUOTA_EXCEEDED"
      ) {
        return res.status(429).json({
          success: false,
          code:
            "GEMINI_QUOTA_EXCEEDED",
          message:
            "Agrii AI request limit has been reached. Please try again later.",
        });
      }

      // ======================================================
      // SERVICE UNAVAILABLE
      // ======================================================

      if (
        error.code ===
        "GEMINI_SERVICE_UNAVAILABLE"
      ) {
        return res.status(503).json({
          success: false,
          code:
            "GEMINI_SERVICE_UNAVAILABLE",
          message:
            "Agrii AI is temporarily busy. Please try again.",
        });
      }

      // ======================================================
      // MODEL NOT FOUND
      // ======================================================

      if (
        error.code ===
        "GEMINI_MODEL_NOT_FOUND"
      ) {
        return res.status(502).json({
          success: false,
          code:
            "GEMINI_MODEL_NOT_FOUND",
          message:
            "Agrii AI service is temporarily unavailable. Please try again later.",
        });
      }

      // ======================================================
      // API KEY
      // ======================================================

      if (
        error.code ===
        "GEMINI_API_KEY_INVALID"
      ) {
        return res.status(500).json({
          success: false,
          code:
            "GEMINI_API_KEY_INVALID",
          message:
            "Agrii AI configuration is unavailable.",
        });
      }

      // ======================================================
      // TIMEOUT
      // ======================================================

      if (
        String(
          error.message || ""
        ).toLowerCase().includes(
          "timeout"
        )
      ) {
        return res.status(504).json({
          success: false,
          code:
            "GEMINI_TIMEOUT",
          message:
            "Agrii AI took too long to respond. Please try again.",
        });
      }

      // ======================================================
      // GENERAL ERROR
      // ======================================================

      return res.status(500).json({
        success: false,
        code:
          "CHATBOT_ERROR",
        message:
          "Agrii AI is temporarily unavailable. Please try again.",
      });
    }
  };

// ==========================================================
// EXPORT
// ==========================================================

module.exports = {
  sendChatbotMessage,
};