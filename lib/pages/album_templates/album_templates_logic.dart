import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:typed_data';
import '../../db_album/data.dart';
import '../../db_album/album_entity.dart';
import '../../models/template_animation.dart';

class AlbumTemplatesLogic extends GetxController {
  final db = Get.find<AlbumDB>();
  final favoriteTemplates = <TemplateEntity>[].obs;
  final templates = <TemplateEntity>[].obs;
  final isLoading = true.obs;
  final ImagePicker picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    loadTemplates();
  }

  Future<void> loadTemplates() async {
    isLoading.value = true;
    try {
      final favorites = await db.getFavoriteTemplates();
      favoriteTemplates.value = favorites;
      
      final allTemplates = await db.getTemplates();
      if (allTemplates.isEmpty) {
        await _initDefaultTemplates();
        final reloaded = await db.getTemplates();
        templates.value = reloaded;
      } else {
        templates.value = allTemplates;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load templates');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _initDefaultTemplates() async {
    final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    
    final musicAnimations = TemplateAnimationConfig.getMusicTemplates();
    final textImageAnimations = TemplateAnimationConfig.getTextImageTemplates();
    final videoAnimations = TemplateAnimationConfig.getVideoTemplates();
    
    for (var anim in musicAnimations) {
      final config = jsonEncode({
        'id': anim.id,
        'imageAnimation': anim.imageAnimation.toString(),
        'subtitleAnimation': anim.subtitleAnimation.toString(),
        'danmakuAnimation': anim.danmakuAnimation.toString(),
        'transitionDuration': anim.transitionDuration.inMilliseconds,
      });
      final template = TemplateEntity(
        name: anim.name,
        type: anim.type,
        animationConfig: config,
        createdAt: now,
      );
      await db.insertTemplate(template);
    }
    
    for (var anim in textImageAnimations) {
      final config = jsonEncode({
        'id': anim.id,
        'imageAnimation': anim.imageAnimation.toString(),
        'subtitleAnimation': anim.subtitleAnimation.toString(),
        'danmakuAnimation': anim.danmakuAnimation.toString(),
        'transitionDuration': anim.transitionDuration.inMilliseconds,
      });
      final template = TemplateEntity(
        name: anim.name,
        type: anim.type,
        animationConfig: config,
        createdAt: now,
      );
      await db.insertTemplate(template);
    }
    
    for (var anim in videoAnimations) {
      final config = jsonEncode({
        'id': anim.id,
        'imageAnimation': anim.imageAnimation.toString(),
        'subtitleAnimation': anim.subtitleAnimation.toString(),
        'danmakuAnimation': anim.danmakuAnimation.toString(),
        'transitionDuration': anim.transitionDuration.inMilliseconds,
      });
      final template = TemplateEntity(
        name: anim.name,
        type: anim.type,
        animationConfig: config,
        createdAt: now,
      );
      await db.insertTemplate(template);
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
          Get.toNamed('/music_edit', arguments: {
            'templateId': template.id,
            'imageBytes': imageBytesList,
          });
        } else if (template.type == 'text_image') {
          final textImages = imageBytesList.map((bytes) => {
            'imageData': bytes,
          }).toList();
          Get.toNamed('/text_image_edit', arguments: {
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

