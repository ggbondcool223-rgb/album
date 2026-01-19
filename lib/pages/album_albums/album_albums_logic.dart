import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:cross_file/cross_file.dart';
import '../../db_album/data.dart';
import '../../db_album/album_entity.dart';
import '../../main.dart';

class AlbumAlbumsLogic extends GetxController {
  final db = Get.find<AlbumDB>();
  final albums = <AlbumEntity>[].obs;
  final allAlbums = <AlbumEntity>[].obs;
  final categories = <CategoryEntity>[].obs;
  final selectedCategoryId = Rx<String?>('');
  final isLoading = true.obs;
  final searchQuery = ''.obs;
  final selectedType = Rx<String?>('');

  @override
  void onInit() {
    super.onInit();
    loadCategories();
    loadAlbums();
  }

  Future<void> loadCategories() async {
    try {
      final cats = await db.getCategories();
      categories.value = cats;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load categories');
    }
  }

  Future<void> loadAlbums() async {
    isLoading.value = true;
    try {
      final loadedAlbums = await db.getAlbums(
        categoryId: selectedCategoryId.value?.isNotEmpty == true
            ? selectedCategoryId.value
            : null,
      );
      allAlbums.value = loadedAlbums;
      _applyFilters();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load albums');
    } finally {
      isLoading.value = false;
    }
  }

  void _applyFilters() {
    var filtered = List<AlbumEntity>.from(allAlbums);
    
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((album) {
        final titleMatch = album.title.toLowerCase().contains(query);
        final tagsMatch = album.tags?.toLowerCase().contains(query) ?? false;
        return titleMatch || tagsMatch;
      }).toList();
    }
    
    if (selectedType.value != null && selectedType.value!.isNotEmpty) {
      filtered = filtered.where((album) => album.type == selectedType.value!).toList();
    }
    
    albums.value = filtered;
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  void onTypeFilterChanged(String? type) {
    selectedType.value = type;
    _applyFilters();
  }

  void onCategoryTap(String? categoryId) {
    selectedCategoryId.value = categoryId;
    loadAlbums();
  }

