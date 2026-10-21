const https = require("https");

// ==========================================================
// GEMINI CONFIGURATION
// ==========================================================

const GEMINI_API_KEY = process.env.GEMINI_API_KEY;

// Fast model for chatbot
const GEMINI_MODEL = "gemini-3.5-flash-lite";

// Fallback model
const GEMINI_FALLBACK_MODEL = "gemini-3.6-flash";

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

      generationConfig: {
        maxOutputTokens: 500,
      },
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
              // RATE LIMIT / QUOTA
              // ==================================================

              if (
                response.statusCode === 429
              ) {
                console.warn(
                  "⚠️ Gemini 429 rate limit/quota"
                );

                // Retry only temporary rate limits.
                if (attempt < 2) {
                  const retryDelay =
                    1500 *
                    Math.pow(
                      2,
                      attempt
                    );

                  console.log(
                    `🔄 Retrying Gemini in ${retryDelay}ms...`
                  );

                  await wait(
                    retryDelay
                  );

                  try {
                    const retryResult =
                      await callGemini(
                        prompt,
                        model,
                        attempt + 1
                      );

                    return resolve(
                      retryResult
                    );
                  } catch (
                    retryError
                  ) {
                    return reject(
                      retryError
                    );
                  }
                }

                // ==================================================
                // FALLBACK MODEL
                // ==================================================

                if (
                  model ===
                  GEMINI_MODEL
                ) {
                  console.log(
                    "🔄 Trying fallback Gemini model..."
                  );

                  try {
                    const fallbackResult =
                      await callGemini(
                        prompt,
                        GEMINI_FALLBACK_MODEL,
                        0
                      );

                    return resolve(
                      fallbackResult
                    );
                  } catch (
                    fallbackError
                  ) {
                    return reject(
                      fallbackError
                    );
                  }
                }

                const quotaError =
                  new Error(
                    "GEMINI_QUOTA_EXCEEDED"
                  );

                quotaError.code =
                  "GEMINI_QUOTA_EXCEEDED";

                return reject(
                  quotaError
                );
              }

              // ==================================================
              // SERVICE UNAVAILABLE
              // ==================================================

              if (
                response.statusCode ===
                503
              ) {
                if (attempt < 2) {
                  const retryDelay =
                    2000 *
                    (attempt + 1);

                  console.log(
                    `🔄 Gemini temporarily unavailable. Retrying in ${retryDelay}ms...`
                  );

                  await wait(
                    retryDelay
                  );

                  try {
                    const retryResult =
                      await callGemini(
                        prompt,
                        model,
                        attempt + 1
                      );

                    return resolve(
                      retryResult
                    );
                  } catch (
                    retryError
                  ) {
                    return reject(
                      retryError
                    );
                  }
                }

                const serviceError =
                  new Error(
                    "GEMINI_SERVICE_UNAVAILABLE"
                  );

                serviceError.code =
                  "GEMINI_SERVICE_UNAVAILABLE";

                return reject(
                  serviceError
                );
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
      30000,
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
      // AGRII AI PROMPT
      // ======================================================

      const prompt = `
You are Agrii AI, an agriculture assistant for farmers.

Your ONLY job is to answer agriculture and farming questions.

AGRICULTURE TOPICS INCLUDE:
farming, crops, seeds, sowing, soil, fertilizer,
manure, irrigation, water management, pests,
plant diseases, weeds, crop rotation, harvesting,
farm machinery, agricultural technology,
farm management, agricultural markets,
crop yield and general farming profitability.

IMPORTANT:

1. First determine whether the farmer's question
is related to agriculture.

2. If the question IS agriculture-related:
answer it helpfully and practically.

3. If the question is NOT agriculture-related:
DO NOT answer that question.

Instead reply only with a short message asking
the farmer to ask an Agrii related agriculture question.

4. Automatically detect the language of the farmer.

5. ALWAYS answer in the SAME LANGUAGE used by
the farmer.

Tamil question -> Tamil answer.
Hindi question -> Hindi answer.
English question -> English answer.
Telugu question -> Telugu answer.
Kannada question -> Kannada answer.
Malayalam question -> Malayalam answer.
Other languages -> use the same language when possible.

6. Do not translate the farmer's question into
English before answering.

7. Use simple farmer-friendly language.

8. Do not guarantee crop yield or profit.

9. Do not invent exact market prices.

10. If advice depends on soil testing, location,
weather, rainfall, crop variety or local conditions,
clearly mention that it may vary.

11. Return ONLY normal plain text.

12. DO NOT use:
asterisks
markdown
hashtags
backticks
special formatting
tables
bold text
headings using symbols

13. Keep the answer concise and useful.

FARMER QUESTION:

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