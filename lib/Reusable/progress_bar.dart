import 'package:flutter/material.dart';

class StepProgressBar extends StatelessWidget {
  final double progress; // 0.0 → 1.0

  const StepProgressBar({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 20,
        width: double.infinity,
        color: Colors.grey.shade900,
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: progress, // ✅ fill as progress
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple, Colors.black],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
