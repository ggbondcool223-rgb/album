import 'package:album_app/pages/album_albums/album_albums_logic.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../main.dart';
import '../album_albums/album_albums_view.dart';
import '../album_settings/album_settings_view.dart';
import '../album_templates/album_templates_view.dart';
import 'album_tab_logic.dart';


class AlbumTabView extends GetView<AlbumTabLogic> {
  const AlbumTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: controller.pageController,
        children: [
          AlbumTemplatesView(),
          AlbumAlbumsView(),
          AlbumSettingsView(),
        ],
      ),
      bottomNavigationBar: Obx(()=>_navAlbumBars()),
    );
  }

  Widget _navAlbumBars() {
    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.grid_view_rounded, size: 22,color: Colors.grey,),
          activeIcon:Icon(Icons.grid_view_rounded, size: 22,color: Colors.blue),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.album_rounded, size: 22,color: Colors.grey,),
          activeIcon:Icon(Icons.album_rounded, size: 22,color: Colors.blue),
          label: 'Albums',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_rounded, size: 22,color: Colors.grey,),
          activeIcon:Icon(Icons.settings_rounded, size: 22,color: Colors.blue),
          label: 'Settings',
        ),

      ],
      currentIndex: controller.currentIndex.value,
      onTap: (index) {
        controller.currentIndex.value = index;
        controller.pageController.jumpToPage(index);
        if(index == 1){
          AlbumAlbumsLogic albumLogic = Get.find<AlbumAlbumsLogic>();
          albumLogic.loadAlbums();
        }
      },
    );
  }
}

