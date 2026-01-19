import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';
import '../../main.dart';
import '../../widgets/tag_input_field.dart';
import '../../models/template_animation.dart';
import '../music_edit/music_edit_view.dart';
import 'video_edit_logic.dart';
import '../../db_album/album_entity.dart';
import '../../widgets/background_video_player.dart';


class VideoEditView extends GetView<VideoEditLogic> {
  const VideoEditView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.setShowEditBottomSheetCallback(_showEditBottomSheet);
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: Obx(() => Text(controller.albumTitle.value)),
        actions: [
          TextButton(
            onPressed: controller.onSaveTap,
            child: Text(
              'Save',
              style: TextStyle(color: accentColor, fontSize: 16.sp),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _buildPreview()),
          _buildBottomToolbar()
        ],
      ),
    );
  }

  Widget _buildPreview() {
    return Obx(() {
      final hasPhotos = controller.photos.isNotEmpty;
      final currentPhoto = hasPhotos &&
          controller.currentPhotoIndex.value < controller.photos.length
          ? controller.photos[controller.currentPhotoIndex.value]
          : null;
      final background = controller.templateBackground.value;

      return Container(
        width: double.infinity,
        height: double.infinity,
        decoration: background?.videoPath == null
            ? BoxDecoration(
                gradient: background?.imagePath == null ? background
                    ?.backgroundGradient : null,
                color: background?.imagePath == null ? (background?.backgroundColor ??
                    Colors.black) : null,
                image: background?.imagePath != null
                    ? DecorationImage(
                        image: AssetImage(background!.imagePath!),
                        fit: BoxFit.cover,
                      )
                    : null,
              )
            : null,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (background?.videoPath != null)
              BackgroundVideoPlayer(
                videoPath: background!.videoPath!,
                fit: BoxFit.cover,
              )
            else
              const SizedBox.shrink(),
            Center(
              child: _buildAnimatedImage(currentPhoto),
            ),
            if (currentPhoto?.subtitle != null &&
                currentPhoto!.subtitle!.isNotEmpty)
              Positioned(
                bottom: 100.h,
                left: 16.w,
                right: 16.w,
                child: _buildAnimatedSubtitle(currentPhoto.subtitle!),
              ),
            _buildDanmakusOverlay(),
            Positioned(
              top: 16.h,
              right: 16.w,
              child: Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Obx(() =>
                      Icon(
                        controller.isPlaying.value ? Icons.pause : Icons
                            .play_arrow,
                        color: Colors.white,
                        size: 24.sp,
                      )),
                  onPressed: controller.onPlayPauseTap,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildAnimatedImage(dynamic currentPhoto) {
    return Obx(() {
      final animation = controller.templateAnimation.value;
      final animationStyle = animation?.imageAnimation ??
          TemplateAnimationStyle.fade;
      final animationKey = controller.animationUpdateKey.value;

      if (currentPhoto == null) {
        return Container(
          width: 260.w,
          height: 260.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.w),
            gradient: const LinearGradient(
              colors: [Color(0xFF00FFC2), Color(0xFFFF00C7)],
            ),
          ),
          child: Center(
            child: Icon(Icons.image, color: Colors.white, size: 64.sp),
          ),
        );
      }

      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 600),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return _buildEntryAnimation(child, animation, animationStyle);
        },
        child: KeyedSubtree(
          key: ValueKey('${currentPhoto.id}_$animationKey'),
          child: _buildContinuousAnimation(
            Image.memory(
              currentPhoto.imageData,
              width: 260.w,
              height: 260.w,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey.withOpacity(0.3),
                  child: Icon(
                      Icons.broken_image, color: Colors.grey, size: 64.sp),
                );
              },
            ),
            animationStyle,
          ),
        ),
      );
    });
  }

  Widget _buildContinuousAnimation(Widget child, TemplateAnimationStyle style) {
    switch (style) {
      case TemplateAnimationStyle.rotate:
        return _buildRotatingAnimation(child);
      case TemplateAnimationStyle.zoomIn:
      case TemplateAnimationStyle.zoomOut:
        return _buildZoomAnimation(child);
      case TemplateAnimationStyle.bounce:
        return _buildBouncingAnimation(child);
      case TemplateAnimationStyle.elastic:
        return _buildElasticAnimation(child);
      case TemplateAnimationStyle.slideLeft:
        return _buildSlideAnimation(child, Offset(1.0, 0.0));
      case TemplateAnimationStyle.slideRight:
        return _buildSlideAnimation(child, Offset(-1.0, 0.0));
      case TemplateAnimationStyle.slideUp:
        return _buildSlideAnimation(child, Offset(0.0, 1.0));
      case TemplateAnimationStyle.slideDown:
        return _buildSlideAnimation(child, Offset(0.0, -1.0));
      case TemplateAnimationStyle.fade:
      default:
        return _buildFadeAnimation(child);
    }
  }

  Widget _buildRotatingAnimation(Widget child) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 2 * 3.1415926535),
      duration: const Duration(seconds: 4),
      curve: Curves.linear,
      onEnd: () {
        controller.triggerAnimationUpdate();
      },
      builder: (context, value, child) {
        return Transform.rotate(
          angle: value,
          alignment: Alignment.center,
          child: child,
        );
      },
      child: child,
    );
  }

  Widget _buildZoomAnimation(Widget child) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.8, end: 1.2),
      duration: const Duration(seconds: 3),
      curve: Curves.easeInOut,
      onEnd: () {
        controller.triggerAnimationUpdate();
      },
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          alignment: Alignment.center,
          child: child,
        );
      },
      child: child,
    );
  }

  Widget _buildBouncingAnimation(Widget child) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.95, end: 1.05),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      onEnd: () {
        controller.triggerAnimationUpdate();
      },
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: child,
    );
  }

  Widget _buildElasticAnimation(Widget child) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.95, end: 1.05),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.elasticOut,
      onEnd: () {
        controller.triggerAnimationUpdate();
      },
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: child,
    );
  }

  Widget _buildSlideAnimation(Widget child, Offset direction) {
    return TweenAnimationBuilder<Offset>(
      tween: Tween(begin: Offset(-direction.dx * 100, -direction.dy * 100),
          end: Offset(direction.dx * 100, direction.dy * 100)),
      duration: const Duration(seconds: 4),
      curve: Curves.easeInOut,
      onEnd: () {
        controller.triggerAnimationUpdate();
      },
      builder: (context, value, child) {
        return Transform.translate(
          offset: value,
          child: child,
        );
      },
      child: child,
    );
  }

  Widget _buildFadeAnimation(Widget child) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.7, end: 1.0),
      duration: const Duration(seconds: 2),
      onEnd: () {
        controller.triggerAnimationUpdate();
      },
      builder: (context, value, child) {
        return Opacity(
          opacity: value.clamp(0.0, 1.0),
          child: child,
        );
      },
      child: child,
    );
  }

  Widget _buildEntryAnimation(Widget child, Animation<double> animation,
      TemplateAnimationStyle style) {
    switch (style) {
      case TemplateAnimationStyle.rotate:
        return RotationTransition(
          turns: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOut),
          ),
          child: FadeTransition(opacity: animation, child: child),
        );
      case TemplateAnimationStyle.zoomIn:
        return ScaleTransition(
          scale: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOut),
          ),
          child: FadeTransition(opacity: animation, child: child),
        );
      case TemplateAnimationStyle.zoomOut:
        return ScaleTransition(
          scale: Tween<double>(begin: 1.5, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOut),
          ),
          child: FadeTransition(opacity: animation, child: child),
        );
      case TemplateAnimationStyle.slideLeft:
        return SlideTransition(
          position: Tween<Offset>(
              begin: const Offset(1.0, 0.0), end: Offset.zero).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOut),
          ),
          child: FadeTransition(opacity: animation, child: child),
        );
      case TemplateAnimationStyle.slideRight:
        return SlideTransition(
          position: Tween<Offset>(
              begin: const Offset(-1.0, 0.0), end: Offset.zero).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOut),
          ),
          child: FadeTransition(opacity: animation, child: child),
        );
      case TemplateAnimationStyle.slideUp:
        return SlideTransition(
          position: Tween<Offset>(
              begin: const Offset(0.0, 1.0), end: Offset.zero).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOut),
          ),
          child: FadeTransition(opacity: animation, child: child),
        );
      case TemplateAnimationStyle.slideDown:
        return SlideTransition(
          position: Tween<Offset>(
              begin: const Offset(0.0, -1.0), end: Offset.zero).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOut),
          ),
          child: FadeTransition(opacity: animation, child: child),
        );
      case TemplateAnimationStyle.bounce:
        return ScaleTransition(
          scale: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.bounceOut),
          ),
          child: FadeTransition(opacity: animation, child: child),
        );
      case TemplateAnimationStyle.elastic:
        return ScaleTransition(
          scale: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.elasticOut),
          ),
          child: FadeTransition(opacity: animation, child: child),
        );
      case TemplateAnimationStyle.flip:
        return RotationTransition(
          turns: Tween<double>(begin: 0.5, end: 0.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOut),
          ),
          child: FadeTransition(opacity: animation, child: child),
        );
      case TemplateAnimationStyle.fade:
      default:
        return FadeTransition(
          opacity: animation,
          child: child,
        );
    }
  }

  Widget _buildBottomToolbar() {
    return Container(
      width: double.infinity,
      height: 80.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(200),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildToolbarButton(
              Icons.grid_view, 'Template', controller.onTemplateTap),
          _buildToolbarButton(Icons.music_note, 'Music', controller.onMusicTap),
          _buildToolbarButton(
            Icons.edit,
            'Edit',
                () => _showEditBottomSheet(),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbarButton(IconData icon, String label, VoidCallback? onTap,
      {bool isSelected = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w,),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
            colors: [Color(0xFF00FFC2), Color(0xFFFF00C7)],
          )
              : null,
          borderRadius: BorderRadius.circular(12.w),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 24.sp),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditBottomSheet() {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.8,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.w)),
        ),
        child: Column(
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.only(bottom: 16.h),
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(2.h),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildPhotoSection(),
                    SizedBox(height: 16.h),
                    _buildDanmakuSection(),
                    SizedBox(height: 16.h),
                    _buildSettingsSection(),
                    SizedBox(height: 16.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          controller.onSaveEditTap();
                          Get.back();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.w),
                          ),
                        ),
                        child: Text(
                          'Done',
                          style: TextStyle(color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}

extension VideoEditViewExtensions on VideoEditView {
  Widget _buildPhotoSection() {
    return GetBuilder<VideoEditLogic>(id: 'photo',builder: (_) {
      return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16.w),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Photos', style: TextStyle(color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    TextButton(
                      onPressed: controller.onAddPhotoTap,
                      child: Text('Add',
                          style: TextStyle(color: accentColor, fontSize: 14
                              .sp)),
                    ),
                    TextButton(
                      onPressed: controller.onReselectPhotosTap,
                      child: Text('Reselect',
                          style: TextStyle(color: accentColor, fontSize: 14
                              .sp)),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Obx(() => ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.photos.length,
              onReorder: (oldIndex, newIndex) {
                if (newIndex > oldIndex) {
                  newIndex -= 1;
                }
                controller.onPhotoReorder(oldIndex, newIndex);
              },
              itemBuilder: (context, index) {
                final photo = controller.photos[index];
                final imageHash = photo.imageData.hashCode;
                return _buildPhotoItem(photo, index, imageHash, key: ValueKey('photo_item_${photo.id ?? index}_${photo.sortOrder}'));
              },
            )),
          ],
        ),
      );
    });
  }

  Widget _buildPhotoItem(dynamic photo, int index, int imageHash, {required Key key}) {
    return Container(
      key: key,
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12.w),
      ),
      child: Row(
        children: [
          GestureDetector(
            key: ValueKey('gesture_${photo.id ?? index}_$imageHash'),
            onTap: () {
              controller.onPhotoEditTap(index);
            },
            behavior: HitTestBehavior.opaque,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.w),
              child: Image.memory(
                photo.imageData,
                width: 64.w,
                height: 64.w,
                fit: BoxFit.cover,
                key: ValueKey('image_${photo.id ?? index}_$imageHash'),
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 64.w,
                    height: 64.w,
                    color: Colors.grey.withOpacity(0.3),
                    child: Icon(Icons.image, color: Colors.grey, size: 32.sp),
                  );
                },
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: TextField(
              maxLength: 20,
              style: TextStyle(color: Colors.white, fontSize: 14.sp),
              decoration: InputDecoration(
                hintText: 'Enter subtitle',
                hintStyle: TextStyle(color: Colors.grey, fontSize: 14.sp),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.w),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.w),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.w),
                  borderSide: BorderSide(color: accentColor, width: 2),
                ),
                contentPadding: EdgeInsets.symmetric(
                    horizontal: 12.w, vertical: 8.h),
                counterText: '',
              ),
              controller: TextEditingController(text: photo.subtitle ?? '')
                ..selection = TextSelection.fromPosition(
                    TextPosition(offset: photo.subtitle?.length ?? 0)),
              onChanged: (value) => controller.onSubtitleChanged(index, value),
            ),
          ),
          SizedBox(width: 8.w),
          Icon(Icons.drag_handle, color: Colors.grey, size: 24.sp),
          SizedBox(width: 4.w),
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red, size: 20.sp),
            onPressed: () => controller.onDeletePhotoTap(index),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedSubtitle(String subtitle) {
    final animation = controller.templateAnimation.value;
    final subtitleStyle = animation?.subtitleAnimation ??
        TemplateAnimationStyle.slideUp;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return _buildEntryAnimation(child, animation, subtitleStyle);
      },
      child: Container(
        key: ValueKey(subtitle),

        child: Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildDanmakusOverlay() {
    return Obx(() {
      final allDanmakus = controller.danmakus;
      controller.danmakuAnimationTime.value;

      if (allDanmakus.isEmpty) {
        return const SizedBox.shrink();
      }

      return Stack(
        children: allDanmakus
            .asMap()
            .entries
            .map((entry) {
          final index = entry.key;
          final danmaku = entry.value;
          final animation = controller.templateAnimation.value;
          final danmakuStyle = animation?.danmakuAnimation ??
              TemplateAnimationStyle.slideRight;

          return _buildDanmakuWidget(danmaku, index, danmakuStyle);
        }).toList(),
      );
    });
  }

  Widget _buildDanmakuWidget(dynamic danmaku, int index,
      TemplateAnimationStyle style) {
    final baseProgress = controller.danmakuAnimationTime.value / 5.0;
    final progress = (baseProgress + (index * 0.2)) % 1.0;
    double yPosition = 0.0;
    if (danmaku.style != null) {
      try {
        final styleMap = danmaku.style is String ? Map<String, dynamic>.from(
            jsonDecode(danmaku.style)) : danmaku.style;
        yPosition = (styleMap['position'] ?? 0.0) * Get.height * 0.1;
      } catch (e) {
        yPosition = (index % 5) * 60.0;
      }
    } else {
      yPosition = (index % 5) * 60.0;
    }

    double leftPosition = 16.w;
    double opacity = 1.0;

    if (style == TemplateAnimationStyle.slideRight) {
      if (progress < 0.2) {
        final entryProgress = progress / 0.2;
        leftPosition = -Get.width * (1 - entryProgress);
      } else if (progress > 0.8) {
        final exitProgress = (progress - 0.8) / 0.2;
        leftPosition = 16.w + (Get.width - 16.w - 200.w) * (1 - exitProgress);
      } else {
        final stayProgress = (progress - 0.2) / 0.6;
        leftPosition = 16.w + (Get.width - 16.w - 200.w) * stayProgress;
      }
    } else if (style == TemplateAnimationStyle.slideLeft) {
      if (progress < 0.2) {
        final entryProgress = progress / 0.2;
        leftPosition = Get.width - (Get.width - 16.w - 200.w) * entryProgress;
      } else if (progress > 0.8) {
        final exitProgress = (progress - 0.8) / 0.2;
        leftPosition = 16.w + (Get.width - 16.w - 200.w) * exitProgress;
      } else {
        final stayProgress = (progress - 0.2) / 0.6;
        leftPosition =
            Get.width - 200.w - (Get.width - 16.w - 200.w) * (1 - stayProgress);
      }
    } else if (style == TemplateAnimationStyle.fade) {
      if (progress < 0.2) {
        opacity = progress / 0.2;
      } else if (progress > 0.8) {
        opacity = 1.0 - (progress - 0.8) / 0.2;
      }
      leftPosition = (Get.width - 200.w) / 2;
    } else {
      leftPosition = (Get.width - 200.w) / 2;
    }

    return Positioned(
      top: 100.h + yPosition,
      left: leftPosition.clamp(0.0, Get.width.toDouble()),
      child: Opacity(
        opacity: opacity.clamp(0.0, 1.0),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(16.w),
          ),
          child: Text(
            danmaku.content,
            style: TextStyle(color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }

  Widget _buildDanmakuSection() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Danmaku', style: TextStyle(color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: controller.onAddDanmakuTap,
                child: Text('Add',
                    style: TextStyle(color: accentColor, fontSize: 14.sp)),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Obx(() =>
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.danmakus.length,
                itemBuilder: (context, index) {
                  final danmaku = controller.danmakus[index];
                  return _buildDanmakuItem(danmaku, index);
                },
              )),
        ],
      ),
    );
  }

  Widget _buildDanmakuItem(dynamic danmaku, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12.w),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  danmaku.content,
                  style: TextStyle(color: Colors.white, fontSize: 14.sp),
                ),
                SizedBox(height: 4.h),
                Text(
                  '${danmaku.timePoint.toStringAsFixed(1)}s',
                  style: TextStyle(color: Colors.grey, fontSize: 12.sp),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.edit, color: accentColor),
                onPressed: () => controller.onDanmakuEditTap(index),
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  controller.onDeleteDanmakuTap(index);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Settings', style: TextStyle(color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold)),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12.w),
            ),
            child: TextField(
              maxLength: 20,
              controller: TextEditingController(
                  text: controller.albumTitle.value),
              onChanged: (value) => controller.albumTitle.value = value,
              style: TextStyle(color: Colors.white, fontSize: 14.sp),
              decoration: InputDecoration(
                border: InputBorder.none,
                counterText: '',
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Text('Tags', style: TextStyle(color: Colors.white, fontSize: 14.sp)),
          SizedBox(height: 8.h),
          TagInputField(
            initialValue: controller.albumTags.value,
            onChanged: (value) => controller.albumTags.value = value,
            maxLength: 10,
          ),
        ],
      ),
    );
  }
}

