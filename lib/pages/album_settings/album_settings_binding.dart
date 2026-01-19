import 'package:get/get.dart';
import 'album_settings_logic.dart';

class AlbumSettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AlbumSettingsLogic());
  }
}

