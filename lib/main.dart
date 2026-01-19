import 'package:album_app/pages/album_settings/album_setting_save.dart';
import 'package:album_app/pages/album_system/album_system_binding.dart';
import 'package:album_app/pages/album_system/album_system_view.dart';
import 'package:album_app/services/tag_suggestion_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'db_album/data.dart';
import '../pages/album_tab/album_tab_binding.dart';
import '../pages/album_tab/album_tab_view.dart';
import '../pages/album_templates/album_templates_binding.dart';
import '../pages/album_templates/album_templates_view.dart';
import '../pages/template_list/template_list_binding.dart';
import '../pages/template_list/template_list_view.dart';
import '../pages/album_albums/album_albums_binding.dart';
import '../pages/album_albums/album_albums_view.dart';
import '../pages/album_settings/album_settings_binding.dart';
import '../pages/album_settings/album_settings_view.dart';
import '../pages/music_edit/music_edit_binding.dart';
import '../pages/music_edit/music_edit_view.dart';
import '../pages/text_image_edit/text_image_edit_binding.dart';
import '../pages/text_image_edit/text_image_edit_view.dart';
import '../pages/video_edit/video_edit_binding.dart';
import '../pages/video_edit/video_edit_view.dart';

const primaryColor = Color(0xFF0B0B1E);
const accentColor = Color(0xFF00D4FF);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  Get.put(AlbumDB());
  Get.put(TagSuggestionService());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) {
        return GetMaterialApp(
          title: 'Album App',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            primaryColor: primaryColor,
            scaffoldBackgroundColor: primaryColor,
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.transparent,
                elevation: 0,
                scrolledUnderElevation: 0,
                foregroundColor: Colors.white,
                centerTitle: true,
                titleTextStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
              bottomNavigationBarTheme: BottomNavigationBarThemeData(
                unselectedItemColor: Colors.grey,
                unselectedLabelStyle: const TextStyle(fontSize: 12),
                selectedItemColor: Colors.blue,
                selectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue
                ),
                elevation: 0,
                backgroundColor: Colors.black.withAlpha(200),
              )
          ),
          initialRoute: '/',
          getPages: Art,
        );
      },
    );
  }
}

List<GetPage<dynamic>> Art = [
  GetPage(
    name: '/',
    page: () => const AlbumSystemView(),
    binding: AlbumSystemBinding(),
    transition: Transition.cupertino,
    popGesture: true,
    preventDuplicates: false,
  ),
  GetPage(
    name: '/album_tab',
    page: () => const AlbumTabView(),
    binding: AlbumTabBinding(),
    transition: Transition.cupertino,
    popGesture: true,
    preventDuplicates: false,
  ),
  GetPage(
    name: '/album_templates',
    page: () => const AlbumTemplatesView(),
    binding: AlbumTemplatesBinding(),
    transition: Transition.cupertino,
    popGesture: true,
    preventDuplicates: false,
  ),
  GetPage(
    name: '/template_list/:type',
    page: () => const TemplateListView(),
    binding: TemplateListBinding(),
    transition: Transition.cupertino,
    popGesture: true,
    preventDuplicates: false,
  ),
  GetPage(
    name: '/album_albums',
    page: () => const AlbumAlbumsView(),
    binding: AlbumAlbumsBinding(),
    transition: Transition.cupertino,
    popGesture: true,
    preventDuplicates: false,
  ),
  GetPage(
    name: '/album_settings_save',
    page: () => const AlbumSettingSave(),
    transition: Transition.cupertino,
    popGesture: true,
    preventDuplicates: false,
  ),
  GetPage(
    name: '/album_settings',
    page: () => const AlbumSettingsView(),
    binding: AlbumSettingsBinding(),
    transition: Transition.cupertino,
    popGesture: true,
    preventDuplicates: false,
  ),
  GetPage(
    name: '/music_edit',
    page: () => const MusicEditView(),
    binding: MusicEditBinding(),
    transition: Transition.cupertino,
    popGesture: true,
    preventDuplicates: false,
  ),
  GetPage(
    name: '/text_image_edit',
    page: () => const TextImageEditView(),
    binding: TextImageEditBinding(),
    transition: Transition.cupertino,
    popGesture: true,
    preventDuplicates: false,
  ),
  GetPage(
    name: '/video_edit',
    page: () => const VideoEditView(),
    binding: VideoEditBinding(),
    transition: Transition.cupertino,
    popGesture: true,
    preventDuplicates: false,
  ),
];