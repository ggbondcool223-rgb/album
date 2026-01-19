import 'package:get/get.dart';

import 'album_system_logic.dart';

class AlbumSystemBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(
      AlbumSystemLogic(),
      permanent: true,
    );
  }
}
