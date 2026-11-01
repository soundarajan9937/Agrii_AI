import 'package:flutter/material.dart';
import '../../services/crop_service.dart';

class CropAdvisorScreen extends StatefulWidget {
  const CropAdvisorScreen({super.key});

  @override
  State<CropAdvisorScreen> createState() => _CropAdvisorScreenState();
}

class _CropAdvisorScreenState extends State<CropAdvisorScreen> {
  String? selectedSoil;
  String? selectedSeason;
  String? selectedDuration;

  final TextEditingController areaController = TextEditingController();
  final TextEditingController previousCropController = TextEditingController();

  bool isLoading = false;
  String? recommendationResult;

  final List<String> soilList = [
    "Alluvial Soil",
    "Red Soil",
    "Black Soil",
    "Laterite Soil",
    "Arid / Sandy Soil",
    "Mountain Soil",
    "Peaty / Marshy Soil",
  ];

  final List<String> seasonList = [
    "Kharif (June - October)",
    "Rabi (November - March)",
    "Zaid (March - June)",
    "Summer",
    "Winter",
    "Monsoon",
    "All Seasons",
  ];

  final List<String> durationList = [
    "Short Term (30-60 Days)",
    "Mid Term (60-90 Days)",
    "Long Term (90-120 Days)",
    "Extended (120+ Days)",
  ];

  @override
  void dispose() {
    areaController.dispose();
    previousCropController.dispose();
    super.dispose();
  }

  Future<void> getRecommendation() async {
    if (selectedSoil == null ||
        selectedSeason == null ||
        selectedDuration == null ||
        areaController.text.trim().isEmpty ||
        previousCropController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all the fields"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
      recommendationResult = null;
    });

