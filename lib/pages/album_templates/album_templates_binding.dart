import 'package:get/get.dart';
import 'album_templates_logic.dart';

class AlbumTemplatesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AlbumTemplatesLogic());
  }
}

