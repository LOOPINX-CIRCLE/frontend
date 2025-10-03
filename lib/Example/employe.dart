import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MultiStepController extends GetxController {
  var currentStep = 0.obs; // step tracker

  void nextStep() {
    if (currentStep.value < 6) {
      currentStep.value++;
    }
  }

  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }

  double get progress => (currentStep.value) / 6; // 6 total pages
}

class MultiStepForm extends StatelessWidget {
  final MultiStepController controller = Get.put(MultiStepController());

  MultiStepForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: LinearProgressIndicator(
                value: controller.progress,
                backgroundColor: Colors.grey[800],
                color: Colors.purpleAccent,
                minHeight: 6,
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            // Title
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Set the mood,\nWhat are we hosting?",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Options (party, music etc.)
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                padding: const EdgeInsets.all(12),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children:
                    [
                          "PARTY",
                          "HOUSE PARTY",
                          "MUSIC",
                          "PICNIC",
                          "OUTDOOR ACTIVITIES",
                          "LIQUOR TASTING",
                          "BRUNCH",
                          "GAMES",
                          "FOOD WALK",
                          "DANCE",
                          "COMEDY CLUB",
                          "ART & CRAFT",
                          "WEEKEND GETAWAY",
                          "TRAVEL",
                          "DINNER",
                          "LUNCH",
                          "COOK FEST",
                        ]
                        .map(
                          (e) => ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[700],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              controller
                                  .nextStep(); // progress bar aage badhega
                            },
                            child: Text(
                              e,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        )
                        .toList(),
              ),
            ),

            // Next & Previous button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (controller.currentStep.value > 0)
                    ElevatedButton(
                      onPressed: controller.previousStep,
                      child: const Text("Back"),
                    ),
                  ElevatedButton(
                    onPressed: controller.nextStep,
                    child: Text(
                      controller.currentStep.value == 5 ? "Finish" : "Next",
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
