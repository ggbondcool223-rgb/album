import 'package:album_app/pages/album_albums/album_albums_logic.dart';
import 'package:album_app/pages/album_settings/album_settings_logic.dart';
import 'package:album_app/pages/album_templates/album_templates_logic.dart';
import 'package:get/get.dart';
import 'album_tab_logic.dart';

class AlbumTabBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AlbumTabLogic());
    Get.lazyPut(() => AlbumTemplatesLogic());
    Get.lazyPut(() => AlbumAlbumsLogic());
    Get.lazyPut(() => AlbumSettingsLogic());
  }
}

