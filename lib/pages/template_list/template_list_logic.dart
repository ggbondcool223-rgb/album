import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import '../../db_album/data.dart';
import '../../db_album/album_entity.dart';

class TemplateListLogic extends GetxController {
  final db = Get.find<AlbumDB>();
  final templates = <TemplateEntity>[].obs;
  final isLoading = true.obs;
  final String templateType;
  final ImagePicker picker = ImagePicker();

  TemplateListLogic({required this.templateType});

  @override
  void onInit() {
    super.onInit();
    loadTemplates();
  }

  Future<void> loadTemplates() async {
    isLoading.value = true;
    try {
      final allTemplates = await db.getTemplates();
      templates.value = allTemplates.where((t) => t.type == templateType).toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load templates');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> onTemplateTap(TemplateEntity template) async {
    try {
      final List<XFile> pickedFiles = await picker.pickMultiImage();
      if (pickedFiles.isNotEmpty) {
        final imageBytesList = <Uint8List>[];
        for (var xfile in pickedFiles) {
          final bytes = await xfile.readAsBytes();
          imageBytesList.add(bytes);
        }
        if (template.type == 'music') {
          Get.offNamed('/music_edit', arguments: {
            'templateId': template.id,
            'imageBytes': imageBytesList,
          });
        } else if (template.type == 'text_image') {
          final textImages = imageBytesList.map((bytes) => {
            'imageData': bytes,
          }).toList();
          Get.offNamed('/text_image_edit', arguments: {
            'templateId': template.id,
            'textImages': textImages,
          });
        } else if (template.type == 'video') {
          final videoImages = imageBytesList.map((bytes) => {
            'imageData': bytes,
          }).toList();
          Get.toNamed('/video_edit', arguments: {
            'templateId': template.id,
            'videoImages': videoImages,
          });
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick images');
    }
  }

  Future<void> onFavoriteTap(TemplateEntity template) async {
    try {
      final newFavorite = !template.isFavorite;
      await db.updateTemplateFavorite(template.id!, newFavorite);
      await loadTemplates();
    } catch (e) {
      Get.snackbar('Error', 'Failed to update favorite');
    }
  }
}

