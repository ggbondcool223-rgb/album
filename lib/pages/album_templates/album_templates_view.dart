import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:styled_widget/styled_widget.dart';
import 'dart:convert';
import '../../main.dart';
import 'album_templates_logic.dart';
import '../../db_album/album_entity.dart';
import '../../models/template_background.dart';
import '../../widgets/template_video_player.dart';

class AlbumTemplatesView extends GetView<AlbumTemplatesLogic> {
  const AlbumTemplatesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        title: const Text('Templates').textColor(Colors.white),
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: accentColor),
          );
        }

        return SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTemplateTypes(),
                SizedBox(height: 16.h),
                _buildRecommendedTemplates(),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTemplateTypes() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Template Type',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12.h),
          _buildTemplateTypeCard(
            icon: Icons.music_note,
            title: 'Music Album Templates',
            subtitle: '5 templates',
            gradient: const LinearGradient(
              colors: [Color(0xFF00FFC2), Color(0xFFFF00C7)],
            ),
            onTap: () {
              Get.toNamed('/template_list/music')?.then((_) {
                controller.loadTemplates();
              });
            },
          ),
          SizedBox(height: 12.h),
          _buildTemplateTypeCard(
            icon: Icons.photo_library,
            title: 'Text Image Album Templates',
            subtitle: '4 templates',
            gradient: const LinearGradient(
              colors: [Color(0xFF00D4FF), Color(0xFF00FFC2)],
            ),
            onTap: () {
              Get.toNamed('/template_list/text_image')?.then((_) {
                controller.loadTemplates();
              });
            },
          ),
          SizedBox(height: 12.h),
          _buildTemplateTypeCard(
            icon: Icons.video_library,
            title: 'Video Album Templates',
            subtitle: '4 templates',
            gradient: const LinearGradient(
              colors: [Color(0xFFFF00C7), Color(0xFF00D4FF)],
            ),
            onTap: () {
              Get.toNamed('/template_list/video')?.then((_) {
                controller.loadTemplates();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateTypeCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              accentColor.withOpacity(0.1),
              const Color(0xFFFF00C7).withOpacity(0.1),
            ],
          ),
          border: Border.all(
            color: accentColor.withOpacity(0.3),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(16.w),
        ),
        child: Row(
          children: [
            Container(
              width: 64.w,
              height: 64.w,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(12.w),
              ),
              child: Icon(icon, color: Colors.white, size: 32.sp),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey, size: 24.sp),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendedTemplates() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
            'Favorites',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 12.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Obx(() {
            return controller.favoriteTemplates.isEmpty
                ? const Center(
                    child: Text('No favorites',style: TextStyle(color: Colors.white),),
                  )
                : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16.w,
                      mainAxisSpacing: 16.h,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: controller.favoriteTemplates.length,
                    itemBuilder: (context, index) {
                      return _buildTemplateCard(
                          controller.favoriteTemplates[index]);
                    },
                  );
          }),
        ),
      ],
    );
  }

  Widget _buildTemplateCard(TemplateEntity template) {
    TemplateBackground? background;
    if (template.animationConfig != null) {
      try {
        final config = jsonDecode(template.animationConfig!);
        final animId = config['id'] as String;
        background = TemplateBackgroundConfig.getByTemplateId(animId);
      } catch (e) {}
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
                          gradient: background?.imagePath == null &&
                                  background?.backgroundGradient != null
                              ? background?.backgroundGradient
                              : background?.imagePath == null
                                  ? const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFF00FFC2),
                                        Color(0xFFFF00C7)
                                      ],
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
                                  template.type == 'music'
                                      ? Icons.music_note
                                      : template.type == 'text_image'
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
                          color:
                              template.isFavorite ? accentColor : Colors.grey,
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