    try {
      final result = await CropService.getAIRecommendation(
        soil: selectedSoil!,
        season: selectedSeason!,
        duration: selectedDuration!,
        area: areaController.text.trim(),
        previousCrop: previousCropController.text.trim(),
      );

      setState(() {
        recommendationResult = result;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to get recommendation. Please check your internet."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF7F2), // Farmer theme background
      appBar: AppBar(
        title: const Text("Crop Advisor", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Icon(Icons.eco, size: 60, color: Colors.orange),
            ),
            const SizedBox(height: 10),
            const Center(
              child: Text(
                "Smart Crop Advisor",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                "Enter your land details to get the best crop recommendations from Agrii AI",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 30),

            _buildLabel("Select Season"),
            _buildDropdown(
              value: selectedSeason,
              items: seasonList,
              hint: "Choose Season",
              onChanged: (val) => setState(() => selectedSeason = val),
            ),

            const SizedBox(height: 18),

            _buildLabel("Select Soil Type"),
            _buildDropdown(
              value: selectedSoil,
              items: soilList,
              hint: "Choose Soil Type",
              onChanged: (val) => setState(() => selectedSoil = val),
            ),

            const SizedBox(height: 18),

            _buildLabel("Cultivation Duration"),
            _buildDropdown(
              value: selectedDuration,
              items: durationList,
              hint: "Choose Duration",
              onChanged: (val) => setState(() => selectedDuration = val),
            ),

            const SizedBox(height: 18),

            _buildLabel("Land Area"),
            _buildTextField(areaController, "e.g. 2 Acres or 50 Cents"),

            const SizedBox(height: 18),

            _buildLabel("Previous Crop"),
            _buildTextField(previousCropController, "e.g. Paddy or None"),

            const SizedBox(height: 35),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : getRecommendation,
                icon: const Icon(Icons.analytics_outlined),
                label: const Text(
                  "Get AI Recommendation",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            if (isLoading)
              const Center(child: CircularProgressIndicator(color: Colors.orange)),

            if (recommendationResult != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.auto_awesome, color: Colors.orange),
                        SizedBox(width: 10),
                        Text(
                          "AI Analysis Result",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange),
                        ),
                      ],
                    ),
                    const Divider(height: 25),
                    _buildFormattedRecommendation(recommendationResult!),
                  ],
                ),
              ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFormattedRecommendation(String raw) {
    if (!raw.contains("BEST SUITED CROP")) {
      return Text(
        raw,
        style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.black87),
      );
    }

    String extractSection(String title, List<String> nextTitles) {
      final startIndex = raw.indexOf(title);
      if (startIndex == -1) return '';
      final contentStart = startIndex + title.length;
      int endIndex = raw.length;
      for (final next in nextTitles) {
        final pos = raw.indexOf(next, contentStart);
        if (pos != -1 && pos < endIndex) {
          endIndex = pos;
        }
      }
      return raw.substring(contentStart, endIndex).trim();
    }

    final bestCrop = extractSection("BEST SUITED CROP", ["ALTERNATIVE CROP", "WHY THIS CROP"]);
    final altCrop = extractSection("ALTERNATIVE CROP", ["WHY THIS CROP", "EXPECTED YIELD"]);
    final why = extractSection("WHY THIS CROP", ["EXPECTED YIELD", "FERTILIZER SCHEDULE"]);
    final yieldVal = extractSection("EXPECTED YIELD", ["FERTILIZER SCHEDULE", "WATERING SCHEDULE"]);
    final fert = extractSection("FERTILIZER SCHEDULE", ["WATERING SCHEDULE", "HARVEST WINDOW"]);
    final water = extractSection("WATERING SCHEDULE", ["HARVEST WINDOW", "MARKET AND PROFITABILITY"]);
    final harvest = extractSection("HARVEST WINDOW", ["MARKET AND PROFITABILITY", "IMPORTANT"]);
    final market = extractSection("MARKET AND PROFITABILITY", ["IMPORTANT"]);
    final note = extractSection("IMPORTANT", []);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (bestCrop.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2E7D32).withValues(alpha: 0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.stars_rounded, color: Color(0xFFFFD54F), size: 16),
                      SizedBox(width: 6),
                      Text(
                        "TOP RECOMMENDED CROP",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  bestCrop,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (altCrop.isNotEmpty && !altCrop.toLowerCase().contains("no alternative")) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.swap_horiz, color: Color(0xFFFFD54F), size: 18),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          "Alternative: $altCrop",
                          style: const TextStyle(
                            color: Color(0xFFE8F5E9),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

        if (why.isNotEmpty)
          _buildInfoTile(
            icon: Icons.lightbulb_outline_rounded,
            iconColor: Colors.amber.shade900,
            bgColor: const Color(0xFFFFFBEB),
            title: "Why This Crop",
            content: why,
          ),

        if (yieldVal.isNotEmpty)
          _buildInfoTile(
            icon: Icons.scale_rounded,
            iconColor: Colors.teal.shade800,
            bgColor: const Color(0xFFF0FDFA),
            title: "Expected Yield",
            content: yieldVal,
          ),

        if (fert.isNotEmpty)
          _buildInfoTile(
            icon: Icons.science_outlined,
            iconColor: Colors.purple.shade800,
            bgColor: const Color(0xFFFAF5FF),
            title: "Fertilizer Schedule",
            content: fert,
          ),

        if (water.isNotEmpty)
          _buildInfoTile(
            icon: Icons.water_drop_outlined,
            iconColor: Colors.blue.shade800,
            bgColor: const Color(0xFFEFF6FF),
            title: "Watering Schedule",
            content: water,
          ),

        if (harvest.isNotEmpty)
          _buildInfoTile(
            icon: Icons.event_available_outlined,
            iconColor: Colors.orange.shade900,
            bgColor: const Color(0xFFFFF7ED),
            title: "Harvest Window",
            content: harvest,
          ),

        if (market.isNotEmpty)
          _buildInfoTile(
            icon: Icons.trending_up_rounded,
            iconColor: Colors.green.shade800,
            bgColor: const Color(0xFFF0FDF4),
            title: "Market & Profitability",
            content: market,
          ),

        if (note.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: Colors.grey.shade700, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    note,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String content,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: iconColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: iconColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 13.5,
              height: 1.45,
              color: Color(0xFF263238),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.orange, width: 2),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required String hint,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: Text(hint),
          items: items.map((String val) {
            return DropdownMenuItem<String>(
              value: val,
              child: Text(val),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
