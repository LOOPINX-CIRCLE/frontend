// ignore_for_file: camel_case_types

import 'package:get/get.dart';
import 'package:flutter/material.dart';

class FormController extends GetxController {
  // Dropdown value
  var selectedOption = "".obs;

  // TextField value
  var enteredText = "".obs;

  // Reset method
  void resetForm() {
    selectedOption.value = "";
    enteredText.value = "";
  }
}

class FirstPage extends StatelessWidget {
  final FormController controller = Get.put(FormController());

  FirstPage({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController textController = TextEditingController(
      text: controller.enteredText.value,
    );

    return Scaffold(
      appBar: AppBar(title: const Text("First Page")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Dropdown
            Obx(
              () => DropdownButton<String>(
                value: controller.selectedOption.value.isEmpty
                    ? null
                    : controller.selectedOption.value,
                hint: const Text("Select Option"),
                items: ["Option 1", "Option 2", "Option 3"]
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) {
                  controller.selectedOption.value = val ?? "";
                },
              ),
            ),

            const SizedBox(height: 20),

            // TextField
            TextField(
              controller: textController,
              decoration: const InputDecoration(labelText: "Enter Text"),
              onChanged: (val) {
                controller.enteredText.value = val;
              },
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                Get.to(() => SecondPage());
              },
              child: const Text("Next Page"),
            ),
          ],
        ),
      ),
    );
  }
}

class SecondPage extends StatelessWidget {
  final FormController controller = Get.find();

  SecondPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Second Page")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Obx(() => Text("Selected: ${controller.selectedOption.value}")),
            Obx(() => Text("Entered: ${controller.enteredText.value}")),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                controller.resetForm(); // ✅ reset fields
                Get.off(
                  () => thrid(),
                ); // ✅ back to first page (replace navigation)
              },
              child: const Text("Back & Reset"),
            ),
          ],
        ),
      ),
    );
  }
}

class thrid extends StatelessWidget {
  const thrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text("njdjdfka"),
          ElevatedButton(
            onPressed: () {
              Get.off(
                () => FirstPage(),
              ); // ✅ back to first page (replace navigation)
            },
            child: const Text("Back & Reset"),
          ),
        ],
      ),
    );
  }
}
