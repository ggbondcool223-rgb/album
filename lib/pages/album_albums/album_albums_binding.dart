import 'package:get/get.dart';
import 'album_albums_logic.dart';

class AlbumAlbumsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AlbumAlbumsLogic());
  }
}

