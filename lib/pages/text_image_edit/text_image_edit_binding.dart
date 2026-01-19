import 'package:get/get.dart';
import 'text_image_edit_logic.dart';

class TextImageEditBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => TextImageEditLogic());
  }
}

