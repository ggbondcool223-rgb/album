import 'package:get/get.dart';
import 'music_edit_logic.dart';

class MusicEditBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MusicEditLogic());
  }
}

