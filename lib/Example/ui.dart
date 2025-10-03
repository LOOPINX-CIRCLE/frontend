import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:text_code/Example/api.dart';

class UiScreen extends StatelessWidget {
  UiScreen({super.key});

  final PostController controller = Get.put(PostController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Employee List")),
      body: Column(
        children: [
          Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            } else if (controller.postList.isEmpty) {
              return const Center(child: Text("No employees found"));
            } else {
              return ListView.builder(
                itemCount: controller.postList.length,
                itemBuilder: (context, index) {
                  final item = controller.postList[index];
                  return ListTile(
                    leading: CircleAvatar(child: Text(item['id'].toString())),
                    title: Text(item['message'] ?? 'No Name'),
                    subtitle: Text(
                      "Age: ${item['employee_age']} | Salary: ₹${item['employee_salary']}",
                    ),
                  );
                },
              );
            }
          }),
        ],
      ),
    );
  }
}
