import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:text_code/Home_pages/UI_Design/home_page.dart';
import 'package:text_code/Reusable/customer_appbar.dart';
import 'package:text_code/Reusable/text_Bricolage%20Grotesque_reusable.dart';
import 'package:text_code/Reusable/text_reusable.dart';

class Failed extends StatelessWidget {
  const Failed({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: CustomAppBar(
        leadingIcon: Padding(
          padding: const EdgeInsets.only(left: 20), // 👈 left se gap
          child: Image.asset(
            "assets/icons/Back Icon.png",
            height: 60,
            // width: 40,
          ),
        ),
        titleWidget: FormLabel("Payment failed", fontSize: 22),
      ),
      // appBar: AppBar(
      //   backgroundColor: Colors.black,
      //   title: Row(
      //     // mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //     children: [
      //       Image.asset("assets/icons/Back Icon.png", height: 40),
      //       SizedBox(width: 100),
      //       FormLabel("Payment failed", fontSize: 22),
      //     ],
      //   ),
      // ),
      body: Column(
        // mainAxisAlignment: MainAxisAlignment.center,
        // crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 100),
          Image.asset("assets/icons/iconpaym.png", height: 200, width: 200),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Expanded(
              child: Center(
                child: TextBricolage(
                  FontWeight.w500,
                  "Payment Could Not Be Completed",
                  26,
                  textAlign: TextAlign.center, // 👈 text ko beech me karega
                ),
              ),
            ),
          ),
          SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black, // 🔹 Button background
              foregroundColor: Colors.white, // 🔹 Text/Icon color
              side: const BorderSide(
                color: Colors.grey,
                width: 1,
              ), // 🔹 Border color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  8,
                ), // optional: rounded corners
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              child: TextBricolage(FontWeight.w500, "Try Again", 18),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.to(() => HomePages()); // 🔹 Example: HomePage par navigate
            },
            child: FormLabel("Go Back", fontSize: 16),
          ),
        ],
      ),
    );
  }
}
