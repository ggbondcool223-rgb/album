import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:convert';
import '../../main.dart';
import '../../widgets/tag_input_field.dart';
import 'text_image_edit_logic.dart';
import '../../models/template_animation.dart';

class TextImageEditView extends GetView<TextImageEditLogic> {
  const TextImageEditView({super.key});

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
          _buildBottomToolbar(),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    return Obx(() {
      final background = controller.templateBackground.value;

      return Container(
        decoration: BoxDecoration(
          gradient: background?.imagePath == null
              ? background?.backgroundGradient
              : null,
          color: background?.imagePath == null
              ? (background?.backgroundColor ?? primaryColor)
              : null,
          image: background?.imagePath != null
              ? DecorationImage(
                  image: AssetImage(background!.imagePath!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(16.w),
                    itemCount: controller.photos.length,
                    itemBuilder: (context, index) {
                      final photo = controller.photos[index];
                      return _buildPhotoItem(photo, index);
                    },
                  ),
                ),
              ],
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
                  icon: Obx(() => Icon(
                        controller.isPlaying.value
                            ? Icons.pause
                            : Icons.play_arrow,
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

  Widget _buildPhotoItem(dynamic photo, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12.w)),
            child: Image.memory(
              photo.imageData,
              height: 300.h,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 300.h,
                  color: Colors.grey.withOpacity(0.3),
                  child: Icon(Icons.image, color: Colors.grey, size: 64.sp),
                );
              },
            ),
          ),
          if (photo.subtitle != null && photo.subtitle!.isNotEmpty)
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Text(
                photo.subtitle!,
                style: TextStyle(color: Colors.white, fontSize: 14.sp),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomToolbar() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildToolbarButton(
              Icons.grid_view, 'Template', controller.onTemplateTap),
          _buildToolbarButton(Icons.music_note, 'Music', controller.onMusicTap),
          _buildToolbarButton(Icons.edit, 'Edit', () => _showEditBottomSheet()),
        ],
      ),
    );
  }

  Widget _buildToolbarButton(IconData icon, String label, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDanmakusOverlay() {
    return Obx(() {
      final allDanmakus = controller.danmakus;

      if (allDanmakus.isEmpty) {
        return const SizedBox.shrink();
      }

      return Stack(
        children: allDanmakus.asMap().entries.map((entry) {
          final index = entry.key;
          final danmaku = entry.value;
          return _buildDanmakuWidget(
              danmaku, index, TemplateAnimationStyle.slideRight);
        }).toList(),
      );
    });
  }

  Widget _buildDanmakuWidget(
      dynamic danmaku, int index, TemplateAnimationStyle style) {
    final baseProgress = controller.danmakuAnimationTime.value / 5.0;
    final progress = (baseProgress + (index * 0.2)) % 1.0;
    double yPosition = (index % 5) * 60.0;

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
            style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }
}

extension TextImageEditViewExtensions on TextImageEditView {
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
                          style: TextStyle(
                              color: Colors.white,
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

  Widget _buildPhotoSection() {
    return GetBuilder<TextImageEditLogic>(
      builder: (_) {
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
                  Text('Photos',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      TextButton(
                        onPressed: controller.onAddPhotoTap,
                        child: Text('Add',
                            style:
                                TextStyle(color: accentColor, fontSize: 14.sp)),
                      ),
                      TextButton(
                        onPressed: controller.onReselectPhotosTap,
                        child: Text('Reselect',
                            style:
                                TextStyle(color: accentColor, fontSize: 14.sp)),
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
                      return _buildPhotoListItem(photo, index, imageHash,
                          key: ValueKey(
                              'photo_item_${photo.id ?? index}_${photo.sortOrder}'));
                    },
                  )),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPhotoListItem(dynamic photo, int index, int imageHash,
      {required Key key}) {
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
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                counterText: '',
              ),
              controller: TextEditingController(text: photo.subtitle ?? '')
                ..selection = TextSelection.fromPosition(
                  TextPosition(offset: (photo.subtitle ?? '').length),
                ),
              onChanged: (value) => controller.onSubtitleChanged(index, value),
            ),
          ),
          SizedBox(width: 12.w),
          GestureDetector(
            onTap: () => controller.onDeletePhotoTap(index),
            child: Icon(Icons.delete, color: Colors.red, size: 24.sp),
          ),
          SizedBox(width: 8.w),
          Icon(Icons.drag_handle, color: Colors.grey, size: 24.sp),
        ],
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
              Text('Danmaku',
                  style: TextStyle(
                      color: Colors.white,
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
          Obx(() => ListView.builder(
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
                Text(danmaku.content,
                    style: TextStyle(color: Colors.white, fontSize: 14.sp)),
                SizedBox(height: 4.h),
                Text('${danmaku.timePoint.toStringAsFixed(1)}s',
                    style: TextStyle(color: Colors.grey, fontSize: 12.sp)),
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
                onPressed: () => controller.onDeleteDanmakuTap(index),
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
          Text('Settings',
              style: TextStyle(
                  color: Colors.white,
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
              controller:
                  TextEditingController(text: controller.albumTitle.value),
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