  Future<void> onDeleteAlbumTap(int albumId) async {
    try {
      final result = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Delete Album'),
          content: const Text('Are you sure you want to delete this album?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Delete'),
            ),
          ],
        ),
      );
      if (result == true) {
        await db.deleteAlbum(albumId);
        loadAlbums();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete album');
    }
  }

  void onEditAlbumTap(int albumId) {
    final album = albums.firstWhere((a) => a.id == albumId);
    if (album.type == 'music') {
      Get.toNamed('/music_edit', arguments: {'albumId': albumId});
    } else if (album.type == 'text_image') {
      Get.toNamed('/text_image_edit', arguments: {'albumId': albumId});
    } else if (album.type == 'video') {
      Get.toNamed('/video_edit', arguments: {'albumId': albumId});
    }
  }

  void onPlayAlbumTap(int albumId) {
    Get.snackbar('Info', 'Play feature coming soon');
  }

  void onShareAlbumTap(int albumId) {
    Get.snackbar('Info', 'Share feature coming soon');
  }

  Future<void> onCreateCategoryTap() async {
    final textController = TextEditingController();
    final result = await Get.dialog<String>(
      Dialog(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Create Category', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
              SizedBox(height: 16.h),
              TextField(
                controller: textController,
                decoration: const InputDecoration(
                  hintText: 'Category Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Cancel'),
                  ),
                  SizedBox(width: 8.w),
                  TextButton(
                    onPressed: () => Get.back(result: textController.text),
                    child: const Text('Create'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (result != null && result.isNotEmpty) {
      try {
        final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
        await db.insertCategory(CategoryEntity(name: result, createdAt: now));
        Get.snackbar('Success', 'Category created');
        loadCategories();
      } catch (e) {
        Get.snackbar('Error', 'Failed to create category');
      }
    }
  }

  Future<void> onRefreshTap() async {
    await loadAlbums();
  }

  void onAlbumTap(AlbumEntity album) {
    if (album.type == 'music') {
      Get.toNamed('/music_edit', arguments: {'albumId': album.id})?.then((_) {
        loadAlbums();
      });
    } else if (album.type == 'text_image') {
      Get.toNamed('/text_image_edit', arguments: {'albumId': album.id})?.then((_) {
        loadAlbums();
      });
    } else if (album.type == 'video') {
      Get.toNamed('/video_edit', arguments: {'albumId': album.id})?.then((_) {
        loadAlbums();
      });
    }
  }

  Future<void> onDeleteAlbum(int albumId) async {
    try {
      final result = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Delete Album'),
          content: const Text('Are you sure you want to delete this album?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Delete'),
            ),
          ],
        ),
      );
      if (result == true) {
      await db.deleteAlbum(albumId);
      Get.snackbar('Success', 'Album deleted');
        loadAlbums();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete album');
    }
  }

  final selectedAlbums = <int>[].obs;
  final isBatchMode = false.obs;

  void onManageTap() {
    isBatchMode.value = !isBatchMode.value;
    if (!isBatchMode.value) {
      selectedAlbums.clear();
    }
  }

  void onAlbumSelectTap(int albumId) {
    if (isBatchMode.value) {
      if (selectedAlbums.contains(albumId)) {
        selectedAlbums.remove(albumId);
      } else {
        selectedAlbums.add(albumId);
      }
    }
  }

  Future<void> onBatchDeleteTap() async {
    if (selectedAlbums.isEmpty) {
      Get.snackbar('Info', 'Please select albums to delete');
      return;
    }

    final result = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: const Color(0xFF0B0B1E),
        title: Text('Delete Albums', style: TextStyle(color: Colors.white, fontSize: 18.sp)),
        content: Text(
          'Are you sure you want to delete ${selectedAlbums.length} album(s)?',
          style: TextStyle(color: Colors.grey, fontSize: 14.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text('Delete', style: TextStyle(color: const Color(0xFF00D4FF))),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        for (var albumId in selectedAlbums) {
          await db.deleteAlbum(albumId);
        }
        selectedAlbums.clear();
        isBatchMode.value = false;
        Get.snackbar('Success', 'Albums deleted');
        loadAlbums();
      } catch (e) {
        Get.snackbar('Error', 'Failed to delete albums');
      }
    }
  }

  Future<void> onBatchMoveCategoryTap() async {
    if (selectedAlbums.isEmpty) {
      Get.snackbar('Info', 'Please select albums to move');
      return;
    }

    final categoryList = ['All', ...categories.map((c) => c.name).toList()];
    final selectedCategory = await Get.bottomSheet<String>(
      Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0B0B1E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.w)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Text(
                'Select Category',
                style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
            ),
            ...categoryList.map((name) => ListTile(
              title: Text(name, style: TextStyle(color: Colors.white)),
              onTap: () => Get.back(result: name),
            )),
          ],
        ),
      ),
    );

    if (selectedCategory != null && selectedCategory != 'All') {
      try {
        final category = categories.firstWhere((c) => c.name == selectedCategory);
        for (var albumId in selectedAlbums) {
          final album = albums.firstWhere((a) => a.id == albumId);
          final updatedAlbum = AlbumEntity(
            id: album.id,
            title: album.title,
            type: album.type,
            coverData: album.coverData,
            templateId: album.templateId,
            musicPath: album.musicPath,
            categoryId: category.id?.toString(),
            tags: album.tags,
            videoPath: album.videoPath,
            createdAt: album.createdAt,
            updatedAt: DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
          );
          await db.updateAlbum(updatedAlbum);
        }
        selectedAlbums.clear();
        isBatchMode.value = false;
        Get.snackbar('Success', 'Albums moved to category');
        loadAlbums();
      } catch (e) {
        Get.snackbar('Error', 'Failed to move albums');
      }
    }
  }

  Future<void> onMoreVertTap(AlbumEntity album) async {
    final action = await Get.bottomSheet<String>(
      Container(
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.w)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Text(
                'Options',
                style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: Icon(Icons.delete, color: Colors.red),
              title: Text('Delete Album', style: TextStyle(color: Colors.white)),
              onTap: () => Get.back(result: 'delete'),
            ),
            ListTile(
              leading: Icon(Icons.save_alt, color: accentColor),
              title: Text('Export Images', style: TextStyle(color: Colors.white)),
              onTap: () => Get.back(result: 'export'),
            ),
          ],
        ),
      ),
    );

    if (action == 'delete') {
      if (album.id != null) {
        await onDeleteAlbum(album.id!);
      }
    } else if (action == 'export') {
      await exportAlbumImages(album);
    }
  }

  Future<void> exportAlbumImages(AlbumEntity album) async {
    try {
      final status = await Permission.photos.status;
      if (!status.isGranted) {
        final result = await Permission.photos.request();
        if (!result.isGranted) {
          Get.snackbar('Error', 'Photo permission is required to export images');
          return;
        }
      }

      Get.dialog(
        Center(
          child: Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(16.w),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: accentColor),
                SizedBox(height: 16.h),
                Text(
                  'Exporting images...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );

      if (album.id == null) {
        Get.back();
        Get.snackbar('Error', 'Invalid album');
        return;
      }

      final photos = await db.getAlbumPhotos(album.id!);
      if (photos.isEmpty) {
        Get.back();
        Get.snackbar('Info', 'No images to export');
        return;
      }

      int successCount = 0;
      int failCount = 0;

      for (final photo in photos) {
        try {
          final result = await ImageGallerySaverPlus.saveImage(
            photo.imageData,
            quality: 100,
          );
          if (result['isSuccess'] == true) {
            successCount++;
          } else {
            failCount++;
          }
        } catch (e) {
          failCount++;
        }
      }

      Get.back();

      if (successCount > 0) {
        Get.snackbar(
          'Success',
          '$successCount images exported to gallery${failCount > 0 ? ', $failCount failed' : ''}',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to export images',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.back();
      Get.snackbar('Error', 'Failed to export images: $e');
    }
  }
}

