import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:convert';
import '../../main.dart';
import 'template_list_logic.dart';
import '../../db_album/album_entity.dart';
import '../../models/template_background.dart';
import '../../widgets/template_video_player.dart';

class TemplateListView extends GetView<TemplateListLogic> {
  const TemplateListView({super.key});

  @override
  Widget build(BuildContext context) {
    final typeName = controller.templateType == 'music' 
        ? 'Music Album Templates'
        : controller.templateType == 'text_image'
            ? 'Text Image Album Templates'
            : 'Video Album Templates';

    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: Text(typeName),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: accentColor),
          );
        }

        if (controller.templates.isEmpty) {
          return Center(
            child: Text(
              'No templates available',
              style: TextStyle(color: Colors.grey, fontSize: 16.sp),
            ),
          );
        }

        return GridView.builder(
          padding: EdgeInsets.all(16.w),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16.w,
            mainAxisSpacing: 16.h,
            childAspectRatio: 0.75,
          ),
          itemCount: controller.templates.length,
          itemBuilder: (context, index) {
            final template = controller.templates[index];
            return _buildTemplateCard(template);
          },
        );
      }),
    );
  }

  Widget _buildTemplateCard(TemplateEntity template) {
    TemplateBackground? background;
    if (template.animationConfig != null) {
      try {
        final config = jsonDecode(template.animationConfig!);
        final animId = config['id'] as String;
        background = TemplateBackgroundConfig.getByTemplateId(animId);
      } catch (e) {
      }
    }

    return GestureDetector(
      onTap: () => controller.onTemplateTap(template),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16.w),
          border: Border.all(
            color: template.isFavorite ? accentColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(14.w),
                ),
                child: background?.videoPath != null
                    ? TemplateVideoPlayer(
                        videoPath: background!.videoPath!,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        decoration: BoxDecoration(
                          gradient: background?.imagePath == null && background?.backgroundGradient != null
                              ? background?.backgroundGradient
                              : background?.imagePath == null
                                  ? const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [Color(0xFF00FFC2), Color(0xFFFF00C7)],
                                    )
                                  : null,
                          color: background?.imagePath == null
                              ? (background?.backgroundColor ?? Colors.black)
                              : null,
                          image: background?.imagePath != null
                              ? DecorationImage(
                                  image: AssetImage(background!.imagePath!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: background?.imagePath == null
                            ? Center(
                                child: Icon(
                                  controller.templateType == 'music'
                                      ? Icons.music_note
                                      : controller.templateType == 'text_image'
                                          ? Icons.image
                                          : Icons.videocam,
                                  color: Colors.white,
                                  size: 48.sp,
                                ),
                              )
                            : Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.3),
                                ),
                              ),
                      ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          template.name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          template.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: template.isFavorite ? accentColor : Colors.grey,
                          size: 20.sp,
                        ),
                        onPressed: () => controller.onFavoriteTap(template),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

