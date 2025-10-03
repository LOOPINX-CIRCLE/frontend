import 'package:get/get.dart';

class ChoosingThemeController extends GetxController {
  // Observable set to track selected tags
  var selectedTags = <String>[].obs;
  var selectedTag = "".obs;
  var selectedIndex = (-1).obs;
  final List<String> tags = [
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
  ];

  // Toggle tag selection
  void toggleTag(String tag) {
    if (selectedTags.contains(tag)) {
      selectedTags.remove(tag);
    } else {
      selectedTags.add(tag);
    }
  }

  RxBool isActive = false.obs;

  bool isSelecteds(int index) => selectedIndex.value == index;

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

  double get progress => (currentStep.value) / 6;

  bool isSelected(String tag) => selectedTags.contains(tag);
  void resetSelection() {
    selectedTag.value = "";
    selectedIndex.value = -1;
    isActive.value = false;
    selectedTags.clear();
  }
}
