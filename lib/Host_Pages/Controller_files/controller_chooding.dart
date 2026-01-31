import 'package:get/get.dart';
import 'package:text_code/core/services/auth_service.dart';
import 'package:text_code/core/models/event_interest.dart';

class ChoosingThemeController extends GetxController {
  // Observable set to track selected tags
  var selectedTags = <String>[].obs;
  var selectedTag = "".obs;
  var selectedIndex = (-1).obs;
  final List<String> tags = [];

  // API event interests
  var eventInterests = <EventInterest>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchEventInterestsFromApi();
  }

  Future<void> fetchEventInterestsFromApi() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final interests = await AuthService().fetchEventInterests();
      eventInterests.assignAll(interests);
      tags.clear();
      tags.addAll(interests.map((e) => e.name));
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

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
