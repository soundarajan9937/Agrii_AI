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
                    Text(
                      recommendationResult!,
                      style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),
          ],
        ),
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
