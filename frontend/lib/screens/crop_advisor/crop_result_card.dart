import 'package:flutter/material.dart';

class CropResultCard extends StatelessWidget {
  final String crop;
  final String yieldText;
  final String harvestTime;
  final String fertilizer;

  const CropResultCard({
    super.key,
    required this.crop,
    required this.yieldText,
    required this.harvestTime,
    required this.fertilizer,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Best Crop: $crop"),
            const SizedBox(height: 8),
            Text("Expected Yield: $yieldText"),
            const SizedBox(height: 8),
            Text("Harvest Time: $harvestTime"),
            const SizedBox(height: 8),
            Text("Fertilizer: $fertilizer"),
          ],
        ),
      ),
    );
  }
}
  